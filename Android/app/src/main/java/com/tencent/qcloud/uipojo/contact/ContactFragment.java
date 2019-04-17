package com.tencent.qcloud.uipojo.contact;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tim.tuikit.R;
import com.tencent.qcloud.uikit.common.BaseFragment;

/**
 * Created by Administrator on 2018/6/25.
 */

public class ContactFragment extends BaseFragment {
    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.contact_fragment, container, false);
    }
}
