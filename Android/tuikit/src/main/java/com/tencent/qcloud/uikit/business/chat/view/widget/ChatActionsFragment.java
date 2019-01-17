package com.tencent.qcloud.uikit.business.chat.view.widget;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.common.BaseFragment;

import java.util.List;

/**
 * Created by valxehuang on 2018/7/23.
 */

public class ChatActionsFragment extends BaseFragment {

    private View baseView;
    private BottomBoxWave panelWave = new BottomBoxWave();
    private List<MessageOperaUnit> actions;
    private IUIKitCallBack mCallback;

    public static final int REQUEST_CODE_FILE = 1011;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        baseView = inflater.inflate(R.layout.chat_bottom_actions_layout, container, false);
        panelWave.init(baseView, actions);
        return baseView;
    }

    public void setActions(List<MessageOperaUnit> actions) {
        this.actions = actions;
    }

    public void setCallback(IUIKitCallBack callback) {
        mCallback = callback;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_FILE) {
            if (resultCode != -1)
                return;
            Uri uri = data.getData();//得到uri，后面就是将uri转化成file的过程。
            if (mCallback != null)
                mCallback.onSuccess(uri);
        }
    }
}
