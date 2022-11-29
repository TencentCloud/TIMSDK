package com.tencent.qcloud.tuikit.tuicontact.classicui.pages;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactConstants;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactGroupApplyInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.classicui.util.ContactStartChatUtils;
import com.tencent.qcloud.tuikit.tuicontact.classicui.widget.FriendProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;

import java.util.ArrayList;
import java.util.HashMap;

public class FriendProfileActivity extends BaseLightActivity {

    private FriendProfilePresenter presenter;
    private FriendProfileLayout layout;
    private String mChatId;
    private String mChatBackgroundThumbnailUrl;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.contact_friend_profile_activity);
        layout = findViewById(R.id.friend_profile);

        presenter = new FriendProfilePresenter();
        layout.setPresenter(presenter);
        presenter.setFriendProfileLayout(layout);
        Intent intent = getIntent();
        mChatId = intent.getStringExtra(TUIConstants.TUIChat.CHAT_ID);
        mChatBackgroundThumbnailUrl = intent.getStringExtra(TUIConstants.TUIChat.CHAT_BACKGROUND_URI);
        String fromUser = intent.getStringExtra("fromUser");
        String fromUserNickName = intent.getStringExtra("fromUserNickName");
        String requestMsg = intent.getStringExtra("requestMsg");
        V2TIMGroupApplication application = (V2TIMGroupApplication) intent.getSerializableExtra("groupApplication");

        if (!TextUtils.isEmpty(mChatId)) {
            layout.initData(mChatId);
        } else if (!TextUtils.isEmpty(fromUser)) {
            ContactGroupApplyInfo contactGroupApplyInfo = new ContactGroupApplyInfo();
            contactGroupApplyInfo.setFromUser(fromUser);
            contactGroupApplyInfo.setFromUserNickName(fromUserNickName);
            contactGroupApplyInfo.setRequestMsg(requestMsg);
            contactGroupApplyInfo.setTimGroupApplication(application);
            layout.initData(contactGroupApplyInfo);
        } else {
            layout.initData(intent.getSerializableExtra(TUIContactConstants.ProfileType.CONTENT));
        }
        layout.setOnButtonClickListener(new FriendProfileLayout.OnButtonClickListener() {
            @Override
            public void onStartConversationClick(ContactItemBean info) {
                String chatName = info.getId();
                if (!TextUtils.isEmpty(info.getRemark())) {
                    chatName = info.getRemark();
                } else if (!TextUtils.isEmpty(info.getNickName())) {
                    chatName = info.getNickName();
                }
                ContactStartChatUtils.startChatActivity(info.getId(), ContactItemBean.TYPE_C2C, chatName, "");
            }

            @Override
            public void onDeleteFriendClick(String id) {
                finish();
            }

            @Override
            public void onSetChatBackground() {
                ArrayList<ImageSelectActivity.ImageBean> faceList = new ArrayList<>();
                ImageSelectActivity.ImageBean defaultFace = new ImageSelectActivity.ImageBean();
                defaultFace.setDefault(true);
                faceList.add(defaultFace);
                for (int i = 0; i < TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_COUNT; i++) {
                    ImageSelectActivity.ImageBean imageBean = new ImageSelectActivity.ImageBean();
                    imageBean.setImageUri(String.format(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_URL, (i + 1) + ""));
                    imageBean.setThumbnailUri(String.format(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_THUMBNAIL_URL, (i + 1) + ""));
                    faceList.add(imageBean);
                }

                Intent intent = new Intent(FriendProfileActivity.this, ImageSelectActivity.class);
                intent.putExtra(ImageSelectActivity.TITLE, getResources().getString(R.string.chat_background_title));
                intent.putExtra(ImageSelectActivity.SPAN_COUNT, 2);
                intent.putExtra(ImageSelectActivity.ITEM_WIDTH, ScreenUtil.dip2px(186));
                intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, ScreenUtil.dip2px(124));
                intent.putExtra(ImageSelectActivity.DATA, faceList);
                if (TextUtils.isEmpty(mChatBackgroundThumbnailUrl) || TextUtils.equals(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL, mChatBackgroundThumbnailUrl)) {
                    intent.putExtra(ImageSelectActivity.SELECTED, defaultFace);
                } else {
                    intent.putExtra(ImageSelectActivity.SELECTED, new ImageSelectActivity.ImageBean(mChatBackgroundThumbnailUrl, "", false));
                }
                intent.putExtra(ImageSelectActivity.NEED_DOWLOAD_LOCAL, true);
                startActivityForResult(intent, TUIConstants.TUIChat.CHAT_REQUEST_BACKGROUND_CODE);
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == TUIConstants.TUIChat.CHAT_REQUEST_BACKGROUND_CODE) {
            if (data == null) {
                return;
            }
            ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) data.getSerializableExtra(ImageSelectActivity.DATA);
            if (imageBean == null) {
                TUIContactLog.e("FriendProfileActivity", "onActivityResult imageBean is null");
                return;
            }

            String backgroundUri = imageBean.getLocalPath();
            String thumbnailUri = imageBean.getThumbnailUri();
            String dataUri = thumbnailUri + "," + backgroundUri;
            TUIContactLog.d("FriendProfileActivity", "onActivityResult backgroundUri = " + backgroundUri);
            mChatBackgroundThumbnailUrl = thumbnailUri;
            HashMap<String, Object> param = new HashMap<>();
            param.put(TUIConstants.TUIChat.CHAT_ID, mChatId);
            param.put(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, dataUri);
            TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_UPDATE_DATA_STORE_CHAT_URI, param);
        }
    }

}
