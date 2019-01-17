package com.tencent.qcloud.uikit.business.chat.group.view;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.SearchView;
import android.widget.TextView;

import com.tencent.imsdk.TIMManager;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatInfo;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupChatManager;
import com.tencent.qcloud.uikit.business.chat.group.model.GroupMemberInfo;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;
import com.tencent.qcloud.uikit.business.contact.view.ContactList;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.qcloud.uikit.common.component.datepicker.builder.OptionsPickerBuilder;
import com.tencent.qcloud.uikit.common.component.datepicker.listener.OnOptionsSelectListener;
import com.tencent.qcloud.uikit.common.component.datepicker.view.OptionsPickerView;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uikit.common.utils.SoftKeyBoardUtil;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uikit.common.widget.InfoItemView;
import com.tencent.qcloud.uikit.operation.message.UIKitRequest;
import com.tencent.qcloud.uikit.operation.message.UIKitRequestDispatcher;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by valexhuang on 2018/10/8.
 */

public class GroupCreatePanel extends LinearLayout {
    private PageTitleBar mTitleBar;
    private SearchView mUserSearch;
    private ContactList mContactList;
    private EditText mGroupName;
    private EditText mGroupNotice;
    private TextView mGroupType;
    private InfoItemView mJoinType;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();
    private int groupTypeIndex = -1, joinTypeIndex = 2;
    List<String> groupTypes = new ArrayList<>();
    List<String> joinTypes = new ArrayList<>();
    List<String> groupTypeValue = new ArrayList<>();
    private boolean creating;


    public GroupCreatePanel(Context context) {
        super(context);
        init();
    }

