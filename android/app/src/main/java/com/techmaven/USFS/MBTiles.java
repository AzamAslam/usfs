package com.techmaven.USFS;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;


public class MBTiles {
    private SQLiteDatabase tilesDB;
    private final String TAG = "HTTPMBTiles";

    public MBTiles(String fileName) throws Exception {
        try {
            tilesDB = SQLiteDatabase.openDatabase(fileName, null, SQLiteDatabase.OPEN_READONLY);
        } catch(Exception ignored) {

        }
    }

    public String getType() {
        String query;
        Cursor cursor;
        String metadata="";

        query = "SELECT value FROM metadata WHERE name = 'type'";
        cursor = tilesDB.rawQuery(query, null);
        if (cursor.moveToFirst()) {
				metadata=cursor.getString(0);
        }
        cursor.close();
        return metadata;
    }
    public String getFormat() {
        String query;
        Cursor cursor;
        String metadata="";

        query = "SELECT value FROM metadata WHERE name = 'format'";
        cursor = tilesDB.rawQuery(query, null);
        if (cursor.moveToFirst()) {
				metadata=cursor.getString(0);
        }
        cursor.close();
        return metadata;
    }

    private double[] getBoundsFromMetadata() {
        String query;
        Cursor cursor;
        double[] bounds = null;

        query = "SELECT value FROM metadata WHERE name = 'bounds'";
        cursor = tilesDB.rawQuery(query, null);
        if (cursor.moveToFirst()) {
            // Use the bounds provided in the metadata
            String[] boundsStr = cursor.getString(0).split(",", 4);
            bounds = new double[4];

            if (bounds.length == 4) {
                bounds[0] = Double.parseDouble(boundsStr[0]); // left
                bounds[1] = Double.parseDouble(boundsStr[1]); // bottom
                bounds[2] = Double.parseDouble(boundsStr[2]); // top
                bounds[3] = Double.parseDouble(boundsStr[3]); // right
            }
        }
        cursor.close();
        return bounds;
    }

    private double[] calculateBounds() {
        String query;
        Cursor cursor;
        double[] bounds = null;
        query =
            "SELECT MIN(tile_column), " +
                    "MAX(tile_column), " +
                    "MIN(tile_row), " +
                    "MAX(tile_row), " +
                    "zoom_level " +
                    "FROM tiles " +
                    "WHERE zoom_level = (SELECT MIN(zoom_level) FROM tiles)";

        cursor = tilesDB.rawQuery(query, null);
        if (cursor.moveToFirst()) {
            int zoomLevel = cursor.getInt(4);
            bounds = new double[4];
            double[] southwest;
            double[] northeast;
            // The mbtiles as stored as TMS, flip y axis to do calculations
            int numRows = (1 << zoomLevel);
            southwest = GeoUtils.tile2deg(cursor.getInt(0), numRows - 1 - cursor.getInt(1), zoomLevel);
            northeast = GeoUtils.tile2deg(cursor.getInt(2), numRows - 1 - cursor.getInt(3), zoomLevel);

            bounds[0] = southwest[0];
            bounds[1] = southwest[1];
            bounds[2] = northeast[0];
            bounds[3] = northeast[1];
        }
        cursor.close();
        return bounds;
    }

    public double[] getBounds() {
        String query;
        Cursor cursor;
        double[] bounds = null;

        bounds = getBoundsFromMetadata();
        if (bounds == null) {
            bounds = calculateBounds();
        }

        return bounds;
    }


    public byte[] getTile(int level, int col, int row) throws Exception {
        String query = String.format(
            "SELECT tile_data " +
            "FROM tiles " +
            "WHERE zoom_level = %d AND tile_column = %d AND tile_row = %d", level, col, row);
        byte[] tile = null;
        Cursor imageCur = tilesDB.rawQuery(query, null);

        if (imageCur.moveToFirst()) {
            tile = imageCur.getBlob(0);
        }
        imageCur.close();
        return tile;
  }

    public String getCenter() {
        String query;
        Cursor cursor;
        String metadata="0,0,0";

        query = "select value from metadata where name='center'";
        cursor = tilesDB.rawQuery(query, null);
        if (cursor.moveToFirst()){
            metadata=cursor.getString(0);
        }
        cursor.close();
        return metadata;
    }

    public int getMaxZoom() {
        String query;
        Cursor cursor;
        int metadata=0;

        query = "select MAX(zoom_level) as zoom from tiles";
        cursor = tilesDB.rawQuery(query, null);
        if (cursor.moveToFirst()){
            metadata=cursor.getInt(0);
        }
        cursor.close();
        return metadata;
    }
    public JSONObject getAllMetaData(){
        Cursor cursor = tilesDB.rawQuery("SELECT * FROM metadata",null);
        JSONObject metaData = new JSONObject();
        try {
            while (cursor.moveToNext()) {
                metaData.put(cursor.getString(0),cursor.getString(1));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return metaData;
    }
}
