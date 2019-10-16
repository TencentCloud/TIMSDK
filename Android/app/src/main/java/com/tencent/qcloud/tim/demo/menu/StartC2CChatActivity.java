package com.tencent.qcloud.tim.demo.menu;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.View;

import com.tencent.imsdk.TIMConversationType;
import com.tencent.qcloud.tim.demo.BaseActivity;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.chat.ChatActivity;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactItemBean;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactListView;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class StartC2CChatActivity extends BaseActivity {

    private static final String TAG = StartC2CChatActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private ContactItemBean mSelectedItem;
    private List<ContactItemBean> mContacts = new ArrayList<>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.popup_start_c2c_chat_activity);

        mTitleBar = findViewById(R.id.start_c2c_chat_title);
        mTitleBar.setTitle(getResources().getString(R.string.sure), TitleBarLayout.POSITION.RIGHT);
        mTitleBar.getRightTitle().setTextColor(getResources().getColor(R.color.title_bar_font_color));
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startConversation();
            }
        });
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mContactListView = findViewById(R.id.contact_list_view);
        mContactListView.setSingleSelectMode(true);
        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    if (mSelectedItem == contact) {
                        // 相同的Item，忽略
                    } else {
                        if (mSelectedItem != null) {
                            mSelectedItem.setSelected(false);
                        }
                        mSelectedItem = contact;
                    }
                } else {
                    if (mSelectedItem == contact) {
                        mSelectedItem.setSelected(false);
                    }
                }
            }
        });
    }

    public void startConversation() {
        if (mSelectedItem == null || !mSelectedItem.isSelected()) {
            ToastUtil.toastLongMessage("请选择聊天对象");
            return;
        }
        ChatInfo chatInfo = new ChatInfo();
        chatInfo.setType(TIMConversationType.C2C);
        chatInfo.setId(mSelectedItem.getId());
        String chatName = mSelectedItem.getId();
        if (!TextUtils.isEmpty(mSelectedItem.getRemark())) {
            chatName = mSelectedItem.getRemark();
        } else if (!TextUtils.isEmpty(mSelectedItem.getNickname())) {
            chatName = mSelectedItem.getNickname();
        }
        chatInfo.setChatName(chatName);
        Intent intent = new Intent(DemoApplication.instance(), ChatActivity.class);
        intent.putExtra(Constants.CHAT_INFO, chatInfo);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        DemoApplication.instance().startActivity(intent);

        finish();
    }
}
