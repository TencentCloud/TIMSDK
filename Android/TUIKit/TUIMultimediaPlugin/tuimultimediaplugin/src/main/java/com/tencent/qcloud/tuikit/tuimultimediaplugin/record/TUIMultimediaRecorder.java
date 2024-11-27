package com.tencent.qcloud.tuikit.tuimultimediaplugin.record;

import android.net.Uri;
import android.os.Bundle;
import androidx.activity.result.ActivityResultCaller;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMultimediaRecorder;
import com.tencent.qcloud.tuikit.tuichat.interfaces.MultimediaRecorderListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;

public class TUIMultimediaRecorder extends IMultimediaRecorder {

    @Override
    public void openRecorder(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener) {
        Bundle bundle = new Bundle();
        openMultimediaRecord(activityResultCaller, bundle, listener);
    }

    @Override
    public void openCamera(ActivityResultCaller activityResultCaller, MultimediaRecorderListener listener) {
        Bundle bundle = new Bundle();
        bundle.putInt(TUIMultimediaConstants.PARAM_NAME_RECORD_TYPE, TUIMultimediaConstants.RECORD_TYPE_PHOTO);
        openMultimediaRecord(activityResultCaller, bundle, listener);
    }

    private void openMultimediaRecord(ActivityResultCaller activityResultCaller, Bundle bundle,MultimediaRecorderListener listener) {
        if (activityResultCaller == null || listener == null) {
            return;
        }
        TUICore.startActivityForResult(activityResultCaller, TUIMultimediaRecordActivity.class, bundle, result -> {
            Bundle resultBundle = null;
            if (result.getData() != null) {
                resultBundle = result.getData().getExtras();
            }

            String recordPath = null;
            if (resultBundle != null) {
                recordPath = resultBundle.getString(TUIMultimediaConstants.PARAM_NAME_EDITED_FILE_PATH);
            }

            Uri recordUri = null;
            if (recordPath != null) {
                recordUri = FileUtil.getUriFromPath(recordPath);
            }

            if (recordUri != null) {
                listener.onSuccess(recordUri);
            } else {
                listener.onFailed(-1, "");
            }
        });
    }
}
