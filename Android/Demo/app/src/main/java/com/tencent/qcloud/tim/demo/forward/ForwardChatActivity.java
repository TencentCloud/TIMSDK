package com.tencent.qcloud.tim.demo.forward;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.recyclerview.widget.LinearLayoutManager;

import com.tencent.imsdk.v2.V2TIMMergerElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.helper.ChatLayoutHelper;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseActvity;
import com.tencent.qcloud.tim.uikit.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.forward.message.ForwardMessageListAdapter;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.List;

public class ForwardChatActivity extends BaseActvity {

    private static final String TAG = ForwardChatActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private MessageLayout mFowardChatMessageLayout;
    private ForwardMessageListAdapter mForwardChatAdapter;

    private MessageInfo mMessageInfo;
    private String mTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.forward_chat_layout);
        mFowardChatMessageLayout = (MessageLayout) findViewById(R.id.chat_message_layout);
        mFowardChatMessageLayout.setLayoutManager(new CustomLinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        mForwardChatAdapter = new ForwardMessageListAdapter();
        mFowardChatMessageLayout.setAdapter(mForwardChatAdapter);

        mTitleBar = (TitleBarLayout) findViewById(R.id.chat_title_bar);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        mFowardChatMessageLayout.setOnItemClickListener(new MessageLayout.OnItemLongClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, MessageInfo messageInfo) {

            }

            @Override
            public void onUserIconClick(View view, int position, MessageInfo messageInfo) {
                if (null == messageInfo) {
                    return;
                }

                V2TIMMergerElem mergerElem = messageInfo.getTimMessage().getMergerElem();
                if (mergerElem != null){
                    Intent intent = new Intent(getBaseContext(), ForwardChatActivity.class);
                    Bundle bundle=new Bundle();
                    bundle.putSerializable(TUIKitConstants.FORWARD_MERGE_MESSAGE_KEY, messageInfo);
                    intent.putExtras(bundle);
                    //intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                }
            }
        });

        init();
    }

    private void init(){
        Intent intent = getIntent();
        if (intent != null) {
            mTitleBar.setTitle(mTitle, TitleBarLayout.POSITION.MIDDLE);
            mTitleBar.getRightGroup().setVisibility(View.GONE);

            mMessageInfo = (MessageInfo) intent.getSerializableExtra(TUIKitConstants.FORWARD_MERGE_MESSAGE_KEY);
            if (null == mMessageInfo) {
                TUIKitLog.d(TAG, "mMessageInfo is null");
                return;
            }

            V2TIMMergerElem mergerElem = mMessageInfo.getTimMessage().getMergerElem();
            if (mergerElem != null){
                if (mergerElem.isLayersOverLimit()){

                } else {
                    mergerElem.downloadMergerMessage(new V2TIMValueCallback<List<V2TIMMessage>>() {
                        @Override
                        public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                            if (v2TIMMessages != null && mForwardChatAdapter != null){
                                mForwardChatAdapter.setDataSource(v2TIMMessages);

                                // TODO 通过api设置ChatLayout各种属性的样例
                                ChatLayoutHelper helper = new ChatLayoutHelper(getApplicationContext());
                                helper.customizeMessageLayout(mFowardChatMessageLayout);
                            }
                        }

                        @Override
                        public void onError(int code, String desc) {

                        }
                    });
                }
            }
        }
    }

}
