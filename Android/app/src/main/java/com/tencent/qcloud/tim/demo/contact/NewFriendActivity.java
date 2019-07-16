package com.tencent.qcloud.tim.demo.contact;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;

import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.friendship.TIMFriendPendencyItem;
import com.tencent.imsdk.friendship.TIMFriendPendencyRequest;
import com.tencent.imsdk.friendship.TIMFriendPendencyResponse;
import com.tencent.imsdk.friendship.TIMPendencyType;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.menu.AddMoreActivity;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class NewFriendActivity extends Activity {

    private static final String TAG = NewFriendActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ListView mNewFriendLv;
    private NewFriendListAdapter mAdapter;
    private TextView mEmptyView;
    private List<TIMFriendPendencyItem> mList = new ArrayList<>();

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
        final TIMFriendPendencyRequest timFriendPendencyRequest = new TIMFriendPendencyRequest();
        timFriendPendencyRequest.setTimPendencyGetType(TIMPendencyType.TIM_PENDENCY_COME_IN);
        timFriendPendencyRequest.setSeq(0);
        timFriendPendencyRequest.setTimestamp(0);
        timFriendPendencyRequest.setNumPerPage(10);
        TIMFriendshipManager.getInstance().getPendencyList(timFriendPendencyRequest, new TIMValueCallBack<TIMFriendPendencyResponse>() {
            @Override
            public void onError(int i, String s) {
                DemoLog.e(TAG, "getPendencyList err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
            }

            @Override
            public void onSuccess(TIMFriendPendencyResponse timFriendPendencyResponse) {
                DemoLog.i(TAG, "getPendencyList success result = " + timFriendPendencyResponse.toString());
                if (timFriendPendencyResponse.getItems() != null) {
                    if (timFriendPendencyResponse.getItems().size() == 0 ) {
                        mEmptyView.setText("暂无好友申请");
                        mNewFriendLv.setVisibility(View.GONE);
                        mEmptyView.setVisibility(View.VISIBLE);
                        return;
                    }
                }
                mNewFriendLv.setVisibility(View.VISIBLE);
                mList.clear();
                mList.addAll(timFriendPendencyResponse.getItems());
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
