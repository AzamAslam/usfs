package com.techmaven.USFS;

import androidx.annotation.NonNull;

import fi.iki.elonen.NanoHTTPD;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import mil.nga.geopackage.GeoPackageFactory;
import mil.nga.geopackage.GeoPackageManager;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.codesnippets4all.json.parsers.JSONParser;
import com.codesnippets4all.json.parsers.JsonParserFactory;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/battery";

    String name;

    private static final String TAG = "HTTPMBTiles";
    private HTTPServer httpServer;
    private final Pattern tilePattern = Pattern.compile("/(.*?)/(.*?)/([0-9]+)/([0-9]+)/([0-9]+)\\.");
    private final Pattern tileJsonPattern = Pattern.compile("/(.*?)/(.*?)/(.*?)/(.*?)\\.");
    // 0/your_key/0/0/0.pbf
    // http://localhost:8080/0/your_key/0/0/0.pbf
    private HashMap<String, JSONObject> geoJsonLayers;
    private HashMap<String, MBTiles> layers;
    private HashMap<String, GPKG> gpkg_layers;
    private GeoPackageManager manager;
    private int port;

    private static Context context;

    public static Context getAppContext() {
        return MainActivity.context;
    }

    public static Map<String, Object> jsonToMap(JSONObject json) throws JSONException {
        Map<String, Object> retMap = new HashMap<String, Object>();

        if(json != JSONObject.NULL) {
            retMap = toMap(json);
        }
        return retMap;
    }

    public static Map<String, Object> toMap(JSONObject object) throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();

        Iterator<String> keysItr = object.keys();
        while(keysItr.hasNext()) {
            String key = keysItr.next();
            Object value = object.get(key);

            if(value instanceof JSONArray) {
                value = toList((JSONArray) value);
            }

            else if(value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            map.put(key, value);
        }
        return map;
    }

    public static List<Object> toList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<Object>();
        for(int i = 0; i < array.length(); i++) {
            Object value = array.get(i);
            if(value instanceof JSONArray) {
                value = toList((JSONArray) value);
            }

            else if(value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            list.add(value);
        }
        return list;
    }

    @Override
    public void onCreate(Bundle bundle){
        super.onCreate(bundle);
        context = getApplicationContext();
        manager = GeoPackageFactory.getManager(MainActivity.getAppContext());
        layers = new HashMap<String, MBTiles>();
        gpkg_layers = new HashMap<String, GPKG>();
        geoJsonLayers = new HashMap<String, JSONObject>();


        httpServer = new HTTPServer(0);

        try {
            httpServer.start();
            port = httpServer.getListeningPort();

        }catch(Exception ex){
            port = -1;
        }
    }

    public String LoadData(String inFile) {
        String tContents = "";

        try {
            InputStream stream = getAssets().open(inFile);

            int size = stream.available();
            byte[] buffer = new byte[size];
            stream.read(buffer);
            stream.close();
            tContents = new String(buffer);
        } catch (IOException e) {
            Log.e("Error Json", e.getLocalizedMessage());
        }
        return tContents;
    }

    public String LoadExternalFile(String inFile) {
        String result = "";
        File file = new File(inFile);

        StringBuilder text = new StringBuilder();

        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line;

            while ((line = br.readLine()) != null) {
                text.append(line);
                text.append('\n');
            }
            result = text.toString();
            br.close();
        }
        catch (IOException e) {
            Log.e("errorLoadFIle", e.getLocalizedMessage());
        }
        return result;
    }

    class HTTPServer extends NanoHTTPD {

        public HTTPServer(int port) {
            super(port);
        }

        @Override public Response serve(IHTTPSession session) {
            NanoHTTPD.Response response;
            String uri = session.getUri();

            Log.e("uri", uri);

//            Matcher jsonMatcher = tileJsonPattern.matcher(uri);

            if(uri.contains("getGeoJson")){

                String[] uriParts = uri.split("/");
                String id = uriParts[1];
                String key = uriParts[2];

                JSONObject geoJson = geoJsonLayers.get(key);

                if(geoJson!=null){
                    String result = null;
                    try {
                        result = geoJson.getString("result");
                        response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, NanoHTTPD.MIME_PLAINTEXT, result);
                    } catch (JSONException e) {
                        response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Not found");
                        Log.e("geoJsonError", e.getMessage());
                    }

                }
                else{
                    response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Not found");
                }
                response.addHeader("Access-Control-Allow-Origin", "*");
                response.addHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
                return response;
            }

            if(uri.contains("getNavigationStyle")){
                String style =  LoadData("navigation.json");

                //http://localhost:"+port+"/"+'getNavigationStyle';

                Log.e("json style", style);

//                String tileUrl = "http://localhost:"+port+"/"+type+"/"+key+"/{z}/{x}/{y}."+format;
                String tileUrl = "http://localhost:"+port+"/2/navigation.mbtiles/{z}/{x}/{y}.pbf";
                style = style.replace("put-your-url", tileUrl);

                response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, NanoHTTPD.MIME_PLAINTEXT, style);
                response.addHeader("Access-Control-Allow-Origin", "*");
                response.addHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");

                return response;
            }

            if(uri.contains("getTilesJson")){

                String[] uriParts = uri.split("/");
                String id = uriParts[1];
                String type = uriParts[2];
                String key = uriParts[3];
                String format = uriParts[4];

                if(uri.contains("layer")){
                    MBTiles mbTiles = layers.get(key);
                    JSONObject allmetadata = mbTiles.getAllMetaData();
//                    "sources": {
//                        "esri": {
//                            "type": "vector",
//                                    "tiles": ["put-your-url"]
//                        }
//                    },

                    try {
                        JSONObject sources = new JSONObject();
                        JSONObject esriSource = new JSONObject();
                        esriSource.put("type", "vector");
                        esriSource.put("minzoom", allmetadata.getString("minzoom"));
                        esriSource.put("maxzoom", allmetadata.getString("maxzoom"));
                        JSONArray tileUrls = new JSONArray();
                        tileUrls.put("http://localhost:"+port+"/"+type+"/"+key+"/{z}/{x}/{y}."+format);
                        esriSource.put("tiles", tileUrls);
                        sources.put("esri", esriSource);

                        String json = allmetadata.getString("json");

                        JSONObject jsonObject = new JSONObject(json);

                        JSONArray vectorLayers = jsonObject.getJSONArray("vector_layers");

                        JSONArray newlayers = new JSONArray();
                        String mapboxStyle =  LoadData("mapbox_style.json");

//                        mapboxStyle = mapboxStyle.replace("put-your-url", tileUrl);
                        JSONObject style = new JSONObject(mapboxStyle);
                        style.put("sources", sources);
                        for (int i = 0; i < vectorLayers.length(); i++) {
                            JSONObject layer = vectorLayers.getJSONObject(i);
                            String idd = layer.getString("id");
                            JSONObject lineType = new JSONObject();
                            lineType.put("id", idd+"-line");
                            lineType.put("type", "line");
                            lineType.put("source", "esri");
                            lineType.put("source-layer", idd);
                            JSONObject linePaint = new JSONObject();
                            linePaint.put("line-color", "red");
                            linePaint.put("line-width", 1.5);
                            lineType.put("paint", linePaint);
                            newlayers.put(0, lineType);

                            JSONObject fillType = new JSONObject();
                            fillType.put("id", idd+"-fill");
                            fillType.put("type", "fill");
                            fillType.put("source", "esri");
                            fillType.put("source-layer", idd);
                            JSONObject fillPaint = new JSONObject();
                            fillPaint.put("fill-color", "red");
                            fillPaint.put("fill-opacity", 0.6);
                            fillType.put("paint", fillPaint);
                            newlayers.put(1, fillType);

                            JSONObject pointType = new JSONObject();
                            pointType.put("id", idd+"-point");
                            pointType.put("type", "circle");
                            pointType.put("source", "esri");
                            pointType.put("source-layer", idd);
                            JSONObject pointPaint = new JSONObject();
                            pointPaint.put("circle-color", "red");
                            pointPaint.put("circle-radius", 5);
                            pointType.put("paint", pointPaint);
                            newlayers.put(2, pointType);
                        }
                        style.put("layers", newlayers);

                        response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, NanoHTTPD.MIME_PLAINTEXT, style.toString());
                        response.addHeader("Access-Control-Allow-Origin", "*");
                        response.addHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");

                        return response;

                    } catch (JSONException e) {
                        Log.e("mapbox error", e.getMessage());
                        return newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Not found");
                    }

                }
                else{
                    String style =  LoadData("style.json");

                    Log.e("json style", style);

                    String tileUrl = "http://localhost:"+port+"/"+type+"/"+key+"/{z}/{x}/{y}."+format;
                    style = style.replace("put-your-url", tileUrl);

                    response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, NanoHTTPD.MIME_PLAINTEXT, style);
                    response.addHeader("Access-Control-Allow-Origin", "*");
                    response.addHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");

                    return response;
                }


