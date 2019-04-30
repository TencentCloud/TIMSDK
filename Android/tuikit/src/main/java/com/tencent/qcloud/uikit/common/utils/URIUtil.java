package com.tencent.qcloud.uikit.common.utils;

import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;

import com.tencent.qcloud.uikit.TUIKit;


public class URIUtil {

    public static String getRealPathFromURI(Uri contentURI) {
        String result;
        Cursor cursor = TUIKit.getAppContext().getContentResolver().query(contentURI,
                new String[]{MediaStore.Images.ImageColumns.DATA},//
                null, null, null);
        if (cursor == null) result = contentURI.getPath();
        else {
            cursor.moveToFirst();
            int index = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
            result = cursor.getString(index);
            cursor.close();
        }
        return result;
    }
}
