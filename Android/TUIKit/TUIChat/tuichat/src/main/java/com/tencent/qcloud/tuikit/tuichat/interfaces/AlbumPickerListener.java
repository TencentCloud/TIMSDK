package com.tencent.qcloud.tuikit.tuichat.interfaces;

import android.net.Uri;


public interface AlbumPickerListener {

    void onFinished(Uri originalUri, Uri transcodeUri);

    void onProgress(Uri originalUri, int progress);

    void onOriginalMediaPicked(Uri originalUri);

    void onCancel();
}
