package com.tencent.qcloud.tuikit.tuichat.component.album;

import android.net.Uri;
import androidx.activity.result.ActivityResultCaller;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.tuichat.interfaces.AlbumPickerListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IAlbumPicker;
import java.util.List;

class SystemAlbumPickerImpl extends IAlbumPicker {
    @Override
    public void pickMedia(ActivityResultCaller activityResultCaller, AlbumPickerListener listener) {
        if (activityResultCaller == null || listener == null) {
            return;
        }
        ActivityResultResolver.getMultipleContent(activityResultCaller,
            new String[] {ActivityResultResolver.CONTENT_TYPE_IMAGE, ActivityResultResolver.CONTENT_TYPE_VIDEO}, new TUIValueCallback<List<Uri>>() {
                @Override
                public void onSuccess(List<Uri> uris) {
                    for (Uri uri : uris) {
                        listener.onFinished(uri, null);
                    }
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    listener.onCancel();
                }
            });
    }
}
