package com.tencent.qcloud.uikit.common.component.picture;

import android.net.Uri;

/**
 * Created by valexhuang on 2018/9/14.
 */

public class PictureInfo {
    private String path;
    private Uri uri;
    private boolean compressed;

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public Uri getUri() {
        return uri;
    }

    public void setUri(Uri uri) {
        this.uri = uri;
    }

    public boolean isCompressed() {
        return compressed;
    }

    public void setCompressed(boolean compressed) {
        this.compressed = compressed;
    }
}
