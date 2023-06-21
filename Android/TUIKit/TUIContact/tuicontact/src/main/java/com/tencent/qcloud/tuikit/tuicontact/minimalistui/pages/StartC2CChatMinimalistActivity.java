package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.util.ContactStartChatUtils;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;

public class StartC2CChatMinimalistActivity extends AppCompatActivity {
    private static final String TAG = StartC2CChatMinimalistActivity.class.getSimpleName();

    private TextView cancelButton;
    private View createGroupButton;
    private ContactListView mContactListView;

    private ContactPresenter presenter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.minimalist_popup_start_c2c_chat_activity);
        cancelButton = findViewById(R.id.cancel_button);
        mContactListView = findViewById(R.id.contact_list_view);
        mContactListView.setSingleSelectMode(true);
        createGroupButton = findViewById(R.id.create_group_button);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        createGroupButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(StartC2CChatMinimalistActivity.this, StartGroupChatMinimalistActivity.class);
                startActivity(intent);
                finish();
            }
        });
        presenter = new ContactPresenter();
        presenter.setFriendListListener();
        mContactListView.setPresenter(presenter);
        presenter.setContactListView(mContactListView);

        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                startConversation(contact);
            }
        });
    }

    public void startConversation(ContactItemBean selectedItem) {
        if (selectedItem == null) {
            ToastUtil.toastLongMessage(getString(R.string.select_chat));
            return;
        }
        String chatName = selectedItem.getId();
        if (!TextUtils.isEmpty(selectedItem.getRemark())) {
            chatName = selectedItem.getRemark();
        } else if (!TextUtils.isEmpty(selectedItem.getNickName())) {
            chatName = selectedItem.getNickName();
        }

        ContactStartChatUtils.startChatActivity(selectedItem.getId(), ContactItemBean.TYPE_C2C, chatName, selectedItem.getAvatarUrl(), null);
        finish();
    }
}
