package com.tencent.qcloud.tim.uikit.modules.group.info;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactItemBean;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactListView;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class StartGroupMemberSelectActivity extends Activity {

    private static final String TAG = StartGroupMemberSelectActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.popup_start_group_select_activity);

        init();
    }

    private String getMembersNameCard(){
        if (mMembers.size() == 0) {
            return "";
        }

        //TUIKitLog.i(TAG, "getMembersNameCard mMembers.size() = " + mMembers.size());
        String nameCardString = "";
        for(int i = 0; i < mMembers.size(); i++){
            nameCardString += mMembers.get(i).getNameCard();
            nameCardString += " ";
        }
        //TUIKitLog.i(TAG, "nameCardString = " + nameCardString);
        return nameCardString;
    }

    private String getMembersUserId(){
        if (mMembers.size() == 0) {
            return "";
        }

        //TUIKitLog.i(TAG, "getMembersUserId mMembers.size() = " + mMembers.size());
        String userIdString = "";
        for(int i = 0; i < mMembers.size(); i++){
            userIdString += mMembers.get(i).getAccount();
            userIdString += " ";
        }
        //TUIKitLog.i(TAG, "userIdString = " + userIdString);
        return userIdString;
    }

    private void init() {
        mMembers.clear();

        GroupInfo groupInfo = (GroupInfo) getIntent().getExtras().getSerializable(TUIKitConstants.Group.GROUP_INFO);
        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.sure), TitleBarLayout.POSITION.RIGHT);
        mTitleBar.getRightTitle().setTextColor(getResources().getColor(R.color.title_bar_font_color));
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                i.putExtra(TUIKitConstants.Selection.USER_NAMECARD_SELECT, getMembersNameCard());
                i.putExtra(TUIKitConstants.Selection.USER_ID_SELECT, getMembersUserId());
                setResult(3, i);

                finish();
            }
        });
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        mContactListView = findViewById(R.id.group_create_member_list);
        mContactListView.setGroupInfo(groupInfo);
        mContactListView.loadDataSource(ContactListView.DataSource.GROUP_MEMBER_LIST);
        mContactListView.setOnItemClickListener(new ContactListView.OnItemClickListener() {
            @Override
            public void onItemClick(int position, ContactItemBean contact) {
                if (position == 0) {
                    mMembers.clear();

                    Intent i = new Intent();
                    i.putExtra(TUIKitConstants.Selection.USER_NAMECARD_SELECT, getString(R.string.at_all));
                    i.putExtra(TUIKitConstants.Selection.USER_ID_SELECT, V2TIMGroupAtInfo.AT_ALL_TAG);
                    setResult(3, i);

                    finish();
                }
            }
        });
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getId());
                    memberInfo.setNameCard(TextUtils.isEmpty(contact.getNickname()) ? contact.getId() : contact.getNickname());
                    mMembers.add(memberInfo);
                } else {
                    for (int i = mMembers.size() - 1; i >= 0; i--) {
                        if (mMembers.get(i).getAccount().equals(contact.getId())) {
                            mMembers.remove(i);
                        }
                    }
                }
            }
        });
    }
}
