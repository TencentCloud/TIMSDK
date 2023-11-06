package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.page;

import android.os.Bundle;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.MemberListAdapter;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;
import java.util.List;

public class CustomerServiceMemberListActivity extends BaseLightActivity {
    private TitleBarLayout mTitleBar;
    private ListView memberListView;
    private TextView notFoundTip;
    private TUICustomerServicePresenter presenter;
    private MemberListAdapter mAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.customer_service_member_list_activity);
        init();
    }

    private void init() {
        mTitleBar = findViewById(R.id.customer_service_member_titlebar);
        mTitleBar.setTitle(getResources().getString(R.string.customer_service), ITitleBarLayout.Position.MIDDLE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        memberListView = findViewById(R.id.customer_service_member_list);
        notFoundTip = findViewById(R.id.customer_service_member_not_found_tip);
        presenter = new TUICustomerServicePresenter();
        presenter.getCustomerServiceUserInfo(new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.isEmpty()) {
                    notFoundTip.setVisibility(View.VISIBLE);
                } else {
                    notFoundTip.setVisibility(View.GONE);
                    mAdapter = new MemberListAdapter(CustomerServiceMemberListActivity.this, R.layout.customer_service_member_item, v2TIMUserFullInfos);
                    memberListView.setAdapter(mAdapter);
                    mAdapter.notifyDataSetChanged();
                }
            }

            @Override
            public void onError(int code, String desc) {
                notFoundTip.setVisibility(View.VISIBLE);
            }
        });
    }
}