    public GroupCreatePanel(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public GroupCreatePanel(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {

        inflate(getContext(), R.layout.group_create_panel, this);

        //群类型：私有群（Private）、公开群（Public）、聊天室（ChatRoom）、互动直播聊天室（AVChatRoom）和在线成员广播大群（BChatRoom）
        String array[] = getResources().getStringArray(R.array.group_type_name);
        for (int i = 0; i < array.length; i++) {
            groupTypes.add(array[i]);
        }
        array = getResources().getStringArray(R.array.group_type);
        for (int i = 0; i < array.length; i++) {
            groupTypeValue.add(array[i]);
        }
        array = getResources().getStringArray(R.array.group_join_type);
        for (int i = 0; i < array.length; i++) {
            joinTypes.add(array[i]);
        }
        GroupMemberInfo memberInfo = new GroupMemberInfo();
        memberInfo.setAccount(TIMManager.getInstance().getLoginUser());
        mMembers.add(0, memberInfo);
        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.create_group_chat), PageTitleBar.POSITION.CENTER);
        mTitleBar.setTitle(getResources().getString(R.string.sure), PageTitleBar.POSITION.RIGHT);
        mTitleBar.getRightTitle().setTextColor(getResources().getColor(R.color.title_bar_font_color));
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setRightClick(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                createGroupChat();
            }
        });

        mGroupName = findViewById(R.id.group_create_group_name);
        mGroupNotice = findViewById(R.id.group_create_group_notice);

        mGroupType = findViewById(R.id.group_create_group_type);
        findViewById(R.id.group_type_group).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SoftKeyBoardUtil.hideKeyBoard(mGroupName);
                showGroupTypePickerView();
            }
        });

        mJoinType = findViewById(R.id.group_type_join);
        mJoinType.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SoftKeyBoardUtil.hideKeyBoard(mGroupName);
                showJoinTypePickerView();
            }
        });
        mJoinType.setValue(joinTypes.get(2));

        mUserSearch = findViewById(R.id.group_user_search);
        mUserSearch.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                return false;
            }
        });

        int id = mUserSearch.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
        TextView textView = (TextView) mUserSearch.findViewById(id);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);

        mContactList = findViewById(R.id.group_create_member_list);
        mContactList.setSelectChangeListener(new ContactList.ContactSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactInfoBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getIdentifier());
                    mMembers.add(memberInfo);
                } else {
                    for (int i = 0; i < mMembers.size(); i++) {
                        if (mMembers.get(i).getAccount().equals(contact.getIdentifier()))
                            mMembers.remove(i);
                    }

                }

            }
        });
        List contacts = new ArrayList();
        array = getResources().getStringArray(R.array.contact);
        for (int i = 0; i < array.length; i++) {
            ContactInfoBean contact = new ContactInfoBean();
            contact.setIdentifier(array[i]);
            contacts.add(contact);
        }
        mContactList.setDatas(contacts);

    }


    private void showGroupTypePickerView() {
        OptionsPickerBuilder typeBuilder = new OptionsPickerBuilder(getContext(), new OnOptionsSelectListener() {
            @Override
            public void onOptionsSelect(int options1, int options2, int options3, View v) {
                mGroupType.setText(groupTypes.get(options1));
                groupTypeIndex = options1;
                if (options1 > 2) {
                    mContactList.setVisibility(View.GONE);
                } else {
                    mContactList.setVisibility(View.VISIBLE);
                }
                if (options1 == 0)
                    mJoinType.setVisibility(View.GONE);
                else
                    mJoinType.setVisibility(View.VISIBLE);

            }
        }).isDialog(false).setCancelText(getResources().getString(R.string.cancel)).setSubmitText(getResources().getString(R.string.sure));
        OptionsPickerView mTypePicker = typeBuilder.build();

        mTypePicker.setPicker(groupTypes);
        Dialog mDialog = mTypePicker.getDialog();
        if (mDialog != null) {
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    Gravity.BOTTOM);

            params.leftMargin = 0;
            params.rightMargin = 0;
            mTypePicker.getDialogContainerLayout().setLayoutParams(params);

            Window dialogWindow = mDialog.getWindow();
            if (dialogWindow != null) {
                dialogWindow.setWindowAnimations(R.style.picker_view_slide_anim);//修改动画样式
                dialogWindow.setGravity(Gravity.BOTTOM);//改成Bottom,底部显示
            }
        }
        mTypePicker.show();
    }


    private void showJoinTypePickerView() {
        OptionsPickerBuilder typeBuilder = new OptionsPickerBuilder(getContext(), new OnOptionsSelectListener() {
            @Override
            public void onOptionsSelect(int options1, int options2, int options3, View v) {
                mJoinType.setValue(joinTypes.get(options1));
                joinTypeIndex = options1;
            }
        }).isDialog(false).setCancelText(getResources().getString(R.string.cancel)).setSubmitText(getResources().getString(R.string.sure));
        OptionsPickerView mTypePicker = typeBuilder.build();

        mTypePicker.setPicker(joinTypes);
        Dialog mDialog = mTypePicker.getDialog();
        if (mDialog != null) {
            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    Gravity.BOTTOM);

            params.leftMargin = 0;
            params.rightMargin = 0;
            mTypePicker.getDialogContainerLayout().setLayoutParams(params);

            Window dialogWindow = mDialog.getWindow();
            if (dialogWindow != null) {
                dialogWindow.setWindowAnimations(R.style.picker_view_slide_anim);//修改动画样式
                dialogWindow.setGravity(Gravity.BOTTOM);//改成Bottom,底部显示
            }
        }
        mTypePicker.show();
    }


    private void createGroupChat() {
        if (creating)
            return;
        if (TextUtils.isEmpty(mGroupType.getText())) {
            UIUtils.toastLongMessage(getResources().getString(R.string.input_group_type_empty_tips));
            return;
        }

        if (groupTypeIndex < 3 && mMembers.size() == 1) {
            UIUtils.toastLongMessage(getResources().getString(R.string.input_group_member_empty_tips));
            return;
        }
        if (groupTypeIndex > 0 && joinTypeIndex == -1) {
            UIUtils.toastLongMessage(getResources().getString(R.string.join_group_type_empty_tips));
            return;
        }
        if (groupTypeIndex == 0) {
            joinTypeIndex = -1;
        }
        GroupChatInfo groupChatInfo = new GroupChatInfo();
        String groupName = TIMManager.getInstance().getLoginUser();
        for (int i = 1; i < mMembers.size(); i++) {
            groupName = groupName + "、" + mMembers.get(i).getAccount();
        }
        if (groupName.length() > 20) {
            groupName = groupName.substring(0, 17) + "...";
        }
        groupChatInfo.setChatName(groupName);
        groupChatInfo.setGroupName(groupName);
        groupChatInfo.setMemberDetails(mMembers);
        groupChatInfo.setGroupType(groupTypeValue.get(groupTypeIndex));
        groupChatInfo.setJoinType(joinTypeIndex);
        groupChatInfo.setNotice(mGroupNotice.getText().toString());

        creating = true;
        GroupChatManager.getInstance().createGroupChat(groupChatInfo, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                MessageInfo msg = (MessageInfo) data;
                SessionInfo sessionInfo = new SessionInfo();
                sessionInfo.setGroup(true);
                sessionInfo.setTitle(mGroupName.getText().toString());
                sessionInfo.setPeer(((MessageInfo) data).getPeer());
                sessionInfo.setLastMessage(msg);
                UIKitRequest request = new UIKitRequest();
                request.setModel(UIKitRequestDispatcher.MODEL_SESSION);
                request.setAction(UIKitRequestDispatcher.SESSION_ACTION_START_CHAT);
                request.setRequest(sessionInfo);
                UIKitRequestDispatcher.getInstance().dispatchRequest(request);
                ((Activity) getContext()).finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                creating = false;
                UIUtils.toastLongMessage("createGroupChat fail:" + errCode + "=" + errMsg);
            }
        });


    }

    public PageTitleBar getTitleBar() {
        return mTitleBar;
    }


}
