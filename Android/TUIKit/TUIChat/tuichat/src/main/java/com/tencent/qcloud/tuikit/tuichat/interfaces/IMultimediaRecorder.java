package com.tencent.qcloud.tuikit.tuichat.interfaces;

import androidx.activity.result.ActivityResultCaller;

public abstract class IMultimediaRecorder {

    public abstract void openRecorder(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener);

    public abstract void openCamera(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener);
}
