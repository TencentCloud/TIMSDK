package com.tencent.qcloud.tim.uikit.modules.forward;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseActvity;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tim.uikit.component.LineControllerView;
import com.tencent.qcloud.tim.uikit.component.SelectionActivity;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactItemBean;
import com.tencent.qcloud.tim.uikit.modules.contact.ContactListView;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.forward.base.ConversationBean;
import com.tencent.qcloud.tim.uikit.modules.group.info.GroupInfo;
import com.tencent.qcloud.tim.uikit.modules.group.member.GroupMemberInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class ForwardSelectGroupActivity extends BaseActvity {

    private static final String TAG = ForwardSelectGroupActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private LineControllerView mJoinType;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();
    private int mGroupType = -1;
    private int mJoinTypeIndex = 2;
    private ArrayList<String> mJoinTypes = new ArrayList<>();
    private ArrayList<String> mGroupTypeValue = new ArrayList<>();
    private boolean mCreating;
    private boolean isCreateNewChat = true;

    private RecyclerView mForwardSelectlistView;
    private ForwardContactSelectorAdapter mAdapter;
    private List<String> mSelectConversationIcons = new ArrayList<>();
    private RelativeLayout mForwardSelectlistViewLayout;
    private TextView mSureView;

    private List<ConversationInfo> mContactDataSource = new ArrayList<>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.forward_select_group_contact);

        init();
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

    private void RefreshMembers(){
        if (mContactDataSource == null || mContactDataSource.size() ==0){
            mMembers.clear();
            return;
        }

        for (int i=0;i<mContactDataSource.size();i++){
            GroupMemberInfo memberInfo = new GroupMemberInfo();
            memberInfo.setAccount(mContactDataSource.get(i).getId());
            memberInfo.setIconUrl((String)mContactDataSource.get(i).getIconUrlList().get(0));
            mMembers.add(memberInfo);
        }

    }

    private void init() {
        Intent intent = getIntent();
        if (intent != null){
            isCreateNewChat = intent.getIntExtra(ForwardSelectFragment.FORWARD_CREATE_NEW_CHAT, 0) == 1 ? true : false;
        }
        /*GroupMemberInfo memberInfo = new GroupMemberInfo();
        memberInfo.setAccount(V2TIMManager.getInstance().getLoginUser());
        mMembers.add(0, memberInfo);*/
        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateNewChat){
                    finish();
                } else {
                    finish();
                }
            }
        });

        mJoinType = findViewById(R.id.group_type_join);
        mJoinType.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showJoinTypePickerView();
            }
        });
        mJoinType.setCanNav(true);
        mJoinType.setContent("Public");
        mJoinType.setVisibility(View.GONE);

        mContactListView = findViewById(R.id.group_create_member_list);
        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getId());
                    memberInfo.setIconUrl(contact.getAvatarurl());
                    mMembers.add(memberInfo);
                } else {
                    for (int i = mMembers.size() - 1; i >= 0; i--) {
                        if (mMembers.get(i).getAccount().equals(contact.getId())) {
                            mMembers.remove(i);
                        }
                    }
                }
                RefreshSelectConversations();
            }
        });

        setGroupType(TUIKitConstants.GroupType.PUBLIC);

        mForwardSelectlistViewLayout = findViewById(R.id.forward_contact_select_list_layout);
        mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
        mForwardSelectlistView = findViewById(R.id.forward_contact_select_list);
        mForwardSelectlistView.setLayoutManager(new CustomLinearLayoutManager(this, CustomLinearLayoutManager.HORIZONTAL, false));
        mAdapter = new ForwardContactSelectorAdapter(this);
        mForwardSelectlistView.setAdapter(mAdapter);

        mSureView = findViewById(R.id.btn_msg_ok);
        mSureView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateNewChat){
                    createGroupChat();
                } else {
                    Intent intent = new Intent();
                    ArrayList<ConversationInfo> conversationBeans = new ArrayList<ConversationInfo>();
                    if (mMembers != null && mMembers.size() != 0){
                        for (int i=0;i<mMembers.size();i++){
                            ConversationInfo conversationInfo = new ConversationInfo();
                            conversationInfo.setId(mMembers.get(i).getAccount());
                            conversationInfo.setType(ConversationInfo.TYPE_COMMON);
                            conversationInfo.setGroup(false);
                            conversationInfo.setTitle(mMembers.get(i).getAccount());
                            List<Object> iconUrlList = new ArrayList<>();
                            iconUrlList.add(mMembers.get(i).getIconUrl());
                            conversationInfo.setIconUrlList(iconUrlList);

                            conversationBeans.add(conversationInfo);
                        }
                    }

                    intent.putExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationBeans);
                    setResult(TUIKitConstants.FORWARD_SELECT_MEMBERS_CODE, intent);

                    finish();
                }
            }
        });

        if (!isCreateNewChat){
           /* ArrayList<ConversationInfo> conversationBeans = (ArrayList<ConversationInfo>) intent.getSerializableExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY);
            if (conversationBeans == null || conversationBeans.isEmpty()){
                mContactDataSource.clear();
                RefreshMembers();
                RefreshSelectConversations();
                return;
            }

            mContactDataSource.clear();
            for (int i=0;i<conversationBeans.size();i++){
                mContactDataSource.add(conversationBeans.get(i));
            }

            RefreshMembers();
            RefreshSelectConversations();*/
           RefreshSelectConversations();
        } else {
            RefreshSelectConversations();
        }
    }

    /*private void storageSerializable(ConversationInfo conversationInfo) {
        FileOutputStream fos=null;
        ObjectOutputStream oos=null;

        try{
            File file=new File(ForwardSelectActivity.path);
            if (!file.getParentFile().exists()){
                file.getParentFile().mkdirs();//创建目录
            }

            if (!file.exists()){
                file.createNewFile();
            }
            fos=new FileOutputStream(file);
            oos=new ObjectOutputStream(fos);
            oos.writeObject(conversationInfo);
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            try {
                //在这里做资源的关闭
                if (oos!=null){
                    oos.close();
                }
                if (fos!=null){
                    fos.close();
                }

            }catch (Exception e){
                e.printStackTrace();
            }

        }
    }*/

    private void RefreshSelectConversations(){
        mSelectConversationIcons.clear();
        if (mMembers != null && mMembers.size() != 0){
            for (int i=0;i<mMembers.size();i++){
                mSelectConversationIcons.add(mMembers.get(i).getIconUrl());
            }
        }
        mAdapter.setDataSource(mSelectConversationIcons);

        if (mSelectConversationIcons == null || mSelectConversationIcons.size() == 0){
            mSureView.setText(getString(R.string.sure));
            mSureView.setVisibility(View.GONE);
            mForwardSelectlistViewLayout.setVisibility(View.GONE);
        } else {
            mForwardSelectlistViewLayout.setVisibility(View.VISIBLE);
            mSureView.setVisibility(View.VISIBLE);
            mSureView.setText(getString(R.string.sure) + "(" + mSelectConversationIcons.size() + ")");
        }
    }

    public void setGroupType(int type) {
        mGroupType = type;
        mTitleBar.setTitle(getResources().getString(R.string.contact_title), TitleBarLayout.POSITION.MIDDLE);
        mJoinType.setVisibility(View.GONE);
    }

    private void showJoinTypePickerView() {
        Bundle bundle = new Bundle();
        bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.group_join_type));
        bundle.putStringArrayList(TUIKitConstants.Selection.LIST, mJoinTypes);
        bundle.putInt(TUIKitConstants.Selection.DEFAULT_SELECT_ITEM_INDEX, mJoinTypeIndex);
        SelectionActivity.startListSelection(this, bundle, new SelectionActivity.OnResultReturnListener() {
            @Override
            public void onReturn(Object text) {
                mJoinType.setContent(mJoinTypes.get((Integer) text));
                mJoinTypeIndex = (Integer) text;
            }
        });
    }

    private void createGroupChat() {
        if (mCreating || mMembers.isEmpty()) {
            return;
        }
       
        if (mMembers.size() == 1){
            Intent intent = new Intent();
            ArrayList<ConversationBean> conversationBeans = new ArrayList<ConversationBean>();
            ConversationBean conversationBean = new ConversationBean();
            conversationBean.setConversationID(mMembers.get(0).getAccount());
            conversationBean.setTitle(mMembers.get(0).getAccount());
            conversationBean.setIsGroup(0);
            conversationBeans.add(conversationBean);
            //intent.putExtra(TUIKitConstants.FORWARD_MERGE_MESSAGE_KEY, conversationBean);
            intent.putParcelableArrayListExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationBeans);
            setResult(TUIKitConstants.FORWARD_CREATE_GROUP_CODE, intent);

            finish();
            return;
        }
        GroupMemberInfo memberInfo = new GroupMemberInfo();
        memberInfo.setAccount(V2TIMManager.getInstance().getLoginUser());
        mMembers.add(memberInfo);

        final GroupInfo groupInfo = new GroupInfo();
        String groupName = V2TIMManager.getInstance().getLoginUser();
        for (int i = 1; i < mMembers.size(); i++) {
            groupName = groupName + "、" + mMembers.get(i).getAccount();
        }
        if (groupName.length() > 20) {
            groupName = groupName.substring(0, 17) + "...";
        }
        groupInfo.setChatName(groupName);
        groupInfo.setGroupName(groupName);
        groupInfo.setMemberDetails(mMembers);
        groupInfo.setGroupType(TUIKitConstants.GroupType.TYPE_PUBLIC);
        groupInfo.setJoinType(0);

        mCreating = true;
        GroupChatManagerKit.createGroupChat(groupInfo, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                Intent intent = new Intent();
                ArrayList<ConversationBean> conversationBeans = new ArrayList<ConversationBean>();
                ConversationBean conversationBean = new ConversationBean();
                conversationBean.setConversationID(data.toString());
                conversationBean.setTitle(groupInfo.getGroupName());
                conversationBean.setIsGroup(1);
                conversationBeans.add(conversationBean);
                //intent.putExtra(TUIKitConstants.FORWARD_MERGE_MESSAGE_KEY, conversationBean);
                intent.putParcelableArrayListExtra(TUIKitConstants.FORWARD_SELECT_CONVERSATION_KEY, conversationBeans);
                setResult(TUIKitConstants.FORWARD_CREATE_GROUP_CODE, intent);

                finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mCreating = false;
                ToastUtil.toastLongMessage("createGroupChat fail:" + errCode + "=" + errMsg);
            }
        });
    }

}
