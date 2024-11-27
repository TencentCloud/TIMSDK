package com.tencent.qcloud.tuikit.tuichat.interfaces;

import android.net.Uri;

public interface MultimediaRecorderListener {

    void onSuccess(Uri uri);

    void onFailed(int errorCode, String errorMessage);
}
