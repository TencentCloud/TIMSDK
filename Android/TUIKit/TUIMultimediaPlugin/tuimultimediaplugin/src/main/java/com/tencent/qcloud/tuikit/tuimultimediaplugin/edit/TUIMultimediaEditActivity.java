package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFullScreen;
import com.tencent.ugc.TXVideoEditConstants.TXVideoInfo;

public class TUIMultimediaEditActivity extends TUIMultimediaFullScreen {

    private final String TAG = TUIMultimediaEditActivity.class.getSimpleName() + "_" + hashCode();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.multimedia_plugin_edit_activity);
        startUpVideoEdit();
    }

    private void startUpVideoEdit() {
        Fragment fragment = null;
        Bundle bundle = getIntent().getExtras();

        TXVideoInfo videoInfo = TUIMultimediaEditorCore
                .getVideoFileInfo(this, bundle.getString(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_PATH));

        if (TUIMultimediaEditorCore.isValidVideo(videoInfo)) {
            fragment = new TUIMultimediaVideoEditFragment(this);
            bundle.putFloat(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_RATIO, TUIMultimediaEditorCore.getVideoAspect(videoInfo));
        }

        if (fragment == null) {
            fragment = new TUIMultimediaPictureEditFragment(this);
        }

        fragment.setArguments(bundle);
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.fl_edit_fragment_container, fragment)
                .commit();
    }
}
