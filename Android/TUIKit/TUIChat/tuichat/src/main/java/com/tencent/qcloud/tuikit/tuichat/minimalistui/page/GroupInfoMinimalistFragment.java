package com.tencent.qcloud.tuikit.tuichat.minimalistui.page;

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
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectMinimalistActivity;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.profile.GroupInfoLayout;
import com.tencent.qcloud.tuikit.tuichat.presenter.GroupProfilePresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.ArrayList;
import java.util.HashMap;

public class GroupInfoMinimalistFragment extends Fragment {
    private static final String TAG = "GroupInfoMinimalistFragment";
    private View baseView;
    private GroupInfoLayout groupInfoLayout;

    private String groupId;

    private String mChatBackgroundThumbnailUrl;

    private final GroupProfilePresenter groupProfilePresenter = new GroupProfilePresenter();

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        baseView = inflater.inflate(R.layout.chat_group_minimalist_info_fragment, container, false);
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
        groupProfilePresenter.loadSelfInfo(groupId);

        groupInfoLayout.setOnChangeChatBackgroundListener(new GroupInfoLayout.OnChangeChatBackgroundListener() {
            @Override
            public void onChangeChatBackground() {
                startSetChatBackground();
            }
        });
    }

    private void startSetChatBackground() {
        ArrayList<ImageSelectMinimalistActivity.ImageBean> faceList = new ArrayList<>();
        ImageSelectMinimalistActivity.ImageBean defaultFace = new ImageSelectMinimalistActivity.ImageBean();
        defaultFace.setDefault(true);
        faceList.add(defaultFace);
        for (int i = 0; i < TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_COUNT; i++) {
            ImageSelectMinimalistActivity.ImageBean imageBean = new ImageSelectMinimalistActivity.ImageBean();
            imageBean.setImageUri(String.format(TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_URL, (i + 1) + ""));
            imageBean.setThumbnailUri(String.format(TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_THUMBNAIL_URL, (i + 1) + ""));
            faceList.add(imageBean);
        }

        Bundle param = new Bundle();
        param.putString(ImageSelectMinimalistActivity.TITLE, getResources().getString(R.string.chat_background_title));
        param.putInt(ImageSelectMinimalistActivity.SPAN_COUNT, 2);
        int itemWidth = (int) (ScreenUtil.getScreenWidth(TUIChatService.getAppContext()) * 0.42f);
        int itemHeight = (int) (itemWidth / 1.5f);
        param.putInt(ImageSelectActivity.ITEM_WIDTH, itemWidth);
        param.putInt(ImageSelectActivity.ITEM_HEIGHT, itemHeight);
        param.putSerializable(ImageSelectMinimalistActivity.DATA, faceList);
        if (TextUtils.isEmpty(mChatBackgroundThumbnailUrl)
            || TextUtils.equals(TUIChatConstants.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL, mChatBackgroundThumbnailUrl)) {
            param.putSerializable(ImageSelectMinimalistActivity.SELECTED, defaultFace);
        } else {
            param.putSerializable(ImageSelectMinimalistActivity.SELECTED, new ImageSelectMinimalistActivity.ImageBean(mChatBackgroundThumbnailUrl, "", false));
        }
        param.putBoolean(ImageSelectMinimalistActivity.NEED_DOWLOAD_LOCAL, true);

        TUICore.startActivityForResult(
            GroupInfoMinimalistFragment.this, ImageSelectMinimalistActivity.class, param, new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    Intent data = result.getData();
                    if (data == null) {
                        return;
                    }
                    ImageSelectMinimalistActivity.ImageBean imageBean =
                        (ImageSelectMinimalistActivity.ImageBean) data.getSerializableExtra(ImageSelectMinimalistActivity.DATA);
                    if (imageBean == null) {
                        TUIChatLog.e("GroupInfoMinimalistFragment", "onActivityResult imageBean is null");
                        return;
                    }

                    String backgroundUri = imageBean.getLocalPath();
                    String thumbnailUri = imageBean.getThumbnailUri();
                    TUIChatLog.d("GroupInfoMinimalistFragment", "onActivityResult backgroundUri = " + backgroundUri);
                    mChatBackgroundThumbnailUrl = thumbnailUri;
                    HashMap<String, Object> param = new HashMap<>();
                    param.put(TUIConstants.TUIChat.CHAT_ID, groupId);
                    String dataUri = thumbnailUri + "," + backgroundUri;
                    TUIChatService.getInstance().setChatBackground(groupId, dataUri);
                }
            });
    }
}
