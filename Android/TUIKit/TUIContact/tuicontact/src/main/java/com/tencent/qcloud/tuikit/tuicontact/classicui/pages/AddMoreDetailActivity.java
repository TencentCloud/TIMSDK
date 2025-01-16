package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Pair;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.LineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.TUIUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuicontact.presenter.AddMorePresenter;
import com.tencent.qcloud.tuikit.tuicontact.presenter.ContactPresenter;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

public class AddMoreDetailActivity extends BaseLightActivity {
    private static final String TAG = "AddMoreDetailActivity";

    private TitleBarLayout mTitleBar;
    private ImageView mHeadImageView;
    private TextView mNickNameView;
    private TextView mIDView;
    private TextView mSignatureView;
    private TextView mSignatureTag;
    private View remarksArea;
    private LineControllerView addFriendRemarkLv;

    private TextView addSendBtn;
    private View verifyArea;
    private EditText addWordingEditText;

    private FriendProfilePresenter presenter = new FriendProfilePresenter();
    private AddMorePresenter addMorePresenter = new AddMorePresenter();
    private Object data;
    private String userID;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contact_add_more_detail_activity);

        mHeadImageView = findViewById(R.id.friend_icon);
        mNickNameView = findViewById(R.id.friend_nick_name);
        mIDView = findViewById(R.id.friend_account);
        mSignatureView = findViewById(R.id.friend_signature);
        mSignatureTag = findViewById(R.id.friend_signature_tag);
        remarksArea = findViewById(R.id.remarks_area);
        addSendBtn = findViewById(R.id.add_send_btn);

        verifyArea = findViewById(R.id.verify_area);
        addWordingEditText = findViewById(R.id.add_wording_edit);

        addFriendRemarkLv = findViewById(R.id.friend_remark_lv);

        mTitleBar = findViewById(R.id.add_more_detail_title_bar);
        mTitleBar.getRightGroup().setVisibility(View.GONE);

        Intent intent = getIntent();
        data = intent.getSerializableExtra(TUIConstants.TUIContact.CONTENT);
        userID = intent.getStringExtra(TUIConstants.TUIContact.USER_ID);
        if (data instanceof GroupInfo) {
            setGroupDetail((GroupInfo) data);
            remarksArea.setVisibility(View.GONE);
            mTitleBar.setTitle(getResources().getString(R.string.add_group), ITitleBarLayout.Position.MIDDLE);
        } else if (data instanceof ContactItemBean) {
            setFriendDetail((ContactItemBean) data);
            mTitleBar.setTitle(getResources().getString(R.string.add_friend), ITitleBarLayout.Position.MIDDLE);
        } else if (!TextUtils.isEmpty(userID)) {
            mTitleBar.setTitle(getResources().getString(R.string.add_friend), ITitleBarLayout.Position.MIDDLE);
            addMorePresenter.getUserInfo(userID, new TUIValueCallback<ContactItemBean>() {
                @Override
                public void onSuccess(ContactItemBean object) {
                    setFriendDetail(object);
                }

                @Override
                public void onError(int errorCode, String errorMessage) {
                    TUIContactLog.e(TAG, "get user info failed, userId: " + data);
                }
            });
        }

        setOnClickListener();
    }

    private void setOnClickListener() {
        addFriendRemarkLv.setOnClickListener(v -> {
            PopupInputCard popupInputCard = new PopupInputCard(AddMoreDetailActivity.this);
            popupInputCard.setContent(addFriendRemarkLv.getContent());
            popupInputCard.setTitle(getResources().getString(R.string.contact_friend_remark));
            popupInputCard.setOnPositive((result -> addFriendRemarkLv.setContent(result)));
            popupInputCard.show(addFriendRemarkLv, Gravity.BOTTOM);
        });

        addSendBtn.setOnClickListener(v -> {
            String addWording = addWordingEditText.getText().toString();
            if (data instanceof GroupInfo) {
                presenter.joinGroup(((GroupInfo) data).getId(), addWording, new IUIKitCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        ToastUtil.toastShortMessage(getString(R.string.success));
                        finish();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage(getString(R.string.contact_add_failed) + " " + errMsg);
                    }
                });
            } else if (data instanceof ContactItemBean || !TextUtils.isEmpty(userID)) {
                String remark = addFriendRemarkLv.getContent();
                String friendID = userID;
                if (data instanceof ContactItemBean) {
                    friendID = ((ContactItemBean) data).getId();
                }
                presenter.addFriend(friendID, addWording, remark, new IUIKitCallback<Pair<Integer, String>>() {
                    @Override
                    public void onSuccess(Pair<Integer, String> data) {
                        ToastUtil.toastShortMessage(data.second);
                        finish();
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        ToastUtil.toastShortMessage(getString(R.string.contact_add_failed));
                    }
                });
            }
        });
    }

    private void setGroupDetail(GroupInfo groupInfo) {
        int radius = ScreenUtil.dip2px(35);
        GlideEngine.loadUserIcon(mHeadImageView, groupInfo.getFaceUrl(), TUIUtil.getDefaultGroupIconResIDByGroupType(this, groupInfo.getGroupType()), radius);
        mIDView.setText(groupInfo.getId());
        mNickNameView.setText(groupInfo.getGroupName());
        mSignatureTag.setText(getString(R.string.contact_group_type_tag));
        mSignatureView.setText(groupInfo.getGroupType());
    }

    private void setFriendDetail(ContactItemBean bean) {
        int radius = ScreenUtil.dip2px(35);
        GlideEngine.loadUserIcon(mHeadImageView, bean.getAvatarUrl(), radius);
        mIDView.setText(bean.getId());
        mNickNameView.setText(bean.getDisplayName());
        mSignatureView.setText(bean.getSignature());
    }
}
