package com.tencent.qcloud.tuikit.tuicontact.minimalistui.pages;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.activities.SelectionActivity;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.util.ContactStartChatUtils;
import com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget.ContactListView;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;

import java.util.ArrayList;
import java.util.Arrays;

public class StartGroupChatMinimalistActivity extends BaseLightActivity {

    private static final String TAG = StartGroupChatMinimalistActivity.class.getSimpleName();

    private TitleBarLayout mTitleBar;
    private ContactListView mContactListView;
    private LineControllerView mJoinType;
    private ArrayList<GroupMemberInfo> mMembers = new ArrayList<>();
    private int mGroupType = -1;
    private boolean communitySupportTopic = false;
    private int mJoinTypeIndex = 2;
    private ArrayList<String> mJoinTypes = new ArrayList<>();
    private ArrayList<String> mGroupTypeValue = new ArrayList<>();
    private boolean mCreating;
    private RecyclerView selectedList;
    private StartGroupMemberSelectMinimalistActivity.SelectedAdapter selectedListAdapter;
    private TextView confirmButton;
    private ContactPresenter presenter;
    private GroupMemberInfo selfInfo;
    private int limit;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.minimalist_popup_start_group_chat_activity);
        selfInfo = new GroupMemberInfo();
        selfInfo.setAccount(ContactUtils.getLoginUser());
        selfInfo.setNickName(TUIConfig.getSelfNickName());
        init();
    }

    private void init() {
        limit = getIntent().getIntExtra(TUIContactConstants.Selection.LIMIT, Integer.MAX_VALUE);
        String[] array = getResources().getStringArray(R.array.group_type);
        mGroupTypeValue.addAll(Arrays.asList(array));
        array = getResources().getStringArray(R.array.group_join_type);
        mJoinTypes.addAll(Arrays.asList(array));

        mTitleBar = findViewById(R.id.group_create_title_bar);
        mTitleBar.setTitle(getResources().getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toCreateGroupChat();
            }
        });
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
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
        mJoinType.setContent(mJoinTypes.get(2));

        mContactListView = findViewById(R.id.group_create_member_list);
        confirmButton = findViewById(R.id.confirm_button);
        selectedList = findViewById(R.id.selected_list);
        selectedListAdapter = new StartGroupMemberSelectMinimalistActivity.SelectedAdapter();
        selectedList.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        selectedList.setAdapter(selectedListAdapter);
        presenter = new ContactPresenter();
        presenter.setFriendListListener();
        mContactListView.setPresenter(presenter);
        presenter.setContactListView(mContactListView);

        ArrayList<String> alreadySelectedList = new ArrayList<>();
        alreadySelectedList.add(TUILogin.getLoginUser());
        mContactListView.setAlreadySelectedList(alreadySelectedList);
        mContactListView.loadDataSource(ContactListView.DataSource.FRIEND_LIST);
        mContactListView.setOnSelectChangeListener(new ContactListView.OnSelectChangedListener() {
            @Override
            public void onSelectChanged(ContactItemBean contact, boolean selected) {
                if (selected) {
                    GroupMemberInfo memberInfo = new GroupMemberInfo();
                    memberInfo.setAccount(contact.getId());
                    memberInfo.setNickName(contact.getNickName());
                    memberInfo.setIconUrl(contact.getAvatarUrl());
                    mMembers.add(memberInfo);
                } else {
                    for (int i = mMembers.size() - 1; i >= 0; i--) {
                        if (mMembers.get(i).getAccount().equals(contact.getId())) {
                            mMembers.remove(i);
                        }
                    }
                }
                selectedListAdapter.setMembers(mMembers);
                selectedListAdapter.notifyDataSetChanged();
                if (mMembers.size() > 0) {
                    confirmButton.setAlpha(1f);
                    confirmButton.setEnabled(true);
                } else {
                    confirmButton.setAlpha(0.5f);
                    confirmButton.setEnabled(false);
                }
            }
        });
        confirmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                toCreateGroupChat();
            }
        });
        confirmButton.setAlpha(0.5f);
        confirmButton.setEnabled(false);
        Intent intent = getIntent();
        communitySupportTopic = intent.getBooleanExtra(TUIConstants.TUIContact.COMMUNITY_SUPPORT_TOPIC_KEY, false);
        setGroupType(intent.getIntExtra(TUIConstants.TUIContact.GROUP_TYPE_KEY, TUIContactConstants.GroupType.PRIVATE));
    }

    public void setGroupType(int type) {
        mGroupType = type;
        switch (type) {
            case TUIContactConstants.GroupType.PUBLIC:
                mTitleBar.setTitle(getResources().getString(R.string.create_group_chat), ITitleBarLayout.Position.MIDDLE);
                break;
            case TUIContactConstants.GroupType.CHAT_ROOM:
                mTitleBar.setTitle(getResources().getString(R.string.create_chat_room), ITitleBarLayout.Position.MIDDLE);
                break;
            case TUIContactConstants.GroupType.COMMUNITY:
                mTitleBar.setTitle(getResources().getString(R.string.create_community), ITitleBarLayout.Position.MIDDLE);
                break;
            case TUIContactConstants.GroupType.PRIVATE:
            default:
                mTitleBar.setTitle(getResources().getString(R.string.create_private_group), ITitleBarLayout.Position.MIDDLE);
                break;
        }
    }

    private void showJoinTypePickerView() {
        Bundle bundle = new Bundle();
        bundle.putString(SelectionActivity.Selection.TITLE, getResources().getString(R.string.group_join_type));
        bundle.putStringArrayList(SelectionActivity.Selection.LIST, mJoinTypes);
        bundle.putInt(SelectionActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, mJoinTypeIndex);
        SelectionActivity.startListSelection(this, bundle, new SelectionActivity.OnResultReturnListener() {
            @Override
            public void onReturn(Object text) {
                mJoinType.setContent(mJoinTypes.get((Integer) text));
                mJoinTypeIndex = (Integer) text;
            }
        });
    }

    private void toCreateGroupChat() {
        mMembers.add(0, selfInfo);
        if (mMembers.size() == 1) {
            ToastUtil.toastLongMessage(getResources().getString(R.string.tips_empty_group_member));
            return;
        }

        String groupName = selfInfo.getDisplayName();
        for (int i = 1; i < mMembers.size(); i++) {
            groupName = groupName + "、" + mMembers.get(i).getDisplayName();
        }
        if (groupName.length() >= 10) {
            groupName = groupName.substring(0, 7) + "..";
        }

        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIGroup.GROUP_NAME, groupName);
        bundle.putInt(TUIConstants.TUIGroup.JOIN_TYPE_INDEX, mJoinTypeIndex);
        bundle.putSerializable(TUIConstants.TUIGroup.GROUP_MEMBER_ID_LIST, mMembers);
        TUICore.startActivity("CreateGroupMinimalistActivity", bundle);
        finish();
    }

    private void createGroupChat() {
        if (mCreating) {
            return;
        }
        mMembers.add(0, selfInfo);
        if (mGroupType < 3 && mMembers.size() == 1) {
            ToastUtil.toastLongMessage(getResources().getString(R.string.tips_empty_group_member));
            return;
        }
        if (mGroupType > 0 && mJoinTypeIndex == -1) {
            ToastUtil.toastLongMessage(getResources().getString(R.string.tips_empty_group_type));
            return;
        }
        if (mGroupType == 0) {
            mJoinTypeIndex = -1;
        }
        final GroupInfo groupInfo = new GroupInfo();
        String groupName = selfInfo.getDisplayName();
        for (int i = 1; i < mMembers.size(); i++) {
            groupName = groupName + "、" + mMembers.get(i).getDisplayName();
        }
        if (groupName.length() >= 10) {
            groupName = groupName.substring(0, 7) + "..";
        }
        groupInfo.setChatName(groupName);
        groupInfo.setGroupName(groupName);
        groupInfo.setMemberDetails(mMembers);
        groupInfo.setGroupType(mGroupTypeValue.get(mGroupType));
        groupInfo.setJoinType(mJoinTypeIndex);
        groupInfo.setCommunitySupportTopic(communitySupportTopic);

        mCreating = true;

        presenter.createGroupChat(groupInfo, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                if (!communitySupportTopic) {
                    ContactStartChatUtils.startChatActivity(data, ChatInfo.TYPE_GROUP, groupInfo.getGroupName(), groupInfo.getGroupType());
                }
                finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mCreating = false;
                mMembers.remove(selfInfo);
                if (errCode == TUIConstants.BuyingFeature.ERR_SDK_INTERFACE_NOT_SUPPORT || errCode == 11000) {
                    showNotSupportDialog();
                }
                ToastUtil.toastLongMessage("createGroupChat fail:" + errCode + "=" + errMsg);
            }
        });
    }

    private void showNotSupportDialog() {
        String string = getResources().getString(R.string.contact_im_flagship_edition_update_tip, getString(R.string.contact_community));
        String buyingGuidelines = getResources().getString(R.string.contact_buying_guidelines);
        int buyingGuidelinesIndex = string.lastIndexOf(buyingGuidelines);
        final int foregroundColor = getResources().getColor(TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_primary_color));
        SpannableString spannedString = new SpannableString(string);
        ForegroundColorSpan colorSpan2 = new ForegroundColorSpan(foregroundColor);
        spannedString.setSpan(colorSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        ClickableSpan clickableSpan2 = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                if (TextUtils.equals(TUIThemeManager.getInstance().getCurrentLanguage(), "zh")) {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC);
                } else {
                    openWebUrl(TUIConstants.BuyingFeature.BUYING_PRICE_DESC_EN);
                }
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan2, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        TUIKitDialog.TUIIMUpdateDialog.getInstance()
                .createDialog(this)
                .setMovementMethod(LinkMovementMethod.getInstance())
                .setShowOnlyDebug(true)
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(spannedString)
                .setDialogWidth(0.75f)
                .setDialogFeatureName(TUIConstants.BuyingFeature.BUYING_FEATURE_COMMUNITY)
                .setPositiveButton(getString(R.string.contact_no_more_reminders), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().setNeverShow(true);
                    }
                })
                .setNegativeButton(getString(R.string.contact_i_know), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                    }
                })
                .show();
    }

    private void openWebUrl(String url) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri contentUrl = Uri.parse(url);
        intent.setData(contentUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }
}
