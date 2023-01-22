package com.techmaven.USFS;

import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Log;

import mil.nga.geopackage.features.index.FeatureIndexManager;
import mil.nga.geopackage.features.index.FeatureIndexResults;
import mil.nga.geopackage.tiles.TileGrid;
import mil.nga.geopackage.tiles.retriever.GeoPackageTile;
import mil.nga.geopackage.tiles.retriever.GeoPackageTileRetriever;
import mil.nga.geopackage.tiles.user.TileCursor;
import mil.nga.geopackage.tiles.user.TileRow;
import com.techmaven.USFS.MainActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

import mil.nga.geopackage.BoundingBox;
import mil.nga.geopackage.GeoPackage;
import mil.nga.geopackage.GeoPackageManager;
import mil.nga.geopackage.features.user.FeatureCursor;
import mil.nga.geopackage.features.user.FeatureDao;
import mil.nga.geopackage.features.user.FeatureRow;
import mil.nga.geopackage.geom.GeoPackageGeometryData;
import mil.nga.geopackage.tiles.TileBoundingBoxUtils;
import mil.nga.geopackage.tiles.features.DefaultFeatureTiles;
import mil.nga.geopackage.tiles.features.FeatureTiles;
import mil.nga.geopackage.tiles.user.TileDao;
import mil.nga.sf.Geometry;
import mil.nga.sf.GeometryEnvelope;
import mil.nga.sf.geojson.FeatureConverter;
import mil.nga.sf.proj.Projection;
import mil.nga.sf.proj.ProjectionConstants;
import mil.nga.sf.proj.ProjectionFactory;
import mil.nga.sf.proj.ProjectionTransform;
import mil.nga.sf.util.GeometryEnvelopeBuilder;

