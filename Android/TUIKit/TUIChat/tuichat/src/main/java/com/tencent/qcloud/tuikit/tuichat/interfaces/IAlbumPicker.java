package com.tencent.qcloud.tuikit.tuichat.interfaces;


import androidx.activity.result.ActivityResultCaller;

public abstract class IAlbumPicker {

    public abstract void pickMedia(ActivityResultCaller activityResultCaller, AlbumPickerListener listener);
}

