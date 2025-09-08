package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.profile.FriendProfileLayout;
import com.tencent.qcloud.tuikit.tuichat.presenter.FriendProfilePresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.HashMap;

public class FriendProfileActivity extends BaseLightActivity {
    private static final String TAG = "FriendProfileActivity";

    private final FriendProfilePresenter presenter = new FriendProfilePresenter();
    private FriendProfileLayout layout;
    private String userID;
    private String mChatBackgroundThumbnailUrl;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.contact_friend_profile_activity);
        layout = findViewById(R.id.friend_profile);
        Intent intent = getIntent();
        userID = intent.getStringExtra(TUIConstants.TUIContact.USER_ID);
        if (TextUtils.isEmpty(userID)) {
            userID = intent.getStringExtra(TUIConstants.TUIChat.CHAT_ID);
        }

        layout.setPresenter(presenter);
        layout.loadFriendProfile(userID);

        mChatBackgroundThumbnailUrl = intent.getStringExtra(TUIChatConstants.CHAT_BACKGROUND_URI);
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();

        layout.setOnButtonClickListener(new FriendProfileLayout.OnButtonClickListener() {

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
                for (int i = 0; i < TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_COUNT; i++) {
                    ImageSelectActivity.ImageBean imageBean = new ImageSelectActivity.ImageBean();
                    imageBean.setImageUri(String.format(TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_URL, (i + 1) + ""));
                    imageBean.setThumbnailUri(String.format(TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_THUMBNAIL_URL, (i + 1) + ""));
                    faceList.add(imageBean);
                }

                Intent intent = new Intent(FriendProfileActivity.this, ImageSelectActivity.class);
                intent.putExtra(ImageSelectActivity.TITLE, getResources().getString(R.string.chat_background_title));
                intent.putExtra(ImageSelectActivity.SPAN_COUNT, 2);
                int itemWidth = (int) (ScreenUtil.getScreenWidth(TUIChatService.getAppContext()) * 0.42f);
                int itemHeight = (int) (itemWidth / 1.5f);
                intent.putExtra(ImageSelectActivity.ITEM_WIDTH, itemWidth);
                intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, itemHeight);
                intent.putExtra(ImageSelectActivity.DATA, faceList);
                if (TextUtils.isEmpty(mChatBackgroundThumbnailUrl)
                        || TextUtils.equals(TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL, mChatBackgroundThumbnailUrl)) {
                    intent.putExtra(ImageSelectActivity.SELECTED, defaultFace);
                } else {
                    intent.putExtra(ImageSelectActivity.SELECTED, new ImageSelectActivity.ImageBean(mChatBackgroundThumbnailUrl, "", false));
                }
                intent.putExtra(ImageSelectActivity.NEED_DOWNLOAD_LOCAL, true);
                TUICore.startActivityForResult(FriendProfileActivity.this, intent, new ActivityResultCallback<ActivityResult>() {
                    @Override
                    public void onActivityResult(ActivityResult result) {
                        Intent data = result.getData();
                        if (data == null) {
                            return;
                        }
                        ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) data.getSerializableExtra(ImageSelectActivity.DATA);
                        if (imageBean == null) {
                            TUIChatLog.e(TAG, "onActivityResult imageBean is null");
                            return;
                        }

                        String backgroundUri = imageBean.getLocalPath();
                        String thumbnailUri = imageBean.getThumbnailUri();
                        TUIChatLog.d(TAG, "onActivityResult backgroundUri = " + backgroundUri);
                        mChatBackgroundThumbnailUrl = thumbnailUri;
                        String dataUri = thumbnailUri + "," + backgroundUri;
                        TUIChatService.getInstance().setChatBackground(userID, dataUri);
                    }
                });
            }
        });
    }

}
