package com.tencent.qcloud.tuikit.tuimultimediaplugin.pick;

import android.app.Activity;
import android.net.Uri;

import androidx.activity.result.ActivityResultCaller;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuichat.interfaces.AlbumPickerListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IAlbumPicker;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaMediaProcessor;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.ui.picker.AlbumPickerActivity;

import java.util.ArrayList;

public class TUIMultimediaAlbumPicker extends IAlbumPicker {
    private static final String TAG = "TUIMultimediaAlbumPicker";

    @Override
    public void pickMedia(ActivityResultCaller activityResultCaller, AlbumPickerListener listener) {
        if (activityResultCaller == null || listener == null) {
            return;
        }
        TUICore.startActivityForResult(activityResultCaller, AlbumPickerActivity.class, null, result -> {
            if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {
                ArrayList<Uri> uris = result.getData().getParcelableArrayListExtra("data");
                ArrayList<Uri> transcodeData = result.getData().getParcelableArrayListExtra("transcodeData");
                if ((uris == null || uris.isEmpty()) && (transcodeData == null || transcodeData.isEmpty())) {
                    listener.onCancel();
                    return;
                }
                if (transcodeData != null && !transcodeData.isEmpty()) {
                    for (Uri uri : transcodeData) {
                        listener.onOriginalMediaPicked(uri);
                    }
                    TUIMultimediaMediaProcessor.getInstance().transcodeMedia(transcodeData, new TUIMultimediaMediaProcessor.TUIMultimediaMediaTranscodeListener() {
                        @Override
                        public void onTranscodeFinished(TUIMultimediaMediaProcessor.TranscodeResult transcodeResult) {
                            if (transcodeResult.errorCode == 0) {
                                listener.onFinished(transcodeResult.originalUri, transcodeResult.transcodeMediaUri);
                            } else {
                                listener.onFinished(transcodeResult.originalUri, null);
                            }
                        }

                        @Override
                        public void onTranscodeProgress(Uri originalUri, int transcodeProgress) {
                            listener.onProgress(originalUri, transcodeProgress);
                        }
                    });
                }
                if (uris != null && !uris.isEmpty()) {
                    for (Uri uri : uris) {
                        listener.onFinished(uri, null);
                    }

                }

            }
        });
    }
}
