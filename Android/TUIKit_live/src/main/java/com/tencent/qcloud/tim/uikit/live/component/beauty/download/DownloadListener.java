package com.tencent.qcloud.tim.uikit.live.component.beauty.download;

public interface DownloadListener {
    void onDownloadFail(String errorMsg);

    void onDownloadProgress(final int progress);

    void onDownloadSuccess(String filePath);
}
