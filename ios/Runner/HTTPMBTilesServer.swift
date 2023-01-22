import Foundation
import Swifter
import UIKit
import SQLite3
import MobileCoreServices
struct gl {
    static var fileMng = ""
    static var layers:[String:MBTiles] = [:]
    static var gpkg_layers:[String:GPKG] = [:]
    static var isServerLive:Bool = false
    static var port:String = "-1"
    static var manager:GPKGGeoPackageManager = GPKGGeoPackageManager();
    static var server:HttpServer? = nil;
    static var appWWWDir = Bundle.main.bundleURL
    static var alert = UIAlertController(title: "", message: "Loading Data...", preferredStyle: .alert)
    static var isAlertInit = false
    static var typesDic = [
        "zip":["tmg.geoint.explorer.shp"],
        "geojson":["tmg.geoint.explorer.geojson"],
        "gpkg":["tmg.geoint.explorer.gpkg"],
        "mbtiles":["tmg.geoint.explorer.mbtiles"],
        "json":["tmg.geoint.explorer.json","public.json"],
        "csv":["public.comma-separated-values-text"],
        "kml":["tmg.geoint.explorer.kml"],
        "jpg":["public.jpeg","public.png"]
    ]
    
}
@objc(HTTPMBTilesServer) class HTTPMBTilesServer : CDVPlugin, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    
    @objc(startServer:)
    func startServer(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let port=TMGDB.init().startServer()
        if port=="error" {
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR
            )
        }else{
            let jsonObject:[String:Any] = ["port": port]
            
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: jsonObject
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
        
    }
    
    @objc(addTiles:)
    func addTiles(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        
        let layerName = command.arguments[0] as? String ?? ""
        let fileName = command.arguments[1] as? String ?? ""
        
        print(layerName)
        print( gl.server!.state)
        var jsonObject:[String:Any]=[:]
        var fileSize : UInt64
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: fileName)
            fileSize = attr[FileAttributeKey.size] as! UInt64
        } catch {
            fileSize = 0
            print("Error: \(error)")
        }
        if fileSize == 0 {
            jsonObject["error"] = "Null File"
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: jsonObject
            )
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
            return
        }
        
        let mbTiles=MBTiles.init(path: fileName)
        
        let bounds=mbTiles.getBounds()
        let type=mbTiles.getType()
        let format=mbTiles.getFormat()
        let mzZoom=mbTiles.getMaxZoom()
        let mCenter=mbTiles.getCenter()
        let mAll=mbTiles.getAllMetaData()
        gl.layers[layerName]=mbTiles
        jsonObject["error"] = 0
        jsonObject["type"]  =  type
        jsonObject["format"]  = format
        jsonObject["maxZoom"] = mzZoom
        jsonObject["center"] = mCenter
        jsonObject["allInfo"] = mAll
        
        var boundsJSON:[Double] = []
        for i in 0..<bounds.count {
            boundsJSON.append(bounds[i] ?? 0)
        }
        jsonObject["bounds"] = boundsJSON;
        print(jsonObject)
        pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: jsonObject
        )
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
        
        
    }
    
    @objc(addGpkgTiles:)
    func addGpkgTiles(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        
        self.commandDelegate.run {
            do {
                var jsonObject:[String:Any]=[:]
                let layerName = command.arguments[0] as? String ?? ""
                let fileName = command.arguments[1] as? String ?? ""
                let nGpkg=GPKG.init(fileName: fileName, manager: gl.manager)
                print(fileName)
                let type = try nGpkg.getMetaData()
                print("type")
                jsonObject["info"] = nGpkg.getAllMetaData()
                 print("info")
                gl.gpkg_layers[layerName]=nGpkg
                
                var jsonArray:[[String:String]] = []
                var errorsArray:[String] = []
                for i in 0..<type.count {
                    let row = type[i].components(separatedBy: ":")
                    if row.count > 2 {
                        let js:[String:String] = ["name":row[0],"type":row[1],"bounds":row[2],"maxZoom":row[3]]
                        jsonArray.append(js)
                    } else {
                        errorsArray.append(type[i])
                    }
                    
                }
                if type.count > 0 && errorsArray.count > 0 {
                    jsonObject["error"] = 1
                } else if type.count == 0 {
                    jsonObject["error"] = 1
                    errorsArray.append("No Tables Found With SRIDS 4326,3857")
                } else {
                    jsonObject["error"] = 0
                }
                jsonObject["detail"] = jsonArray
                jsonObject["msg"] = errorsArray
                
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: jsonObject
                )
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
            }catch {
                print("eee")
            }
            
            
            
            
        }
        
        
    }
    
    
    
    
    
    
    
    @objc(getTiles:)
    func getTiles(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let fileManager = FileManager.default
        let path = command.arguments[0] as? String ?? ""
        let mbPath1 = fileManager.fileExists(atPath: path+"hillshade_rastertiles.mbtiles")
        let mbPath2 = fileManager.fileExists(atPath: path+"contourlines_vectortiles.mbtiles")
        let msg = "\(mbPath1),\(mbPath2)"
        
        pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: msg
        )
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    
    var downloadCallBackContext = ""
    @objc(initDatabase:)
    func initDatabase(command: CDVInvokedUrlCommand) {
        self.downloadCallBackContext = command.callbackId
        if self.downloadFile() > 0 {
            postInitFiles()
        } else {
            self.commandDelegate!.send(
                CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "No Downloads Found"),
                callbackId: self.downloadCallBackContext
            )
        }
        
    }
    
    func postInitFiles() {
        if self.countriesList.count > 0 {
            let downloadAvailableViewController:CountriesViewController = self.viewController.storyboard?.instantiateViewController(withIdentifier: "CountriesViewController") as! CountriesViewController
            downloadAvailableViewController.countriesList = countriesList
            downloadAvailableViewController.countriesListMaster = countriesList
            downloadAvailableViewController.needForDownloadOptional = needForDownloadOptional
            downloadAvailableViewController.notNeedForDownloadOptional = notNeedForDownloadOptional
            downloadAvailableViewController.callBackId = self.downloadCallBackContext
            downloadAvailableViewController.db = self.db
            downloadAvailableViewController.DNDIRECTORY = self.DNDIRECTORY
            downloadAvailableViewController.fromMap = true
            downloadAvailableViewController.commandDelegate = self.commandDelegate
            let navigationBar = UINavigationController.init(rootViewController: downloadAvailableViewController)
            self.viewController.present(navigationBar, animated: true, completion: {
                
            })
        } else {
            self.commandDelegate!.send(
                CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "No Downloads Found"),
                callbackId: self.downloadCallBackContext
            )
        }
    }
    var countriesList: [String] = ["TMG","GEO","INT"]
    var countriesListMaster: [String] = ["TMG","GEO","INT"]
    var countryNameSelected: String = ""
    
    var listItems: [String] = []
    var checkedItems: [Bool] = []
    var needForDownloadOptional:[[String]] = []
    var notNeedForDownloadOptional:[[String]] = []
    var DNDIRECTORY:URL = URL(fileURLWithPath: "")
    func getCountryList()  {
        
    }
    var db:DBHelper? = nil
    func downloadFile() -> Int {
        if db == nil {
            db = DBHelper()
        }
        let documentsDirectoryURL:URL = FileManager.default.urls(for:.applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = documentsDirectoryURL.appendingPathComponent("geoint_data_explorer")
        
        let needFiles:[[String]] = db!.getFiles(selection: "*", wherest: " where path!=''", table: "files3")
        let lengthOfFile = needFiles.count
        if lengthOfFile > 0 {
            
            notNeedForDownloadOptional.removeAll()
            countriesList.removeAll()
            for i in needFiles.indices {
                let fileCountry = needFiles[i][4]
                if countriesList.firstIndex(of: fileCountry) == nil {
                    countriesList.append(fileCountry)
                }
                let file = needFiles[i][0]
                let type = needFiles[i][2]
                let sizeStr = needFiles[i][1]
                let size = Int(needFiles[i][1])
                var ffFile = needFiles[i][3]
                if ffFile.count>0 {
                    ffFile = "\(folder.path)/\(needFiles[i][3])"
                }
                
                
                
                if FileManager.default.fileExists(atPath: ffFile) {
                    
                    var ffsize = 0;
                    do {
                        let flAttr = try FileManager.default.attributesOfItem(atPath: ffFile)
                        ffsize = flAttr[FileAttributeKey.size] as! Int
                    }catch{
                        ffsize = 0;
                    }
                    
                    if ffsize == size! {
                        notNeedForDownloadOptional.append([file, sizeStr, type, ffFile, fileCountry])
                    }
                }
            }
        }
        return lengthOfFile
    }
    
    @objc(update:)
    func update(command: CDVInvokedUrlCommand) {
        if command.arguments.count > 0 {
            let data = command.arguments[0] as? String ?? ""
            let type = command.arguments[1] as? String ?? ""
            if type == "get" || type == "save" {
                if type == "get" {
                    if gl.isServerLive != true {
                        _ = TMGDB.init().startServer()
                        gl.isServerLive = true
                    }
                }
                self.commandDelegate!.send(
                    CDVPluginResult(status: CDVCommandStatus_OK, messageAs: getSearchResults(data: data, type: type)),
                    callbackId: command.callbackId
                )
                return
            } else if type == "openManual" {
                MainMenu.openAboutAppManual(vc: self.viewController)
            }
        }
        if gl.isServerLive != true {
            _ = TMGDB.init().startServer()
            gl.isServerLive = true
        }
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        let msg = command.arguments[0] as? String ?? ""
        _ = TMGDB.init().insertData(min: msg)
        let db_count=TMGDB.init().getCrypto()
        let jsonObject:[String:String] = ["db": "ok", "cnt": db_count]
        
        pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: jsonObject
        )
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
        
    }
    
    
    
    @objc(fileChooser:)
    func fileChooser(command: CDVInvokedUrlCommand) {
        gl.fileMng = command.callbackId
        let type = command.arguments[0] as? String ?? ""
        self.attachDocument(types: gl.typesDic[type]!)
    }
    
    @objc(showToast:)
    func showToast(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        let msg = command.arguments[0] as? String ?? ""
        if msg.count > 0 {
            let toastController: UIAlertController =
                UIAlertController(
                    title: "",
                    message: msg,
                    preferredStyle: .alert
            )
            
            self.viewController?.present(
                toastController,
                animated: true,
                completion: nil
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                toastController.dismiss(
                    animated: true,
                    completion: nil
                )
            }
            
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: msg
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    private func attachDocument(types:[String]) {
        
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .open)
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        print(types)

        self.viewController.present(importMenu, animated: true)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let myURL = urls[0] as URL

        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: myURL.path
        )
        self.commandDelegate!.send(
            pluginResult,
            callbackId: gl.fileMng
        )
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.viewController.dismiss(animated: true, completion: nil)
    }

    @objc(playAudio:)
    func playAudio(command: CDVInvokedUrlCommand) {
        let id = command.arguments[0] as? String ?? ""
        let data = command.arguments[1] as? String ?? ""
        if !gl.isAlertInit {
            gl.isAlertInit = true
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            gl.alert.view.addSubview(loadingIndicator)
        }
        if data.contains("update") {
            let nn = data.components(separatedBy: "@")
            gl.alert.title = "Loading Data..."
            gl.alert.message = nn[1]
        } else {
            if id.lowercased().contains("show") {
                self.viewController.present(gl.alert, animated: true, completion: nil)
                gl.alert.title = "Loading Data..."
                gl.alert.message = ""
            } else if id.lowercased().contains("hide") {
                gl.alert.dismiss(animated: true, completion: nil)
            }
        }
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: id
        )
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }


    func getSearchResults(data: String, type: String) -> [String:Any] {
        var isReady = false;
        if db == nil {
            db = DBHelper()
            if db!.status == false {
                db!.reinit()
            }
            isReady = db!.status
        } else {
            isReady = true;
        }
        var jsonObject:[String:Any] = ["status": false, "val": "0,0,0", "isServer": gl.isServerLive, "port": gl.port]
        if isReady {
            if type == "save" {
                jsonObject["status"] = db!.insertSettings(data: data)
            } else {
                let needFiles:[[String]] = db!.getFiles(selection: "*", wherest: "", table: "settings")
                jsonObject["status"] = needFiles.count > 0
                if needFiles.count > 0 {
                    jsonObject["val"] = needFiles[0][0]
                }
            }
        }
        return jsonObject
    }
}

