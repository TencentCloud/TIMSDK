package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.profile.GroupInfoLayout;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupProfilePresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;

public class GroupInfoFragment extends Fragment  {
    private static final String TAG = "GroupInfoFragment";

    private View baseView;
    private GroupInfoLayout groupInfoLayout;

    private String groupId;

    private String mChatBackgroundThumbnailUrl;

    private GroupProfilePresenter groupProfilePresenter = new GroupProfilePresenter();

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        baseView = inflater.inflate(R.layout.group_info_fragment, container, false);
        initView();
        return baseView;
    }

    private void initView() {
        Bundle bundle = getArguments();
        if (bundle == null) {
            ToastUtil.toastShortMessage("groupId is empty. bundle is null");
            return;
        }
        groupId = bundle.getString(TUIChatConstants.Group.GROUP_ID);
        mChatBackgroundThumbnailUrl = bundle.getString(TUIChatConstants.CHAT_BACKGROUND_URI);
        groupInfoLayout = baseView.findViewById(R.id.group_info_layout);
        groupInfoLayout.setGroupProfilePresenter(groupProfilePresenter);
        groupProfilePresenter.loadGroupProfile(groupId);

        groupInfoLayout.setOnChangeChatBackgroundListener(new GroupInfoLayout.OnChangeChatBackgroundListener() {
            @Override
            public void onChangeChatBackground() {
                startSetChatBackground();
            }
        });
    }

    private void startSetChatBackground() {
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

        Intent intent = new Intent();
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

        TUICore.startActivityForResult(this, ImageSelectActivity.class, intent.getExtras(), new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result.getData() == null) {
                    return;
                }
                ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) result.getData().getSerializableExtra(ImageSelectActivity.DATA);
                if (imageBean == null) {
                    TUIChatLog.e("GroupInfoFragment", "onActivityResult imageBean is null");
                    return;
                }

                String backgroundUri = imageBean.getLocalPath();
                String thumbnailUri = imageBean.getThumbnailUri();
                TUIChatLog.d("GroupInfoFragment", "onActivityResult backgroundUri = " + backgroundUri);
                mChatBackgroundThumbnailUrl = thumbnailUri;
                String dataUri = thumbnailUri + "," + backgroundUri;
                TUIChatService.getInstance().setChatBackground(groupId, dataUri);
            }
        });
    }

}
