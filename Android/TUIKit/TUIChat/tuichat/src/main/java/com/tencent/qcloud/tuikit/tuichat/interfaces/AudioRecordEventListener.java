package com.tencent.qcloud.tuikit.tuichat.interfaces;


/**
 * C2C Chat event listener
 */
public abstract class AudioRecordEventListener {
    public void onRecordBegin(int errorCode, String path) {}
    public void onRecordComplete(int errorCode, String path) {}
}
