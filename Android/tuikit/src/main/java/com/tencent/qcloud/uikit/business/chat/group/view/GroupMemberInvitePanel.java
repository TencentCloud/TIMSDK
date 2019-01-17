package com.tencent.qcloud.uikit.business.chat.group.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;
import com.tencent.qcloud.uikit.business.contact.view.ContactList;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.common.BaseFragment;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.UIUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class GroupMemberInvitePanel extends LinearLayout {
    private PageTitleBar mTitleBar;
    private ContactList mContactList;
    private List<String> mInviteMembers = new ArrayList<>();
    private Object parentContainer;

    public GroupMemberInvitePanel(Context context) {
        super(context);
        init();
    }

    public GroupMemberInvitePanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupMemberInvitePanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.group_member_invite_panel, this);
        mTitleBar = findViewById(R.id.group_invite_title_bar);
        mTitleBar.setTitle("确定", PageTitleBar.POSITION.RIGHT);
        mTitleBar.setTitle("添加成员", PageTitleBar.POSITION.CENTER);
        mTitleBar.getRightTitle().setTextColor(Color.BLUE);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setRightClick(new OnClickListener() {
            @Override
            public void onClick(View v) {
                GroupChatManager.getInstance().inviteGroupMembers(mInviteMembers, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        if (data instanceof String) {
                            UIUtils.toastLongMessage(data.toString());
                        } else {
                            UIUtils.toastLongMessage("邀请成员成功");
                        }
                        mInviteMembers.clear();
                        finish();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        UIUtils.toastLongMessage("邀请成员失败:" + errCode + "=" + errMsg);
                    }
                });
            }
        });
        mContactList = findViewById(R.id.group_invite_member_list);
        mContactList.setSelectChangeListener(new ContactList.ContactSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactInfoBean contact, boolean selected) {
                if (selected)
                    mInviteMembers.add(contact.getIdentifier());
                else
                    mInviteMembers.remove(contact.getIdentifier());
                if (mInviteMembers.size() > 0)
                    mTitleBar.setTitle("确定（" + mInviteMembers.size() + "）", PageTitleBar.POSITION.RIGHT);
                else
                    mTitleBar.setTitle("确定", PageTitleBar.POSITION.RIGHT);

            }
        });
        initContacts();
    }


    private void initContacts() {
        List contacts = new ArrayList();
        String[] array = getResources().getStringArray(R.array.contact);
        for (int i = 0; i < array.length; i++) {
            ContactInfoBean contact = new ContactInfoBean();
            contact.setIdentifier(array[i]);
            contacts.add(contact);
        }
        mContactList.setDatas(contacts);
    }

    public PageTitleBar getTitleBar() {
        return mTitleBar;
    }

    public void setParent(Object parent) {
        parentContainer = parent;
    }

    private void finish() {
        if (parentContainer instanceof Activity) {
            ((Activity) parentContainer).finish();
        } else if (parentContainer instanceof BaseFragment) {
            ((BaseFragment) parentContainer).backward();
        }
    }

}
