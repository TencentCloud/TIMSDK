package com.tencent.qcloud.uikit.operation.c2c;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.c2c.view.PersonalInfoPanel;
import com.tencent.qcloud.uikit.common.BaseFragment;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class PersonalInfoFragment extends BaseFragment {
    private View mBaseView;
    private PersonalInfoPanel infoPanel;
    private PageTitleBar chatTitleBar;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {

        mBaseView = inflater.inflate(R.layout.info_fragment_personal, container, false);
        initView();
        return mBaseView;
    }

    private void initView() {
        infoPanel = mBaseView.findViewById(R.id.personal_info_panel);
        chatTitleBar = infoPanel.getTitleBar();
        chatTitleBar.setLeftClick(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                backward();
            }
        });
    }
}
