import UIKit
import Flutter
import flutter_downloader
import Foundation
import Swifter
import SQLite3
import MobileCoreServices
import SwiftyJSON

struct gl {
    static var fileMng = ""
    static var layers:[String:MBTiles] = [:]
    static var gpkg_layers:[String:GPKG] = [:]
    static var geoJson_layers:[String:[String: String]] = [:]
    static var isServerLive:Bool = false
    static var port:String = "-1"
    static var manager:GPKGGeoPackageManager = GPKGGeoPackageManager();
    static var server:HttpServer? = nil;
    static var appWWWDir = Bundle.main.bundleURL
    static var alert = UIAlertController(title: "", message: "Loading Data...", preferredStyle: .alert)
    static var isAlertInit = false
    static var typesDic = [
        "zip":["tmg.geoint.explorer.shp"],
        "geojson":["tmg.geoint.explorer.geojson","tmg.geoint.explorer.json","public.json"],
        "gpkg":["tmg.geoint.explorer.gpkg"],
        "mbtiles":["tmg.geoint.explorer.mbtiles"],
        "json":["tmg.geoint.explorer.geojson","tmg.geoint.explorer.json","public.json"],
        "csv":["public.comma-separated-values-text"],
        "kml":["tmg.geoint.explorer.kml"],
        "jpg":["public.jpeg","public.png"]
    ]
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
        binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
        print(call.method)
        if call.method == "addGpkg" {
            if let args = call.arguments as? [String: Any] {
                if let path = args["path"] as? String,
                   let key = args["key"] as? String,
                   let name = args["name"] as? String {
                    result(self?.addGpkgTiles(path: path, key: key, name: name))
                } else {
                    result(FlutterMethodNotImplemented)
                    return
                }

            } else {
                result(FlutterMethodNotImplemented)
                return
            }

        } else if call.method == "addTiles" {
            if let args = call.arguments as? [String: Any]{
                if let path = args["path"] as? String,
                   let key = args["key"] as? String,
                   let name = args["fileName"] as? String {
                    result(self?.addTiles(layerName: key, fileName: path, name: name))
                } else {
                    result(FlutterMethodNotImplemented)
                    return
                }

            } else {
                result(FlutterMethodNotImplemented)
                return
            }
        } else if call.method == "addGeoJson" {
            if let args = call.arguments as? [String: Any]{
                print(args.keys)
                if let path = args["path"] as? String,
                   let key = args["key"] as? String,
                   let name = args["fileName"] as? String {
                    result(self?.addGeoJson(path: path, key: key, fileName: name))
                } else {
                    result(FlutterMethodNotImplemented)
                    return
                }

            } else {
                result(FlutterMethodNotImplemented)
                return
            }
        } else {
            result(FlutterMethodNotImplemented)
            return
        }
//      self?.receiveBatteryLevel(result: result)
    })

    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    let port = startServer()
    print(port)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    private func receiveBatteryLevel(result: FlutterResult) {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Battery info unavailable",
                            details: nil))
      } else {
        result(Int(device.batteryLevel * 100))
      }
    }

    func addGeoJson(path: String, key: String, fileName: String) -> String {
        var data: String = "{}"
        do {
            let dataJson = try String(contentsOfFile: path, encoding: .utf8)
            var geojson: [String: String] = [:]
            if dataJson.count > 0 {
                geojson["path"] = path
                geojson["port"] = gl.port
                geojson["result"] = dataJson

                gl.geoJson_layers[key] = geojson
            }

            let dataBinary: Data = try JSONSerialization.data(withJSONObject: geojson, options: .prettyPrinted)
            data = String(data: dataBinary, encoding: .utf8)!

        } catch {

        }


        return data
    }

    func addTiles(layerName: String, fileName: String, name: String) -> String {

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

            return jsonObject.description
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
        jsonObject["key"] = layerName
        jsonObject["port"] = gl.port

        var boundsJSON:[Double] = []
        for i in 0..<bounds.count {
            boundsJSON.append(bounds[i] ?? 0)
        }
        jsonObject["bounds"] = boundsJSON;
        var data: String = "{}"
        do {
            let dataBinary: Data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            data = String(data: dataBinary, encoding: .utf8)!
        } catch {

        }

        return data

    }

    func addGpkgTiles(path: String, key: String, name: String) -> String {
        var jsonObject:[String:Any]=[:]
        do {
            let nGpkg=GPKG.init(fileName: path, manager: gl.manager)
            let type = try nGpkg.getMetaData()
            print("type")
            jsonObject["info"] = nGpkg.getAllMetaData()
            jsonObject["port"] = gl.port
            jsonObject["key"] = key
             print("info")
            gl.gpkg_layers[key]=nGpkg

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

        }catch {
            print("eee")
        }
        var data: String = "{}"
        do {
            let dataBinary: Data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            data = String(data: dataBinary, encoding: .utf8)!
        } catch {

        }

        return data

    }

    func startServer() -> String {
        do {
                    if let bundlePath = Bundle.main.path(forResource: "mapbox_style",
                                                         ofType: "json"),
                        let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                        let json = try JSON(data: jsonData)
                        let name = json["version"].stringValue
                        print(name)
                    }
                } catch {
                    print(error)
                }
            var port="8008"
            gl.server = HttpServer()
            gl.server!["/getTilesJson-layer/:type/:key/:format"] = {request in
                var response: HttpResponse
                response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)

                return response
            }
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
                if resr.contains("getGeoJson"){
                    let uriParts = resr.components(separatedBy: "/")
                    print(uriParts)
                    let id = uriParts[1]
                    let key = uriParts[2]
                    if let geojson = gl.geoJson_layers[key] {
                        let path = geojson["path"] as! String
                        do {
                            let fileData = Data(try NSData(contentsOfFile: path))
                            response = HttpResponse.raw(200, "OK", ["Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers":"*"], { writer in
                                try? writer.write(fileData)
                            })
                        } catch {
                            response = HttpResponse.raw(404, "Not Found", ["Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"*","Access-Control-Allow-Methods":"*"], nil)
                        }


                    } else {
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

        self.geoManager.importGeoPackage(fromPath: fileName, withName: dbName)
print(dbName)
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
            let vd0=Double(bbnds[0].trimmingCharacters(in: .whitespacesAndNewlines))!
            let vd1=Double(bbnds[1].trimmingCharacters(in: .whitespacesAndNewlines))!
            let vd2=Double(bbnds[2].trimmingCharacters(in: .whitespacesAndNewlines))!
            let vd3=Double(bbnds[3].trimmingCharacters(in: .whitespacesAndNewlines))!
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
        } else if (bounds[0] == nil){
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

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}