//                try {
////                    JSONObject obj = new JSONObject(style);
////                    JSONObject source = obj.getJSONObject("sources");
////                    JSONObject esri = source.getJSONObject("esri");
////                    JSONArray tiles = esri.getJSONArray("tiles");
////                    tiles.getString(0);
//
////                    Log.e("style", obj.getString("sprite"));
//                }catch (JSONException e){
//                    Log.e("errorJson", e.getMessage());
//                }
            }

            Matcher matcher = tilePattern.matcher(uri);
            if(!matcher.find()) {
                response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Not found");
            } else {
                // http://localhost:8080/0/your_key/0/0/0.pbf
                // type 3 == geopackage raster tile
                // type 4 == geopackage feature
                // type 5 == geopackage feature to raster tile
                // else mbtiles type 1 == raster tiles
                // else mbtiles type 2 == vector tiles
                int type=Integer.parseInt(matcher.group(1));
                String layerName = matcher.group(2);
                int z = Integer.parseInt(matcher.group(3));
                int x = Integer.parseInt(matcher.group(4));
                int y = Integer.parseInt(matcher.group(5));
                if (type==3){
                    String hybridLayer[]=layerName.split("@");
                    String layer_name=hybridLayer[0];
                    String table_name=hybridLayer[1];
                    GPKG gpkg=gpkg_layers.get(layer_name);
                    if (gpkg != null) {
                        Log.e("gpkg found", "yes");
                        try {
                            byte[] tile = gpkg.getTile(table_name,z, x, y);
                            if (tile != null) {
                                Log.e("tile found", "yes");
                                response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, "image/png", new ByteArrayInputStream(tile),tile.length);

                            } else {
                                response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Tile not found");
                            }
                        } catch(Exception ex) {
                            Log.e("new",ex.toString());
                            response = newFixedLengthResponse(NanoHTTPD.Response.Status.INTERNAL_ERROR, NanoHTTPD.MIME_PLAINTEXT, ex.toString());
                        }
                    }else {
                        response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Layer not found");
                    }

                    response.addHeader("Access-Control-Allow-Origin", "*");
                    response.addHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");

                }else if (type==4){
                    String hybridLayer[]=layerName.split("@");
                    String layer_name=hybridLayer[0];
                    String table_name=hybridLayer[1];
                    GPKG gpkg=gpkg_layers.get(layer_name);
                    try {
                        String tile = gpkg.getFeatureTile(table_name);

                        if (tile != null) {
                            response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, NanoHTTPD.MIME_PLAINTEXT, tile);
                            response.addHeader("Access-Control-Allow-Origin", "*");
                            response.addHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
                        } else {
                            response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Tile not found");
                        }
                    } catch (Exception ex) {
                        response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Tile not found");
                    }

                }else if (type==5){
                    String hybridLayer[]=layerName.split("@");
                    String layer_name=hybridLayer[0];
                    String table_name=hybridLayer[1];
                    GPKG gpkg=gpkg_layers.get(layer_name);
                    try {
                        byte[] tile = gpkg.getFeatureTileRaster(table_name, x, y, z);
                        if (tile != null) {
                            response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, "image/png", new ByteArrayInputStream(tile),tile.length);
                        } else {
                            response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Tile not found");
                        }
                    }catch (Exception ex){
                        response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Tile not found");
                    }


                }else {
                    MBTiles mbTiles = layers.get(layerName);
                    if (mbTiles != null) {
                        try {
                            y = (1 << z) - 1 - y;
                            Log.e("check", ""+z+x+y);
                            byte[] tile = mbTiles.getTile(z, x, y);
                            if (tile != null) {
                                if (type==1){

                                    Log.e("tile found", "Yes");
                                    response = newFixedLengthResponse(NanoHTTPD.Response.Status.OK, "image/png", new ByteArrayInputStream(tile),tile.length);
                                    response.addHeader("Access-Control-Allow-Origin","*");
                                    response.addHeader("Access-Control-Allow-Headers","Origin, X-Requested-With, Content-Type, Accept");
                                }else if (type==2){
                                    response=newFixedLengthResponse(NanoHTTPD.Response.Status.OK, "application/x-protobuf",new ByteArrayInputStream(tile),tile.length);

                                    response.addHeader("Access-Control-Allow-Origin","*");
                                    response.addHeader("Access-Control-Allow-Headers","Origin, X-Requested-With, Content-Type, Accept");
                                    response.addHeader("Content-Type","application/x-protobuf");
                                    response.addHeader("Content-Encoding","gzip");

                                }else {
                                    response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Tile not found");
                                }

                            } else {

                                response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, "application/x-protobuf", "Tile not found");
                                if (type==2){
                                    response=newFixedLengthResponse(NanoHTTPD.Response.Status.OK, "application/x-protobuf","");
                                    response.addHeader("Access-Control-Allow-Origin","*");
                                    response.addHeader("Access-Control-Allow-Headers","Origin, X-Requested-With, Content-Type, Accept");
                                    response.addHeader("Content-Type","application/x-protobuf");
                                    response.addHeader("Content-Encoding","gzip");
                                }
                            }
                        } catch(Exception ex) {
                            response = newFixedLengthResponse(NanoHTTPD.Response.Status.INTERNAL_ERROR, NanoHTTPD.MIME_PLAINTEXT, ex.toString());
                        }
                    } else {
                        response = newFixedLengthResponse(NanoHTTPD.Response.Status.NOT_FOUND, NanoHTTPD.MIME_PLAINTEXT, "Layer not found");
                    }
                }
            }
            return response;
        }
    }

    void setName(String name){
        this.name = name;
    }

    String getName(){
        return this.name;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        flutterEngine
                .getPlatformViewsController()
                .getRegistry()
                .registerViewFactory("<platform-view-type>", new NativeViewFactory());
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();

                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            }
                            else if (call.method.equals("addGeoJson")) {
                                Log.e("path", call.argument("path"));
                                Log.e("key", call.argument("key"));

                                JSONObject json = addGeoJson(call.argument("key"), call.argument("path"), call.argument("name"));
                                Log.e("geoJsonResult", json.toString());

                                result.success(json.toString());

                            }
                            else if (call.method.equals("addTiles")) {
                                Log.e("addTiles", "addTiles");
                                Log.e("path", call.argument("path"));
                                Log.e("key", call.argument("key"));

                                setName(call.argument("fileName"));

                                JSONObject json = addTiles(call.argument("key"), call.argument("path"), call.argument("fileName"));
                                Log.e("mbtileJson", json.toString());

                                result.success(json.toString());

                            }
                            else if (call.method.equals("addGpkg")) {
                                Log.e("asasas", "asass");
                                Log.e("asasa",call.argument("path"));
                                Log.e("asasas",call.argument("key"));

                                JSONObject json = addGeoPackage(call.argument("path"), call.argument("key"), call.argument("name"));

//                                JsonParserFactory factory=JsonParserFactory.getInstance();
//                                JSONParser parser=factory.newJsonParser();
//                                Map<String, Object> jsonMap = parser.parseJson(json.toString());
//                                Log.e("map", jsonMap.toString());

                                result.success(json.toString());
                            }
                            else {
                                result.notImplemented();
                            }
                        }
                );
    }

    public JSONObject addGeoJson(String key, String path, String name){
        String data = LoadExternalFile(path);
        JSONObject geoJson = new JSONObject();
        if( data.length() > 0 ){
            try{
                geoJson.put("path", path);
                geoJson.put("port", port);
                geoJson.put("result", data);

                geoJsonLayers.put(key, geoJson);

            }catch(Exception ex) {
                Log.e("geojson", ex.getLocalizedMessage());
            }
        }

        return geoJson;
    }

    public JSONObject addTiles(String layerName, String fileName, String name) {
        try {
            JSONObject jsonObject=new JSONObject();
            File file=new File(fileName);
            if (file.length()==0){
                jsonObject.put("error", "Null File");
                return jsonObject;
            }
            MBTiles mbTiles = new MBTiles(fileName);
            double[] bounds=mbTiles.getBounds();
            String center= mbTiles.getCenter();
            String type=mbTiles.getType();
            String format=mbTiles.getFormat();
            int mzZoom=mbTiles.getMaxZoom();
            layers.put(layerName, mbTiles);

            jsonObject.put("error", 0);
            jsonObject.put("type",type);
            jsonObject.put("format",format);
            jsonObject.put("maxZoom",mzZoom);
            jsonObject.put("center",center);
            jsonObject.put("allInfo",mbTiles.getAllMetaData());
            jsonObject.put("key", layerName);
            jsonObject.put("port", port);


            if (bounds != null) {
                JSONArray boundsJSON = new JSONArray();
                for (int i = 0; i < bounds.length; i++) {
                    boundsJSON.put(bounds[i]);
                }
                jsonObject.put("bounds", boundsJSON);
            }

            return jsonObject;


        } catch(Exception ex) {
            JSONObject jsonObject=new JSONObject();
            Log.e("mbtile",ex.getLocalizedMessage());

            try {
                jsonObject.put("error", ex.getMessage());
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return jsonObject;
        }
    }

    private JSONObject addGeoPackage(String path, String key, String name){
        try {
            JSONObject jsonObject=new JSONObject();
            GPKG gpkg = new GPKG(path, manager);
            List<String> type=gpkg.getMetaData();
            jsonObject.put("info",gpkg.getAllMetaData());
            jsonObject.put("port",port);
            jsonObject.put("key", key);
            gpkg_layers.put(key, gpkg);

            JSONArray jsonArray=new JSONArray();
            JSONArray errorsArray=new JSONArray();
            for (int i=0;i<type.size();i++){
                String row[]=type.get(i).split(":");
                if (row.length>2){
                    JSONObject js=new JSONObject();
                    js.put("name",row[0]);
                    js.put("type",row[1]);
                    js.put("bounds",row[2]);
                    js.put("maxZoom",row[3]);
                    jsonArray.put(js);
                } else {
                    errorsArray.put(type.get(i));
                }
            }
            if (type.size()>0 && errorsArray.length()>0){
                jsonObject.put("error", 1);
            } else if (type.size()==0){
                jsonObject.put("error", 1);
                errorsArray.put("No Tables Found With SRIDS 4326,3857");
            } else {
                jsonObject.put("error", 0);
            }
            jsonObject.put("detail",jsonArray);
            jsonObject.put("msg",errorsArray);

            return jsonObject;
        } catch(Exception ex) {
            JSONObject jsonObject=new JSONObject();
            JSONArray errorsArray=new JSONArray();
            try {
                jsonObject.put("error", 2);
                errorsArray.put(ex.toString());
                jsonObject.put("msg", errorsArray);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return jsonObject;
        }
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }
        return batteryLevel;
    }

}
