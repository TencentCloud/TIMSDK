package com.tencent.qcloud.tuikit.tuicallkit.view.function;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingAction;

public class TUICallingSwitchAudioView extends BaseFunctionView {
    private final Context mContext;

    public TUICallingSwitchAudioView(Context context) {
        super(context);
        mContext = context.getApplicationContext();
        initView();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.tuicalling_switch_audio_view, this);
        LinearLayout layoutSwitchToAudio = findViewById(R.id.ll_switch_audio);
        layoutSwitchToAudio.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                TUICallingAction callingAction = new TUICallingAction(mContext);
                callingAction.switchCallMediaType(TUICallDefine.MediaType.Audio);
            }
        });
    }
}
