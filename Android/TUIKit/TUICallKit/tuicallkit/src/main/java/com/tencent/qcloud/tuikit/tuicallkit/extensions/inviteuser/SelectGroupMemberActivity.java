package com.tencent.qcloud.tuikit.tuicallkit.extensions.inviteuser;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuicallkit.R;
import com.tencent.qcloud.tuikit.tuicallkit.base.Constants;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SelectGroupMemberActivity extends AppCompatActivity {
    private static AppCompatActivity mActivity;

    private RecyclerView             mRecyclerUserList;
    private String                   mGroupId;
    private List<GroupMemberInfo>    mGroupMemberList   = new ArrayList<>();
    private List<String>             mAlreadySelectList = new ArrayList<>();
    private SelectGroupMemberAdapter mAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuicallkit_activity_group_user);
        mActivity = this;
        initStatusBar();
        initView();
        initData();
    }

    private void initView() {
        Toolbar toolbar = findViewById(R.id.toolbar_group);
        if (toolbar.getNavigationIcon() != null) {
            toolbar.getNavigationIcon().setAutoMirrored(true);
        }
        toolbar.setNavigationOnClickListener(v -> finish());
        Button btnOK = findViewById(R.id.btn_group_ok);
        btnOK.setOnClickListener(v -> {
            if (mAdapter != null) {
                List<String> selectUsers = new ArrayList<>();
                for (GroupMemberInfo info : mGroupMemberList) {
                    if (info != null && !TextUtils.isEmpty(info.userId) && info.isSelected) {
                        selectUsers.add(info.userId);
                    }
                }
                Map<String, Object> map = new HashMap<>();
                map.put(Constants.SELECT_MEMBER_LIST, selectUsers);
                TUICore.notifyEvent(Constants.EVENT_TUICALLING_CHANGED, Constants.EVENT_SUB_GROUP_MEMBER_SELECTED, map);
            }
            finish();
        });
        mRecyclerUserList = findViewById(R.id.rv_user_list);
    }

    private void initData() {
        Intent intent = getIntent();
        mGroupId = intent.getStringExtra(Constants.GROUP_ID);
        mAlreadySelectList = new ArrayList<>(intent.getStringArrayListExtra(Constants.SELECT_MEMBER_LIST));

        mAdapter = new SelectGroupMemberAdapter();
        mRecyclerUserList.setLayoutManager(new LinearLayoutManager(getApplicationContext()));
        mRecyclerUserList.setAdapter(mAdapter);

        updateGroupUserList();
    }

    private void updateGroupUserList() {
        int filter = V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL;
        V2TIMManager.getGroupManager().getGroupMemberList(mGroupId, filter, 0,
                new V2TIMValueCallback<V2TIMGroupMemberInfoResult>() {
                    @Override
                    public void onSuccess(V2TIMGroupMemberInfoResult v2TIMGroupMemberInfoResult) {
                        List<V2TIMGroupMemberFullInfo> results = v2TIMGroupMemberInfoResult.getMemberInfoList();
                        mGroupMemberList.clear();
                        for (V2TIMGroupMemberFullInfo info : results) {
                            GroupMemberInfo userInfo = new GroupMemberInfo();
                            userInfo.userId = info.getUserID();
                            userInfo.avatar = info.getFaceUrl();
                            userInfo.userName = info.getNickName();
                            userInfo.isSelected = mAlreadySelectList.contains(userInfo.userId);
                            mGroupMemberList.add(userInfo);
                        }

                        if (mAdapter != null) {
                            mAdapter.setDataSource(mGroupMemberList);
                            mAdapter.notifyDataSetChanged();
                        }
                    }

                    @Override
                    public void onError(int errorCode, String errorMsg) {
                    }
                });
    }

    public static void finishActivity() {
        if (mActivity == null || mActivity.isFinishing()) {
            return;
        }
        mActivity.finish();
        mActivity = null;
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }
}