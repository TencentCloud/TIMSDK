package com.tencent.qcloud.tuikit.tuimultimediaplugin.record;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFullScreen;

public class TUIMultimediaRecordActivity extends TUIMultimediaFullScreen {

    private final String TAG = TUIMultimediaRecordActivity.class.getSimpleName() + "_" + hashCode();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.multimedia_plugin_record_activity);
        TUIMultimediaRecordFragment fragment = new TUIMultimediaRecordFragment(this);
        fragment.setArguments(getIntent().getExtras());
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.fl_record_fragment_container, fragment)
                .commit();
    }
}