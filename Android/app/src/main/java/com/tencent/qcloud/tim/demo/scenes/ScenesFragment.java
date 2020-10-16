package com.tencent.qcloud.tim.demo.scenes;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.scenes.view.ScenesLayout;
import com.tencent.qcloud.tim.uikit.base.BaseFragment;

public class ScenesFragment extends BaseFragment {

    private static final String TAG = ScenesFragment.class.getSimpleName();

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.scenes_fragment, container, false);
        initView(view);
        Log.i(TAG, "onCreateView");
        return view;
    }

    private void initView(View view) {
        ScenesLayout scenesLayout = view.findViewById(R.id.scenes_layout);
        scenesLayout.setFragmentManager(getChildFragmentManager());
    }
}
