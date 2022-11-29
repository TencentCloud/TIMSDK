package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.Nullable;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.BaseInputFragment;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;

import java.util.ArrayList;
import java.util.List;

public class InputMoreFragment extends BaseInputFragment {

    public static final int REQUEST_CODE_FILE = 1011;
    public static final int REQUEST_CODE_PHOTO = 1012;

    private View mBaseView;
    private List<InputMoreActionUnit> mInputMoreList = new ArrayList<>();
    private IUIKitCallback mCallback;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.chat_inputmore_fragment, container, false);
        InputMoreLayout layout = mBaseView.findViewById(R.id.input_extra_area);
        layout.init(mInputMoreList);
        return mBaseView;
    }

    public void setActions(List<InputMoreActionUnit> actions) {
        this.mInputMoreList = actions;
    }

    public void setCallback(IUIKitCallback callback) {
        mCallback = callback;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_FILE
                || requestCode == REQUEST_CODE_PHOTO) {
            if (resultCode != -1) {
                return;
            }
            Uri uri = data.getData();
            if (mCallback != null) {
                mCallback.onSuccess(uri);
            }
        }
    }
}
