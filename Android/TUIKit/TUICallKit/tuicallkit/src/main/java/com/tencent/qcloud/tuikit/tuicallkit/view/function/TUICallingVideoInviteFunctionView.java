package com.tencent.qcloud.tuikit.tuicallkit.view.function;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.TUICallingStatusManager;

public class TUICallingVideoInviteFunctionView extends BaseFunctionView {
    private LinearLayout mLayoutCancel;
    private ImageView    mImageSwitchCamera;

    public TUICallingVideoInviteFunctionView(Context context) {
        super(context);
        initView();
        initClickListener();
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.tuicalling_funcation_view_video_inviting, this);
        mLayoutCancel = findViewById(R.id.ll_cancel);
        mImageSwitchCamera = findViewById(R.id.img_switch_camera);
    }

    private void initClickListener() {
        mLayoutCancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallingAction.hangup(null);
            }
        });

        mImageSwitchCamera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                TUICommonDefine.Camera camera = TUICallingStatusManager.sharedInstance(mContext).getFrontCamera();
                mCallingAction.switchCamera(TUICommonDefine.Camera.Front.equals(camera)
                        ? TUICommonDefine.Camera.Back : TUICommonDefine.Camera.Front);
                ToastUtil.toastShortMessage(mContext.getString(R.string.tuicalling_toast_switch_camera));
            }
        });
    }
}
