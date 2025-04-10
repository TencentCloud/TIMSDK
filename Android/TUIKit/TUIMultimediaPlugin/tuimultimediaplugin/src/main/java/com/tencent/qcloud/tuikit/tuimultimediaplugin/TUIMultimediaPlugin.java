package com.tencent.qcloud.tuikit.tuimultimediaplugin;

import android.content.Context;
import android.text.TextUtils;
import com.google.auto.service.AutoService;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.tuichat.component.album.AlbumPicker;
import com.tencent.qcloud.tuikit.tuichat.component.album.VideoRecorder;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker.SignatureCheckListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.TUIMultimediaAlbumPicker;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.TUIMultimediaRecorder;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency({"TUIChat"})
@TUIInitializerID("TUIMultimediaRecordService")
public class TUIMultimediaPlugin implements TUIInitializer, ITUINotification {
    public static final String TAG = TUIMultimediaPlugin.class.getSimpleName();

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }

    @Override
    public void init(Context context) {
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS, this);
        AlbumPicker.registerAdvancedAlbumPicker(new TUIMultimediaAlbumPicker());
        VideoRecorder.registerAdvancedVideoRecorder(new TUIMultimediaRecorder());
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED)) {
            if (TextUtils.equals(subKey, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_LOGIN_SUCCESS)) {
                TUICore.registerEvent(
                    TUIConstants.NetworkConnection.EVENT_CONNECTION_STATE_CHANGED, TUIConstants.NetworkConnection.EVENT_SUB_KEY_CONNECT_SUCCESS, this);
                updateSignature();
            }
        } else if (TUIConstants.NetworkConnection.EVENT_CONNECTION_STATE_CHANGED.equals(key)) {
            if (TUIConstants.NetworkConnection.EVENT_SUB_KEY_CONNECT_SUCCESS.equals(subKey)) {
                updateSignature();
            }
        }
    }

    private void updateSignature() {
        TUIMultimediaSignatureChecker.getInstance().startUpdateSignature(() -> {

        });
    }
}
