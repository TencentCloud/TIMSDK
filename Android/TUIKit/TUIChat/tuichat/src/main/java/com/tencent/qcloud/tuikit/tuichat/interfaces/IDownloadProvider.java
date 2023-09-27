package com.tencent.qcloud.tuikit.tuichat.interfaces;

import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;

public interface IDownloadProvider {
    default void downloadSound(String path, TUIValueCallback<String> callback) {}

    default void downloadFile(String path, TUIValueCallback<String> callback) {}

    default void downloadImage(String path, TUIValueCallback<String> callback) {}

    default void downloadVideo(String path, TUIValueCallback<String> callback) {}

    default void downloadVideoSnapshot(String path, TUIValueCallback<String> callback) {}
}
