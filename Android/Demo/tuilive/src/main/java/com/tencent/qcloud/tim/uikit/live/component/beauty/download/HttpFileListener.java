package com.tencent.qcloud.tim.uikit.live.component.beauty.download;

import java.io.File;

public interface HttpFileListener {
    void onProgressUpdate(int progress);

    void onSaveSuccess(File file);

    void onSaveFailed(File file, Exception e);

    void onProcessEnd();
}
