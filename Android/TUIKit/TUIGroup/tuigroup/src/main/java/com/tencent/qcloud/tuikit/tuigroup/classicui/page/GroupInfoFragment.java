package com.tencent.qcloud.tuikit.tuigroup.classicui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.classicui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.classicui.widget.GroupInfoLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupLog;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class GroupInfoFragment extends BaseFragment {
    private static final int CHOOSE_AVATAR_REQUEST_CODE = 101;

    private View baseView;
    private GroupInfoLayout groupInfoLayout;

    private String groupId;

    private GroupInfoPresenter groupInfoPresenter = null;
    private String mChatBackgroundThumbnailUrl;

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
        groupId = bundle.getString(TUIGroupConstants.Group.GROUP_ID);
        mChatBackgroundThumbnailUrl = bundle.getString(TUIConstants.TUIChat.CHAT_BACKGROUND_URI);
        groupInfoLayout = baseView.findViewById(R.id.group_info_layout);
        // 新建 presenter 与 layout 互相绑定
        groupInfoPresenter = new GroupInfoPresenter(groupInfoLayout);
        groupInfoPresenter.setGroupEventListener();
        groupInfoLayout.setGroupInfoPresenter(groupInfoPresenter);
        groupInfoLayout.setOnModifyGroupAvatarListener(new OnModifyGroupAvatarListener() {
            @Override
            public void onModifyGroupAvatar(String originAvatarUrl) {
                startModifyGroupAvatar(originAvatarUrl);
            }
        });
        groupInfoLayout.loadGroupInfo(groupId);
        groupInfoLayout.setRouter(new IGroupMemberListener() {
            @Override
            public void forwardListMember(GroupInfo info) {
                Intent intent = new Intent(getContext(), GroupMemberActivity.class);
                intent.putExtra(TUIConstants.TUIGroup.IS_SELECT_MODE, false);
                intent.putExtra(TUIConstants.TUIGroup.GROUP_ID, info.getId());
                startActivity(intent);
            }

            @Override
            public void forwardAddMember(GroupInfo info) {
                startAddMember(info);
            }

            @Override
            public void forwardDeleteMember(GroupInfo info) {
                startDeleteMember(info);
            }

            @Override
            public void forwardShowMemberDetail(GroupMemberInfo info) {
                startShowMemberDetail(info);
            }
        });

        groupInfoLayout.setOnButtonClickListener(new GroupInfoLayout.OnButtonClickListener() {
            @Override
            public void onSetChatBackground() {
                startSetChatBackground();
            }

            @Override
            public void onChangeGroupOwner(String newOwnerID) {
                changeGroupOwner(newOwnerID);
            }
        });
    }

    private void startShowMemberDetail(GroupMemberInfo info) {
        Bundle bundle = new Bundle();
        bundle.putString(TUIConstants.TUIChat.CHAT_ID, info.getAccount());
        TUICore.startActivity("FriendProfileActivity", bundle);
    }

    private void startSetChatBackground() {
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

        Intent intent = new Intent();
        intent.putExtra(ImageSelectActivity.TITLE, getResources().getString(R.string.chat_background_title));
        intent.putExtra(ImageSelectActivity.SPAN_COUNT, 2);
        intent.putExtra(ImageSelectActivity.ITEM_WIDTH, ScreenUtil.dip2px(186));
        intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, ScreenUtil.dip2px(124));
        intent.putExtra(ImageSelectActivity.DATA, faceList);
        if (TextUtils.isEmpty(mChatBackgroundThumbnailUrl)
            || TextUtils.equals(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL, mChatBackgroundThumbnailUrl)) {
            intent.putExtra(ImageSelectActivity.SELECTED, defaultFace);
        } else {
            intent.putExtra(ImageSelectActivity.SELECTED, new ImageSelectActivity.ImageBean(mChatBackgroundThumbnailUrl, "", false));
        }
        intent.putExtra(ImageSelectActivity.NEED_DOWLOAD_LOCAL, true);

        TUICore.startActivityForResult(this, ImageSelectActivity.class, intent.getExtras(), new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result.getData() == null) {
                    return;
                }
                ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) result.getData().getSerializableExtra(ImageSelectActivity.DATA);
                if (imageBean == null) {
                    TUIGroupLog.e("GroupInfoFragment", "onActivityResult imageBean is null");
                    return;
                }

                String backgroundUri = imageBean.getLocalPath();
                String thumbnailUri = imageBean.getThumbnailUri();
                TUIGroupLog.d("GroupInfoFragment", "onActivityResult backgroundUri = " + backgroundUri);
                mChatBackgroundThumbnailUrl = thumbnailUri;
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIChat.CHAT_ID, groupId);
                String dataUri = thumbnailUri + "," + backgroundUri;
                param.put(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, dataUri);
                TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_UPDATE_DATA_STORE_CHAT_URI, param);
            }
        });
    }

    private void startDeleteMember(GroupInfo info) {
        Bundle param = new Bundle();
        param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, info.getId());
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FOR_CALL, true);

        TUICore.startActivityForResult(this, "StartGroupMemberSelectActivity", param, new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result.getData() != null) {
                    List<String> friends = (List<String>) result.getData().getSerializableExtra(TUIGroupConstants.Selection.LIST);
                    deleteGroupMembers(friends);
                }
            }
        });
    }

    private void startAddMember(GroupInfo info) {
        Bundle param = new Bundle();
        param.putString(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.GROUP_ID, info.getId());
        param.putBoolean(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECT_FRIENDS, true);
        ArrayList<String> selectedList = new ArrayList<>();
        for (GroupMemberInfo memberInfo : info.getMemberDetails()) {
            selectedList.add(memberInfo.getAccount());
        }
        param.putStringArrayList(TUIConstants.TUIContact.StartActivity.GroupMemberSelect.SELECTED_LIST, selectedList);

        TUICore.startActivityForResult(this, "StartGroupMemberSelectActivity", param, new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result.getData() != null) {
                    List<String> friends = (List<String>) result.getData().getSerializableExtra(TUIGroupConstants.Selection.LIST);
                    inviteGroupMembers(friends);
                }
            }
        });
    }

    private void startModifyGroupAvatar(String originAvatarUrl) {
        ArrayList<ImageSelectActivity.ImageBean> faceList = new ArrayList<>();
        for (int i = 0; i < TUIGroupConstants.GROUP_FACE_COUNT; i++) {
            ImageSelectActivity.ImageBean imageBean = new ImageSelectActivity.ImageBean();
            imageBean.setThumbnailUri(String.format(TUIGroupConstants.GROUP_FACE_URL, (i + 1) + ""));
            imageBean.setImageUri(String.format(TUIGroupConstants.GROUP_FACE_URL, (i + 1) + ""));
            faceList.add(imageBean);
        }

        Intent intent = new Intent();
        intent.putExtra(ImageSelectActivity.TITLE, getResources().getString(R.string.group_choose_avatar));
        intent.putExtra(ImageSelectActivity.SPAN_COUNT, 4);
        intent.putExtra(ImageSelectActivity.ITEM_WIDTH, ScreenUtil.dip2px(77));
        intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, ScreenUtil.dip2px(77));
        intent.putExtra(ImageSelectActivity.DATA, faceList);
        intent.putExtra(ImageSelectActivity.SELECTED, new ImageSelectActivity.ImageBean(originAvatarUrl, originAvatarUrl, false));
        TUICore.startActivityForResult(this, ImageSelectActivity.class, intent.getExtras(), new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                if (result.getData() != null) {
                    ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) result.getData().getSerializableExtra(ImageSelectActivity.DATA);
                    if (imageBean == null) {
                        return;
                    }

                    String avatarUrl = imageBean.getImageUri();
                    modifyGroupAvatar(avatarUrl);
                }
            }
        });
    }

    private void modifyGroupAvatar(String avatarUrl) {
        groupInfoLayout.modifyGroupAvatar(avatarUrl);
    }

    private void deleteGroupMembers(List<String> friends) {
        if (friends != null && friends.size() > 0) {
            if (groupInfoPresenter != null) {
                groupInfoPresenter.deleteGroupMembers(groupId, friends, new IUIKitCallback<List<String>>() {
                    @Override
                    public void onSuccess(List<String> data) {
                        groupInfoPresenter.loadGroupInfo(groupId);
                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {}
                });
            }
        }
    }

    private void inviteGroupMembers(List<String> friends) {
        if (friends != null && friends.size() > 0) {
            groupInfoPresenter.inviteGroupMembers(groupId, friends, new IUIKitCallback<Object>() {
                @Override
                public void onSuccess(Object data) {
                    if (data instanceof String) {
                        ToastUtil.toastLongMessage(data.toString());
                    } else {
                        ToastUtil.toastLongMessage(TUIGroupService.getAppContext().getString(R.string.invite_suc));
                    }
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    ToastUtil.toastLongMessage(TUIGroupService.getAppContext().getString(R.string.invite_fail) + errCode + "=" + errMsg);
                }
            });
        }
    }

    public void changeGroupOwner(String newOwnerId) {
        groupInfoPresenter.transferGroupOwner(groupId, newOwnerId, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                groupInfoLayout.loadGroupInfo(groupId);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {}
        });
    }

    public interface OnModifyGroupAvatarListener {
        void onModifyGroupAvatar(String originAvatarUrl);
    }
}
