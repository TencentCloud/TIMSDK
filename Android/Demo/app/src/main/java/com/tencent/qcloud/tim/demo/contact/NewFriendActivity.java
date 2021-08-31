package com.tencent.qcloud.tim.demo.contact;

import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.view.View;
import android.widget.ListView;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplicationResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.BaseActivity;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.menu.AddMoreActivity;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class NewFriendActivity extends BaseActivity {

    private static final String TAG = NewFriendActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ListView mNewFriendLv;
    private NewFriendListAdapter mAdapter;
    private TextView mEmptyView;
    private List<V2TIMFriendApplication> mList = new ArrayList<>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_new_friend_activity);
        init();
    }

    @Override
    protected void onResume() {
        super.onResume();
        initPendency();
    }

    private void init() {
        mTitleBar = findViewById(R.id.new_friend_titlebar);
        mTitleBar.setTitle(getResources().getString(R.string.new_friend), TitleBarLayout.POSITION.LEFT);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mTitleBar.setTitle(getResources().getString(R.string.add_friend), TitleBarLayout.POSITION.RIGHT);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(DemoApplication.instance(), AddMoreActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.putExtra("isGroup", false);
                startActivity(intent);
            }
        });

        mNewFriendLv = findViewById(R.id.new_friend_list);
        mEmptyView = findViewById(R.id.empty_text);
    }

    private void initPendency() {
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG, "getPendencyList err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                DemoLog.i(TAG, "getFriendApplicationList success");
                if (v2TIMFriendApplicationResult.getFriendApplicationList() != null) {
                    if (v2TIMFriendApplicationResult.getFriendApplicationList().size() == 0) {
                        mEmptyView.setText(getResources().getString(R.string.no_friend_apply));
                        mNewFriendLv.setVisibility(View.GONE);
                        mEmptyView.setVisibility(View.VISIBLE);
                        return;
                    }
                }
                mNewFriendLv.setVisibility(View.VISIBLE);
                mList.clear();
                mList.addAll(v2TIMFriendApplicationResult.getFriendApplicationList());
                mAdapter = new NewFriendListAdapter(NewFriendActivity.this, R.layout.contact_new_friend_item, mList);
                mNewFriendLv.setAdapter(mAdapter);
                mAdapter.notifyDataSetChanged();
            }
        });
    }

    @Override
    public void finish() {
        super.finish();
    }

}