//SQLITE SECTION

class TMGDB{
    var db: OpaquePointer?
    func viewDidLoad() ->String{

        let fileUrl=try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:  nil, create: false).appendingPathComponent("explorercrypto.sqlite")

        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("error opening file")
            return "error opening file"
        }
        let tablename="settings"
        let col1="counter"
        let createSQL="create table if not exists " + tablename + " (" + col1 + " TEXT )"

        if sqlite3_exec(db,createSQL,nil,nil,nil) != SQLITE_OK {
            print("error creating table")
            return "error creating table"

        }
        return "OK"
    }

    func insertData(min: String) ->Bool {
        var stmt: OpaquePointer?
        let isDB=viewDidLoad()
        if isDB=="OK" {

            let delSQL = "DELETE FROM settings"
            sqlite3_exec(db,delSQL,nil,nil,nil)
            let queryString = "INSERT INTO settings (counter) VALUES (?)"

            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                return false
            }
            if sqlite3_bind_text(stmt, 1, min, -1, nil) != SQLITE_OK{
                return false

            }
            if sqlite3_step(stmt) != SQLITE_DONE {
                return false
            }else{
                return true
            }

        }else{
            return false
        }

    }

    func getCrypto()->String{
        let isDB=viewDidLoad()

        var v="U2FsdGVkX186mQawqxVBo6PiUfXbflCLtTVnPTZNw4YZWzn6S7Axqq+VHqGZSy3EUuHRjgnIwCysNDM74g6QAWkgZET1dNS5u5IFhAmoG/YImMzMEvWcZDSeVjDlC3LO/a9IOsXfljIUMymFT+AW6d5Rc+v18P5/VsyPV50KqNZ71VbUOhqxMMfBmg3Soaw5i6wHrYoIB5aj4J04Vpx8KDVVNtWNm1iIkqgKVDVSr8xh+jFd279+VgnaBwMFlFCzK/AOJRBclJy0ls9RaDfTcw==";
        if isDB=="OK" {
            let queryString = "SELECT * FROM settings"

            var stmt:OpaquePointer?

            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                return v
            }

            while(sqlite3_step(stmt) == SQLITE_ROW){
                v = String(cString: sqlite3_column_text(stmt, 0))
            }
            return v

        }else{
            return v
        }



    }

    func startServer() -> String {
        var port="8008"
        gl.server = HttpServer()
        gl.server!["/:type/:layerName/:z/:x/:y"] = {request in
            //let endnode=request.params
            //let values=Array(endnode.values)
            var res:NSData?
            var response: HttpResponse
            let resr:String="\(String(describing: request.path))"
            if resr.contains("/elevation-tiles-prod/terrarium/") {
                let xyz = "https://s3.amazonaws.com\(resr)"
                do {
                    let img = try Data(contentsOf: URL(string: xyz)!)
                    response =  HttpResponse.raw(200, "OK", ["Content-Type":"image/png","Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"*"], {try $0.write(img)})
                } catch {
                    print(error.localizedDescription)
                    response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                }
                
                return response
            }
            if resr.contains("/file/") {
                var indexStart = resr.components(separatedBy: "/")
                if var index = indexStart.lastIndex(of: "file") {
                    index = Array<String>.Index(Int(index)+1)
                    indexStart = Array(indexStart[index...])
                    var fileURL:URL = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
                    for itme in indexStart {
                        fileURL.appendPathComponent(itme)
                    }
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            let fileData = Data(try NSData(contentsOfFile: fileURL.path))
                            response = HttpResponse.raw(200, "OK", ["Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers":"*"], { writer in
                                try? writer.write(fileData)
                            })
                        } catch {
                            print(error.localizedDescription)
                            response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                        }
                        
                    } else {
                        response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                    }
                } else {
                    response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                }
                return response
            }
            let values=resr.components(separatedBy: "/")
            let type=Int(values[1])!
            let layerName = values[2]
            let zoom = Int(values[3])!
            let xx = Int(values[4])!
            let last = values[5].split(separator: ".")
            var yy=0
            if type != 6 {
                yy=Int(last[0])!
            }

            if type == 6 {
                response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                var fileName =  layerName.replacingOccurrences(of: "@@@", with: "/")
                if last.count>2 {
                    fileName = "\(gl.appWWWDir.path)/\(fileName)\(last[1]).\(last[2])"
                } else {
                    fileName = "\(gl.appWWWDir.path)/\(fileName)"
                }

                if FileManager.default.fileExists(atPath: fileName) {
                    print("Exist");

                    if last.firstIndex(of: String.SubSequence("json")) != nil {
                        print("json");
                        do {
                            let contents = try String(contentsOfFile: fileName)
                            response = HttpResponse.raw(200, "OK", ["Access-Control-Allow-Origin": "*", "Content-Type":"application/json","Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"*"], { writer in
                                try? writer.write([UInt8](contents.utf8))
                            })
                        } catch  {
                            response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                        }
                    } else if last.firstIndex(of: String.SubSequence("png")) != nil {
                        print("png");
                        let icon = UIImage(named: fileName)!
                        let data: NSData = icon.pngData()! as NSData

                        response =  HttpResponse.raw(200, "OK", ["Content-Type":"image/png","Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"*"], {try $0.write(data)})
                    } else if last.firstIndex(of: String.SubSequence("pbf")) != nil {
                        print("pbf");
                        do {
                            let ssresponse = try fileName.openForReading()
                            response = HttpResponse.raw(200, "OK", ["Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"*"], { writer in
                                try? writer.write(ssresponse)
                                ssresponse.close()
                            })
                        } catch  {
                            response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                        }

                    } else {
                        response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                    }
                }else {
                    print("Not Exist");
                    response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                }
                return response;
            }


            if type == 3 || type == 4 || type == 5 {
                let hybridlayer=layerName.components(separatedBy: "@")
                let hLayerName=hybridlayer[0]
                let hTableName=hybridlayer[1]
                let gpk:GPKG = gl.gpkg_layers[hLayerName]!

                if type == 3 || type == 5 {
                    if type == 3 {
                        res=gpk.getTile(table: hTableName, level: zoom, col: xx, row: yy) as NSData
                    } else {
                        res = gpk.getFeatureTileRaster(table_name: hTableName, xxx: xx, y: yy, z: zoom) as NSData
                    }

                    if res != nil {
                        response = HttpResponse.raw(200, "OK", ["Content-Type":"image/png", "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"*"], {try $0.write(res!)})
                    }else{
                        response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                    }
                } else if type == 4 {
                    let fts = gpk.getFeatureTile(table_name: hTableName)
                    response = HttpResponse.raw(200, "OK", ["Access-Control-Allow-Origin": "*", "Content-Type":"application/json","Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"*"], { writer in
                        try? writer.write([UInt8](fts.utf8))
                    })
                }else {
                    response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                }


            } else {
                let mbTile:MBTiles = gl.layers[layerName]!
            
                yy = (1 << zoom) - 1 - yy
                
                res=mbTile.getTile(level:zoom, col:xx, row:yy)

                if res != nil {
                    if type == 1{
                        response = HttpResponse.raw(200, "OK", ["Content-Type":"image/png", "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers":"*", "Access-Control-Allow-Methods":"*"], {try $0.write(res!)})
                    } else if type == 2{
                        response = HttpResponse.raw(200, "OK", ["Content-Type":"application/x-protobuf","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*","Content-Encoding":"gzip"], {try $0.write(res!)})
                    } else {
                        response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                    }

                } else {
                    response = HttpResponse.raw(404, "Not Found", ["Content-Type":"application/x-protobuf","Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*","Content-Encoding":"gzip"], nil)
                }
            }
            return response
        }
        func start(p:in_port_t) -> String {
            do {
                try  gl.server!.start(p, forceIPv4: true)
                try port = "\( gl.server!.port())"
                gl.port = port
                print("os ready")
            }catch{
                port="error"
            }
            return port
        }
        for n:in_port_t in 8008...8080 {
            if !start(p:n).elementsEqual("error") {
                break
            }
        }
        print(port);

        return port
    }

}



class GPKG{
    var geoManager: GPKGGeoPackageManager
    var geoPackage: GPKGGeoPackage
    var tbl_srids:[String:Any]=[:]
    var tbl_paint_color:[String:UIColor]=[:]
    var tilesDB:OpaquePointer?
    var isOK=true
    init(fileName: String, manager: GPKGGeoPackageManager) {

        self.geoManager = manager
        let dbName:String = String( arc4random())+fileName.replacingOccurrences(of: "/", with: "_")

        self.geoManager.importGeoPackageAsLink(toPath: fileName, withName: dbName)

        self.geoPackage = self.geoManager.open(dbName);

        tbl_srids = [:]
        tbl_paint_color = [:]
        let cc1:GPKGResultSet = geoPackage.rawQuery("select table_name,srs_id from gpkg_contents", andArgs: nil)
        while cc1.moveToNext() {
            tbl_srids[cc1.string(with: 0)] = cc1.int(with: 1)
            tbl_paint_color[cc1.string(with: 0)] = randomColor()
        }
        cc1.close()
    }
    func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    func getAllMetaData() -> [String:Any] {
        var cursor = geoPackage.rawQuery("PRAGMA table_info(gpkg_contents)", andArgs: nil)!
        var columns = [String]();

        var tbl_index = 0;
        var jj = 0;
        while cursor.moveToNext() {
            if cursor.string(with: 1).elementsEqual("table_name") {
                tbl_index = jj;
            }
            columns.append(cursor.string(with: 1));
            jj += 1;
        }
        cursor.close();
        cursor = geoPackage.rawQuery("SELECT * FROM gpkg_contents", andArgs: nil)!
        var allTables:[String:Any]=[:]
        while cursor.moveToNext() {
            var metadata:[String:Any]=[:]
            for i in columns.indices {
                metadata[columns[i]] = cursor.string(with: Int32(i))
            }
            allTables[cursor.string(with: Int32(tbl_index))] = metadata;
        }
        return allTables
    }

    func getMetaData() throws -> [String] {
        var metadata = [String]()
        let features =  geoPackage.featureTables()!
        let tiles =  geoPackage.tileTables()!
        for i in features.indices {
            let strFtTbl = String(describing: features[i])
            let srid = tbl_srids[strFtTbl] as! Int
            if srid == 4326 || srid == 3857 {
                let ft =  geoPackage.featureDao(withTableName: strFtTbl)!
                print(ft)
                let bbox =  ft.boundingBox()!

                let bbstr = [bbox.minLongitude.description(withLocale: Locale.current), bbox.minLatitude.description(withLocale: Locale.current), bbox.maxLongitude.description(withLocale: Locale.current), bbox.maxLatitude.description(withLocale: Locale.current)].joined(separator: ",")
                let cursor = ft.queryForAll()!
                if cursor.count <= Int32(5000){
                    metadata.append(strFtTbl+":features:"+bbstr+":0")
                } else {
                    metadata.append(strFtTbl+": Cannot Handle Features > 5000.:0:0")
                }
                cursor.close()
            }
        }

        for i in tiles.indices {
            print(tiles[i] )
            guard let tileDao = geoPackage.tileDao(withTableName: tiles[i] ) else {
                return metadata
            }
            print("found")
            guard let bbox = tileDao.boundingBox() else {
                return metadata
            }

            let strFtTbl = String(describing: tiles[i])
            let srid = tbl_srids[strFtTbl] as! Int
            let bbstr = [bbox.minLongitude.description(withLocale: Locale.current), bbox.minLatitude.description(withLocale: Locale.current), bbox.maxLongitude.description(withLocale: Locale.current), bbox.maxLatitude.description(withLocale: Locale.current)].joined(separator: ",")
            if srid == 4326 || srid == 3857 {
                metadata.append(strFtTbl+":tiles:"+bbstr+":"+String(tileDao.maxZoom))
            }

        }
        return metadata
    }

    func  getTile(table:String, level: Int, col:Int, row:Int) -> Data {
        var tile:Data = Data.init()
        let tileDao = geoPackage.tileDao(withTableName: table)
        let packageTileRetriever = GPKGGeoPackageTileRetriever(tileDao: tileDao, andWidth: 256, andHeight: 256)!

        if packageTileRetriever.hasTileWith(x: col, andY: row, andZoom: level) {
            tile = packageTileRetriever.tileWith(x: col, andY: row, andZoom: level)!.data
        }
        return tile
    }

    func getFeatureTileRaster(table_name:String,  xxx:Int,  y:Int,  z:Int) -> Data{
        let featureDao = geoPackage.featureDao(withTableName: table_name)
        let featureTiles = GPKGFeatureTiles(featureDao: featureDao)!
        featureTiles.maxFeaturesPerTile = 1000
        featureTiles.fillPolygon = false
        featureTiles.lineColor = tbl_paint_color[table_name]
        featureTiles.lineStrokeWidth = 2
        featureTiles.polygonColor = tbl_paint_color[table_name]
        featureTiles.polygonStrokeWidth = 2
        featureTiles.pointColor = tbl_paint_color[table_name]
        let tile:Data? = featureTiles.drawTileDataWith(x: Int32(xxx), andY: Int32(y), andZoom: Int32(z))
        if tile == nil {
            return Data.init()
        } else {
            return tile!
        }
    }

    func getFeatureTile(table_name:String) -> String {
        let featureDao = geoPackage.featureDao(withTableName: table_name)!
        let tableName = featureDao.tableName!
        let featCol = featureDao.columnNames!
        let ftsrid = tbl_srids[tableName] as! Int
        let ftCollection:SFGFeatureCollection = SFGFeatureCollection()
        let cursor = featureDao.queryForAll()!
        do {
            while cursor.moveToNext() {

                let row: GPKGFeatureRow = featureDao.featureRow(cursor)
                var rowGeometry = row.geometry()!.geometry
                if (ftsrid == 3857){
                    let projection1 = SFPProjectionFactory.projection(withEpsg: 3857)
                    let projection2 = SFPProjectionFactory.projection(withEpsg: 4326)
                    let transforms = SFPProjectionTransform(from: projection1, andTo: projection2)!
                    rowGeometry = transforms.transform(with: rowGeometry)
                }

                let ft:SFGFeature = SFGFeature()

                    let ftjson:String = SFGFeatureConverter.simpleGeometry(toJSON: rowGeometry!)
                    ft.setGeometry(SFGFeatureConverter.json(toGeometry: ftjson)!)
                    var featureProp:[String:String] = [:]
                    for i in featCol.indices {
                        if (!featCol[i].elementsEqual("geom")) {
                            if let vals = row.value(withColumnName: featCol[i]) {
                                featureProp[featCol[i]] = vals.description
                            } else {
                                featureProp[featCol[i]] = ""
                            }
                        }
                    }
                    ft.setProperties(NSMutableDictionary(dictionary: featureProp))
                    ftCollection.addFeature(ft)
                
                /*}*/
            }
        
        }
        cursor.close()
        return SFGFeatureConverter.object(toJSON: ftCollection)!
        
    }
  
    
}
class MBTiles{
    var tilesDB:OpaquePointer?
    var isOK=true
    init(path: String) {
        let c:Int32 = sqlite3_open_v2(path, &tilesDB, SQLITE_OPEN_FULLMUTEX|SQLITE_OPEN_READONLY,nil);
        if  c != SQLITE_OK {
            isOK=false
        }
    }
    
    func getType() -> String {
        var v=""
        var stmt:OpaquePointer?
        let query = "SELECT value FROM metadata WHERE name = 'type'"
        sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil)
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            v = String(cString: sqlite3_column_text(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return v
    }
    
    func getFormat() -> String {
        var v=""
        var stmt:OpaquePointer?
        let query = "SELECT value FROM metadata WHERE name = 'format'"
        sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil)
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            v = String(cString: sqlite3_column_text(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return v
    }
    
    func getBoundsFromMetadata() -> [Double?] {
        var v:[Double?]=[]
        
        var stmt:OpaquePointer?
        let query = "SELECT value FROM metadata WHERE name = 'bounds'"
        sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil)
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let bbnds = String(cString: sqlite3_column_text(stmt, 0)).split(separator: ",")
            let vd0=Double(bbnds[0])
            let vd1=Double(bbnds[1])
            let vd2=Double(bbnds[2])
            let vd3=Double(bbnds[3])
            v=[vd0,vd1,vd2,vd3]
        }
        sqlite3_finalize(stmt)
        return v
    }
    
    
    
    func calculateBounds()->[Double?] {
        var bounds:[Double?] = []
        var stmt:OpaquePointer?
        let query = "SELECT MIN(tile_column), MAX(tile_column), MIN(tile_row), MAX(tile_row), zoom_level FROM tiles WHERE zoom_level = (SELECT MIN(zoom_level) FROM tiles)"
        
        sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil)
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let zoomLevel = Int(sqlite3_column_int(stmt, 4))
            let numRows = (1 << zoomLevel)
            let southwest = GeoUtils.init().tile2deg(x: Int(sqlite3_column_int(stmt, 0)), y: numRows-1-Int(sqlite3_column_int(stmt, 1)), z: zoomLevel)
            
            let northeast = GeoUtils.init().tile2deg(x: Int(sqlite3_column_int(stmt, 2)), y: numRows-1-Int(sqlite3_column_int(stmt, 3)), z: zoomLevel)
            bounds=[southwest[0], southwest[1], northeast[0], northeast[1]]
            
        }
        sqlite3_finalize(stmt)
        return bounds
    }
    
    func getBounds()->[Double?] {
        var bounds:[Double?]=[]
        
        bounds = getBoundsFromMetadata()
        if (bounds.count==0) {
            bounds = calculateBounds()
        }
        return bounds
    }
    
    
    func  getTile(level: Int, col:Int, row:Int) -> NSData? {
        var stmt:OpaquePointer?
        var tile:NSData? = nil
        let query = "SELECT tile_data FROM tiles WHERE zoom_level = "+String(level)+" AND tile_column = "+String(col)+" AND tile_row = "+String(row)
        if sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil) == SQLITE_OK {
            if(sqlite3_step(stmt) == SQLITE_ROW){
                let tiles:UnsafeRawPointer = sqlite3_column_blob(stmt,0)
                let tiles_size = sqlite3_column_bytes(stmt,0)
                //tile = [UInt8](Data(bytes: tiles, count: Int(tiles_size)))
                
                tile = NSData(bytes: tiles, length: Int(tiles_size))
                
            }
        }
        sqlite3_finalize(stmt)
        return tile
    }
    
    
    
    func getMaxZoom()-> Int {
        var v=0;
        var stmt:OpaquePointer?
        let query = "SELECT MAX(zoom_level) as zoom FROM tiles"
        sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil)
        while(sqlite3_step(stmt) == SQLITE_ROW){
            v = Int(sqlite3_column_int(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return v
        
    }
    
    func getCenter() -> String {
        var metadata="0,0,0";
        var stmt:OpaquePointer?
        let query = "select value from metadata where name='center'"
        sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil)
        while(sqlite3_step(stmt) == SQLITE_ROW){
            metadata = String(cString:sqlite3_column_text(stmt, 0))
        }
        sqlite3_finalize(stmt)
        return metadata
    }
    func getAllMetaData() -> [String:Any] {
        var jsonObject:[String:Any]=[:]
        var stmt:OpaquePointer?
        let query = "SELECT * FROM metadata"
        sqlite3_prepare_v2(tilesDB, query, -1, &stmt, nil)
        while(sqlite3_step(stmt) == SQLITE_ROW){
            jsonObject[String(cString:sqlite3_column_text(stmt, 0))] = String(cString:sqlite3_column_text(stmt, 1))
        }
        sqlite3_finalize(stmt)
        return jsonObject
    }
    
}

class GeoUtils {
    func tile2deg(x:Int, y: Int, z:Int) -> [Double?] {
        let coords:[Double] = [tile2lon(x: x, z: z), tile2lat(y: y, z: z)]
        return coords
    }
    
    func tile2lon(x: Int, z:Int) -> Double {
        return Double(x) / pow(Double(z), 2) * 360.0 - 180
    }
    
    
    func tile2lat(y: Int, z:Int) -> Double {
        let n = Double.pi - (2.0 * Double.pi * Double(y)) / pow(Double(z), 2.0)
        return radiansToDegrees(radians:atan(sinh(n)))
    }
    func radiansToDegrees (radians: Double)->Double {
        return radians * 180 / Double.pi
    }
    
    
}

