package com.tencent.cloud.tuikit.roomkit.videoseat.core;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;

import com.tencent.qcloud.tuicore.TUICore;


public final class TUIVideoSeatProvider extends ContentProvider {
    private static final String TAG = "TUIVideoSeatProvider";

    @Override
    public boolean onCreate() {
        Log.d(TAG, "TUIVideoSeatProvider onCreate");
        TUIVideoSeatExtension videoSeatExtension = new TUIVideoSeatExtension();
        TUICore.registerExtension(TUIVideoSeatExtension.OBJECT_TUI_VIDEO_SEAT, videoSeatExtension);
        return false;
    }


    @Override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) {
        return null;
    }


    @Override
    public String getType(Uri uri) {
        return null;
    }


    @Override
    public Uri insert(Uri uri, ContentValues values) {
        return null;
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
        return 0;
    }
}