public class GPKG {
    private GeoPackage geoPackage;
    private GeoPackageManager geoManager;
    private HashMap<String, Integer> tbl_srids;
    private HashMap<String, Integer> tbl_paint_color;
    public GPKG(String fileName, GeoPackageManager manager) throws Exception {
        geoManager = manager;
        Random rand = new Random();
        String dbName = rand.nextInt()+fileName.replaceAll("/","_");
        if(new File(fileName).exists()){
            Log.e("exist", "exist");
        }
        else {
            Log.e("not exist", "not exist");
        }
        geoManager.importGeoPackageAsExternalLink(new File(fileName),dbName);
        geoPackage = geoManager.open(dbName,false);
        tbl_srids = new HashMap<String, Integer>();
        tbl_paint_color = new HashMap<String, Integer>();
        Cursor cc1 = geoPackage.rawQuery("select table_name,srs_id from gpkg_contents",null);

        while (cc1.moveToNext()){
            tbl_srids.put(cc1.getString(0),cc1.getInt(1));
            int r = rand.nextInt(), g = rand.nextInt(), b = rand.nextInt();
            if (r>255){r=0;}if (g>255){g=0;}if (b>255){b=0;}
            tbl_paint_color.put(cc1.getString(0),darker(Color.rgb(r,g,b),5));
        }
        cc1.close();
    }
    public static int darker (int color, float factor) {
        int a = Color.alpha( color );
        int r = Color.red( color );
        int g = Color.green( color );
        int b = Color.blue( color );

        return Color.argb( a,
                Math.max( (int)(r * factor), 0 ),
                Math.max( (int)(g * factor), 0 ),
                Math.max( (int)(b * factor), 0 ) );
    }
    public JSONObject getAllMetaData(){
        Cursor cursor = geoPackage.getConnection().rawQuery("PRAGMA table_info(gpkg_contents)",null);
        ArrayList<String> columns = new ArrayList<>();
        int tbl_index = 0;
        int jj = 0;
        while (cursor.moveToNext()){
            if (cursor.getString(1).equalsIgnoreCase("table_name")){
                tbl_index = jj;
            }
            columns.add(cursor.getString(1));
            jj++;
        }
        cursor.close();
        cursor = geoPackage.getConnection().rawQuery("SELECT * FROM gpkg_contents",null);
        JSONObject allTables = new JSONObject();
        try {
            while (cursor.moveToNext()) {
                JSONObject metadata = new JSONObject();
                for (int i = 0; i < columns.size(); i++) {
                    metadata.put(columns.get(i), cursor.getString(i));
                }
                allTables.put(cursor.getString(tbl_index), metadata);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return allTables;
    }
    public List<String> getMetaData() {
        List<String> metadata=new ArrayList<>();
        List<String> features = geoPackage.getFeatureTables();
        List<String> tiles = geoPackage.getTileTables();

        for (int i = 0; i < features.size(); i++) {
            BoundingBox bbox = null;
            int srid = tbl_srids.get(features.get(i));
            if (srid == 4326 || srid == 3857) {
                FeatureDao ft = geoPackage.getFeatureDao(features.get(i));
                bbox = ft.getBoundingBox();
                FeatureCursor cursor = ft.queryForAll();
                if (cursor.getCount()<=5000){
                    metadata.add(
                            features.get(i)+":"+
                                    "features"+":"+
                                    bbox.getMinLongitude()+","+
                                    bbox.getMinLatitude()+","+
                                    bbox.getMaxLongitude()+","+
                                    bbox.getMaxLatitude()+":"+
                                    0
                    );
                } else {
                    metadata.add(
                            features.get(i)+": Cannot Handle Features > 5000."
                    );
                }
                cursor.close();
            }

        }
        for (int i = 0; i < tiles.size(); i++) {
            TileDao tileDao = geoPackage.getTileDao(tiles.get(i));
            BoundingBox bbox = tileDao.getBoundingBox();
            int srid = tbl_srids.get(tiles.get(i));

            if (srid == 4326 || srid == 3857) {
                metadata.add(
                        tiles.get(i)+":"+
                                "tiles"+":"+
                                bbox.getMinLongitude()+","+
                                bbox.getMinLatitude()+","+
                                bbox.getMaxLongitude()+","+
                                bbox.getMaxLatitude()+":"+
                                tileDao.getMaxZoom()
                );
            }

        }

        return metadata;
    }

    public byte[] getTile(String table,int level, int col, int row) {
        /*Log.e("gp",geoPackage.getTileDao(table).qu);*/
        byte[] tile = null;
        TileDao tileDao = geoPackage.getTileDao(table);
        GeoPackageTileRetriever packageTileRetriever = new GeoPackageTileRetriever(tileDao,256,256);
        GeoPackageTile geoPackageTile= packageTileRetriever.getTile(col,row,level);
        if (geoPackageTile!=null){
            Log.e("tile","ok");
            tile = geoPackageTile.getData();
        }else {Log.e("tile","ERROR:"+col+","+row+","+level);}

        return tile;
    }

    public byte[] getFeatureTileRaster(String table_name, int x, int y, int z){
        FeatureDao featureDao = geoPackage.getFeatureDao(table_name);
        FeatureTiles featureTiles = new DefaultFeatureTiles(MainActivity.getAppContext(), featureDao);
        featureTiles.setMaxFeaturesPerTile(1000); // Set max features to draw per tile
        featureTiles.setFillPolygon(false);
        Paint tileOutlinePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        tileOutlinePaint.setColor(tbl_paint_color.get(table_name));
        tileOutlinePaint.setStrokeWidth(2);
        tileOutlinePaint.setStyle(Paint.Style.STROKE);
        featureTiles.setLinePaint(tileOutlinePaint);
        featureTiles.setPointPaint(tileOutlinePaint);
        featureTiles.setPolygonPaint(tileOutlinePaint);
        return featureTiles.drawTileBytes(x, y, z);
    }

    public String getFeatureTile(String table_name) {
        FeatureDao featureDao = geoPackage.getFeatureDao(table_name);
        String tableName = featureDao.getTableName();
        FeatureCursor cursors = featureDao.queryForAll();
        int numberOfRows = cursors.getCount();
        String order = null;
        if (cursors.getColumnIndex("id") != -1) {
            order = "id";
        } else if (cursors.getColumnIndex("fid") != -1){
            order = "fid";
        }
        int passes = 0;
        cursors.close();
        int limit = 0;
        long ftsrid = tbl_srids.get(tableName);

        JSONObject resultObject = new JSONObject();
        JSONArray featureArr = new JSONArray();
        JSONObject tmpresultObject = new JSONObject();

        while (limit + 10 < numberOfRows) {
//            FeatureCursor cursor = featureDao.query("", null, null, null, order, limit+", 10");
            FeatureCursor cursor = featureDao.queryForChunk( order, limit,10);

            try {
                while (cursor.moveToNext()) {
                    passes++;

                    try {
                        FeatureRow row = cursor.getRow();
                        /*if (drawFeature(boundingBox, transform, row, tableName)) {*/
                        Geometry rowGeometry = row.getGeometry().getGeometry();
                        if (ftsrid == 3857){
                            Projection projection1 = ProjectionFactory.getProjection(3857);
                            Projection projection2 = ProjectionFactory.getProjection(4326);
                            ProjectionTransform transforms = projection1.getTransformation(projection2);
                            rowGeometry = transforms.transform(rowGeometry);
                        }
                        JSONObject featureObj = new JSONObject();
                        JSONObject featureGeom=null,coords=null;
                        try {
                            featureGeom  = new JSONObject();
                            featureGeom.put("type",resolveGeoType(rowGeometry.getGeometryType().getName()));
                            coords = new JSONObject(FeatureConverter.toStringValue(rowGeometry));
                            featureGeom.put("coordinates",coords.getJSONArray("coordinates"));
                        }catch (OutOfMemoryError err){Log.e("err",err.toString());}
                        if (featureGeom != null && coords != null) {
                            JSONObject featureProp = new JSONObject();
                            String col[] = row.getColumnNames();
                            for (String colName : col) {
                                if (!colName.equalsIgnoreCase("geom")) {
                                    featureProp.put(colName, row.getValue(colName));
                                }
                            }
                            featureObj.put("type","Feature");
                            featureObj.put("properties",featureProp);
                            featureObj.put("geometry",featureGeom);

                            featureArr.put(featureObj);
                        }else {
                            Log.e("not added",resolveGeoType(rowGeometry.getGeometryType().getName()));
                        }
                        /* }*/
                    }catch (SQLException err){Log.e("err",err.toString());}
                }
            } catch (JSONException e) {
                e.printStackTrace();
                Log.e("err",e.toString());
            }
            cursor.close();
            limit += 10;
        }
        FeatureCursor cursor = featureDao.queryForChunk(order, numberOfRows-(numberOfRows - limit), (numberOfRows - limit));
//        FeatureCursor cursor = featureDao.query("", null, null, null, order, numberOfRows-(numberOfRows - limit)+", "+(numberOfRows - limit));
        try {
            while (cursor.moveToNext()) {
                passes++;
                FeatureRow row = cursor.getRow();
                /* if (drawFeature(boundingBox, transform, row, tableName)) {*/
                Geometry rowGeometry = row.getGeometry().getGeometry();
                if (ftsrid == 3857){
                    Projection projection1 = ProjectionFactory.getProjection(3857);
                    Projection projection2 = ProjectionFactory.getProjection(4326);
                    ProjectionTransform transforms = projection1.getTransformation(projection2);
                    rowGeometry = transforms.transform(rowGeometry);
                }

                JSONObject featureObj = new JSONObject();
                JSONObject featureGeom=null,coords=null;
                try {
                    featureGeom  = new JSONObject();
                    featureGeom.put("type",resolveGeoType(rowGeometry.getGeometryType().getName()));
                    coords = new JSONObject(FeatureConverter.toStringValue(rowGeometry));
                    featureGeom.put("coordinates",coords.getJSONArray("coordinates"));
                }catch (OutOfMemoryError ignored){}
                if (featureGeom != null && coords != null) {
                    JSONObject featureProp = new JSONObject();
                    String col[] = row.getColumnNames();
                    for (String colName : col) {
                        if (!colName.equalsIgnoreCase("geom")) {
                            featureProp.put(colName, row.getValue(colName));
                        }
                    }
                    featureObj.put("type","Feature");
                    featureObj.put("properties",featureProp);
                    featureObj.put("geometry",featureGeom);

                    featureArr.put(featureObj);
                }
                /*}*/
            }
            resultObject.put("type", "FeatureCollection");
            resultObject.put("features", featureArr);
            tmpresultObject.put("type", "FeatureCollection");
            tmpresultObject.put("features", featureArr);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        cursor.close();
        try {
            return resultObject.toString();
        }catch (OutOfMemoryError error){
            return tmpresultObject.toString();
        }
    }

    public BoundingBox expandBoundingBox(BoundingBox webMercatorBoundingBox, FeatureTiles featureTiles) {

        // Create an expanded bounding box to handle features outside the tile
        // that overlap
        float widthOverlap = featureTiles.getWidthDrawOverlap();
        float heightOverlap = featureTiles.getHeightDrawOverlap();
        long tileWidth = featureTiles.getTileWidth();
        long tileHeight = featureTiles.getTileHeight();
        double minLongitude = TileBoundingBoxUtils.getLongitudeFromPixel(
                tileWidth, webMercatorBoundingBox, 0 - widthOverlap);
        double maxLongitude = TileBoundingBoxUtils.getLongitudeFromPixel(
                tileWidth, webMercatorBoundingBox, tileWidth + widthOverlap);
        double maxLatitude = TileBoundingBoxUtils.getLatitudeFromPixel(
                tileHeight, webMercatorBoundingBox, 0 - heightOverlap);
        double minLatitude = TileBoundingBoxUtils.getLatitudeFromPixel(
                tileHeight, webMercatorBoundingBox, tileHeight + heightOverlap);
        return new BoundingBox(
                webMercatorBoundingBox.getMinLongitude()+webMercatorBoundingBox.getMinLongitude()/2,
                webMercatorBoundingBox.getMinLatitude()+webMercatorBoundingBox.getMinLatitude()/2,
                webMercatorBoundingBox.getMaxLongitude()+webMercatorBoundingBox.getMaxLongitude()/2,
                webMercatorBoundingBox.getMaxLatitude()+webMercatorBoundingBox.getMaxLatitude()/2
        );
    }

    public String resolveGeoType(String type){
        String result ="LineString";
        if (type.equalsIgnoreCase("Point".toUpperCase())){
            result = "Point";
        }else if (type.equalsIgnoreCase("LineString".toUpperCase())){
            result = "LineString";
        }else if (type.equalsIgnoreCase("Polygon".toUpperCase())){
            result = "Polygon";
        }else if (type.equalsIgnoreCase("MultiPoint".toUpperCase())){
            result = "MultiPoint";
        }else if (type.equalsIgnoreCase("MultiLineString".toUpperCase())){
            result = "MultiLineString";
        }else if (type.equalsIgnoreCase("MultiPolygon".toUpperCase())){
            result = "MultiPolygon";
        }

        return result;
    }
}
