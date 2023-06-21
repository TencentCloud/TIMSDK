package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.BaseInputFragment;

import java.util.ArrayList;
import java.util.List;

public class InputMoreFragment extends BaseInputFragment {
    private List<InputMoreActionUnit> mInputMoreList = new ArrayList<>();

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View baseView = inflater.inflate(R.layout.chat_inputmore_fragment, container, false);
        InputMoreLayout layout = baseView.findViewById(R.id.input_extra_area);
        layout.init(mInputMoreList);
        return baseView;
    }

    public void setActions(List<InputMoreActionUnit> actions) {
        this.mInputMoreList = actions;
    }
}
