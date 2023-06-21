package com.tencent.cloud.tuikit.roomkit.view.component;


import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.imaccess.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.MoreFunctionViewModel;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;

public class MoreFunctionView extends BaseBottomDialog implements View.OnClickListener {

    private SettingView           mSettingView;
    private LinearLayout          mLayoutChat;
    private LinearLayout          mLayoutBeauty;
    private LinearLayout          mLayoutSetting;
    private MoreFunctionViewModel mViewModel;

    public MoreFunctionView(@NonNull Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_view_extension;
    }

    @Override
    protected void intiView() {
        mViewModel = new MoreFunctionViewModel(getContext(),this);
        mLayoutChat = findViewById(R.id.ll_item_chat);
        mLayoutBeauty = findViewById(R.id.ll_beauty_icon);
        mLayoutSetting = findViewById(R.id.ll_item_setting);

        mLayoutBeauty.removeAllViews();
        setBeautyView(mViewModel.getBeautyView());

        mLayoutSetting.setOnClickListener(this);
        if (BusinessSceneUtil.isChatAccessRoom() || TUICore.getService(TUIConstants.Service.TUI_CHAT) == null) {
            mLayoutChat.setVisibility(View.INVISIBLE);
        } else {
        mLayoutChat.setOnClickListener(this);
        }
    }

    @Override
    public void onDetachedFromWindow() {
        mViewModel.destroy();
        super.onDetachedFromWindow();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.ll_item_chat) {
            mViewModel.showChatView();
            dismiss();
        } else if (v.getId() == R.id.ll_item_setting) {
            if (mSettingView == null) {
                mSettingView = new SettingView(getContext());
            }
            mSettingView.show();
            dismiss();
        }
    }

    private void setBeautyView(View view) {
        if (view == null) {
            return;
        }
        RelativeLayout.LayoutParams params = new RelativeLayout
                .LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        mLayoutBeauty.addView(view, params);
    }
}
