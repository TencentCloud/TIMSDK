package com.tencent.qcloud.tuikit.tuigroup.minimalistui.page;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.ActivityResultRegistry;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityOptionsCompat;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.activities.ImageSelectMinimalistActivity;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuigroup.R;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupConstants;
import com.tencent.qcloud.tuikit.tuigroup.TUIGroupService;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuigroup.bean.GroupMemberInfo;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.interfaces.IGroupMemberListener;
import com.tencent.qcloud.tuikit.tuigroup.minimalistui.widget.GroupInfoLayout;
import com.tencent.qcloud.tuikit.tuigroup.presenter.GroupInfoPresenter;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupLog;
import com.tencent.qcloud.tuikit.tuigroup.util.TUIGroupUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class GroupInfoMinimalistFragment extends BaseFragment {
    private static final int CALL_MEMBER_LIMIT = 8;

    private View baseView;
    private GroupInfoLayout groupInfoLayout;

    private String groupId;

    private GroupInfoPresenter groupInfoPresenter = null;
    private String mChatBackgroundThumbnailUrl;
    private String groupAvatarUrl;

    private final ActivityResultContract<Pair<String, Boolean>, Intent> groupCallResultContract =
            new ActivityResultContract<Pair<String, Boolean>, Intent>() {

                @NonNull
                @Override
                public Intent createIntent(@NonNull Context context, Pair<String, Boolean> input) {
                    Intent intent = new Intent();
                    Bundle bundle = new Bundle();
                    bundle.putString(TUIConstants.TUICalling.GROUP_ID, input.first);
                    bundle.putString(TUIConstants.TUIGroup.GROUP_ID, input.first);
                    bundle.putString(TUIConstants.TUICalling.PARAM_NAME_TYPE,
                            input.second ? TUIConstants.TUICalling.TYPE_AUDIO : TUIConstants.TUICalling.TYPE_VIDEO);
                    bundle.putString(TUIConstants.TUIGroup.TITLE,
                            input.second ? getString(R.string.group_profile_audio_call) : getString(R.string.group_profile_video_call));
                    bundle.putBoolean(TUIConstants.TUIGroup.SELECT_FOR_CALL, true);
                    bundle.putInt(TUIConstants.TUIGroup.LIMIT, CALL_MEMBER_LIMIT);
                    intent.putExtras(bundle);
                    return intent;
                }

                @Override
                public Intent parseResult(int resultCode, @Nullable Intent intent) {
                    return intent;
                }
            };

    private final ActivityResultCallback<Intent> groupCallResultCallback = new ActivityResultCallback<Intent>() {
        @Override
        public void onActivityResult(Intent result) {
            List<String> stringList = result.getStringArrayListExtra("list");
            if (stringList != null && !stringList.isEmpty()) {
                String[] stringArray = stringList.toArray(new String[]{});
                result.putExtra(TUIConstants.TUICalling.PARAM_NAME_USERIDS, stringArray);
                HashMap<String, Object> hashMap = new HashMap<>();
                for (String key : result.getExtras().keySet()) {
                    hashMap.put(key, result.getExtras().get(key));
                }
                TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME,
                        TUIConstants.TUICalling.METHOD_NAME_CALL, hashMap);
            }
        }
    };


    private final ActivityResultRegistry groupInfoResultRegistry = new ActivityResultRegistry() {
        @Override
        public <I, O> void onLaunch(int requestCode, @NonNull ActivityResultContract<I, O> contract, I input, @Nullable ActivityOptionsCompat options) {
            Context context = getContext();
            if (context == null) {
                return;
            }
            Intent intent = contract.createIntent(context, input);
            if (contract == groupCallResultContract || contract == groupInviteMemberResultContract || contract == groupDeleteMemberResultContract) {
                Bundle bundle = intent.getExtras();
                TUICore.startActivity(GroupInfoMinimalistFragment.this, "StartGroupMemberSelectMinimalistActivity", bundle, requestCode);
            } else {
                if (getActivity() == null) {
                    return;
                }
                GroupInfoMinimalistFragment.this.startActivityForResult(intent, requestCode);
            }
        }
    };

    private final ActivityResultLauncher<Pair<String, Boolean>> groupCallResultLauncher =
            registerForActivityResult(groupCallResultContract, groupInfoResultRegistry, groupCallResultCallback);

    private final ActivityResultLauncher<Intent> groupAvatarSetupResultLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), groupInfoResultRegistry, new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    Intent data = result.getData();
                    if (data != null) {
                        ImageSelectMinimalistActivity.ImageBean imageBean = (ImageSelectMinimalistActivity.ImageBean) data.getSerializableExtra(ImageSelectMinimalistActivity.DATA);
                        if (imageBean == null) {
                            return;
                        }

                        String avatarUrl = imageBean.getImageUri();
                        modifyGroupAvatar(avatarUrl);
                    }
                }
            });

    private final ActivityResultLauncher<Intent> groupChatBgSetupResultLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), groupInfoResultRegistry, new ActivityResultCallback<ActivityResult>() {
                @Override
                public void onActivityResult(ActivityResult result) {
                    Intent data = result.getData();
                    if (data == null) {
                        return;
                    }
                    ImageSelectMinimalistActivity.ImageBean imageBean = (ImageSelectMinimalistActivity.ImageBean) data.getSerializableExtra(ImageSelectMinimalistActivity.DATA);
                    if (imageBean == null) {
                        TUIGroupLog.e("GroupInfoMinimalistFragment", "onActivityResult imageBean is null");
                        return;
                    }

                    String backgroundUri = imageBean.getLocalPath();
                    String thumbnailUri = imageBean.getThumbnailUri();
                    String dataUri = thumbnailUri + "," + backgroundUri;
                    TUIGroupLog.d("GroupInfoMinimalistFragment", "onActivityResult backgroundUri = " + backgroundUri);
                    mChatBackgroundThumbnailUrl = thumbnailUri;
                    HashMap<String, Object> param = new HashMap<>();
                    param.put(TUIConstants.TUIChat.CHAT_ID, groupId);
                    param.put(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, dataUri);
                    TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_UPDATE_DATA_STORE_CHAT_URI, param);
                }
            });

    private final ActivityResultContract<String, Intent> groupDeleteMemberResultContract = new ActivityResultContract<String, Intent>() {
        @NonNull
        @Override
        public Intent createIntent(@NonNull Context context, String input) {
            Intent intent = new Intent();
            Bundle param = new Bundle();
            param.putString(TUIGroupConstants.Group.GROUP_ID, input);
            param.putBoolean(TUIGroupConstants.Selection.SELECT_FOR_CALL, true);
            intent.putExtras(param);
            return intent;
        }

        @Override
        public Intent parseResult(int resultCode, @Nullable Intent intent) {
            return intent;
        }
    };

    private final ActivityResultContract<GroupInfo, Intent> groupInviteMemberResultContract = new ActivityResultContract<GroupInfo, Intent>() {
        @NonNull
        @Override
        public Intent createIntent(@NonNull Context context, GroupInfo input) {
            Intent intent = new Intent();
            Bundle param = new Bundle();
            param.putString(TUIGroupConstants.Group.GROUP_ID, input.getId());
            param.putBoolean(TUIGroupConstants.Selection.SELECT_FRIENDS, true);
            ArrayList<String> selectedList = new ArrayList<>();
            for (GroupMemberInfo memberInfo : input.getMemberDetails()) {
                selectedList.add(memberInfo.getAccount());
            }
            param.putStringArrayList(TUIGroupConstants.Selection.SELECTED_LIST, selectedList);
            intent.putExtras(param);
            return intent;
        }

        @Override
        public Intent parseResult(int resultCode, @Nullable Intent intent) {
            return intent;
        }
    };

    private final ActivityResultLauncher<String> groupDeleteMemberResultLauncher =
            registerForActivityResult(groupDeleteMemberResultContract, groupInfoResultRegistry, new ActivityResultCallback<Intent>() {
                @Override
                public void onActivityResult(Intent result) {
                    if (result == null) {
                        return;
                    }
                    List<String> friends = (List<String>) result.getSerializableExtra(TUIGroupConstants.Selection.LIST);
                    deleteGroupMembers(friends);
                }
            });

    private final ActivityResultLauncher<GroupInfo> groupInviteMemberResultLauncher =
            registerForActivityResult(groupInviteMemberResultContract, groupInfoResultRegistry, new ActivityResultCallback<Intent>() {
                @Override
                public void onActivityResult(Intent result) {
                    if (result == null) {
                        return;
                    }
                    List<String> friends = (List<String>) result.getSerializableExtra(TUIGroupConstants.Selection.LIST);
                    inviteGroupMembers(friends);
                }
            });

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        baseView = inflater.inflate(R.layout.group_minimalist_info_fragment, container, false);
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
                ArrayList<ImageSelectMinimalistActivity.ImageBean> faceList = new ArrayList<>();
                for (int i = 0; i < TUIGroupConstants.GROUP_FACE_COUNT; i++) {
                    ImageSelectMinimalistActivity.ImageBean imageBean = new ImageSelectMinimalistActivity.ImageBean();
                    imageBean.setThumbnailUri(String.format(TUIGroupConstants.GROUP_FACE_URL, (i + 1) + ""));
                    imageBean.setImageUri(String.format(TUIGroupConstants.GROUP_FACE_URL, (i + 1) + ""));
                    faceList.add(imageBean);
                }

                Intent intent = new Intent(getContext(), ImageSelectMinimalistActivity.class);
                intent.putExtra(ImageSelectMinimalistActivity.TITLE, getResources().getString(R.string.group_choose_avatar));
                intent.putExtra(ImageSelectMinimalistActivity.SPAN_COUNT, 4);
                intent.putExtra(ImageSelectMinimalistActivity.ITEM_WIDTH, ScreenUtil.dip2px(77));
                intent.putExtra(ImageSelectMinimalistActivity.ITEM_HEIGHT, ScreenUtil.dip2px(77));
                intent.putExtra(ImageSelectMinimalistActivity.DATA, faceList);
                intent.putExtra(ImageSelectMinimalistActivity.SELECTED, new ImageSelectMinimalistActivity.ImageBean(originAvatarUrl, originAvatarUrl, false));
                groupAvatarSetupResultLauncher.launch(intent);
            }
        });
        groupInfoLayout.loadGroupInfo(groupId);
        groupInfoLayout.setRouter(new IGroupMemberListener() {
            @Override
            public void forwardListMember(GroupInfo info) {
                Intent intent = new Intent(getContext(), GroupMemberMinimalistActivity.class);
                intent.putExtra(TUIConstants.TUIGroup.IS_SELECT_MODE, false);
                intent.putExtra(TUIConstants.TUIGroup.GROUP_ID, info.getId());
                startActivity(intent);
            }

            @Override
            public void forwardAddMember(GroupInfo info) {
                groupInviteMemberResultLauncher.launch(info);
            }

            @Override
            public void forwardDeleteMember(GroupInfo info) {
                groupDeleteMemberResultLauncher.launch(info.getId());
            }
        });

        groupInfoLayout.setOnButtonClickListener(new GroupInfoLayout.OnButtonClickListener() {
            @Override
            public void onSetChatBackground() {
                ArrayList<ImageSelectMinimalistActivity.ImageBean> faceList = new ArrayList<>();
                ImageSelectMinimalistActivity.ImageBean defaultFace = new ImageSelectMinimalistActivity.ImageBean();
                defaultFace.setDefault(true);
                faceList.add(defaultFace);
                for (int i = 0; i < TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_COUNT; i++) {
                    ImageSelectMinimalistActivity.ImageBean imageBean = new ImageSelectMinimalistActivity.ImageBean();
                    imageBean.setImageUri(String.format(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_URL, (i + 1) + ""));
                    imageBean.setThumbnailUri(String.format(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_THUMBNAIL_URL, (i + 1) + ""));
                    faceList.add(imageBean);
                }

                Intent intent = new Intent(getContext(), ImageSelectMinimalistActivity.class);
                intent.putExtra(ImageSelectMinimalistActivity.TITLE, getResources().getString(R.string.chat_background_title));
                intent.putExtra(ImageSelectMinimalistActivity.SPAN_COUNT, 2);
                intent.putExtra(ImageSelectMinimalistActivity.ITEM_WIDTH, ScreenUtil.dip2px(186));
                intent.putExtra(ImageSelectMinimalistActivity.ITEM_HEIGHT, ScreenUtil.dip2px(124));
                intent.putExtra(ImageSelectMinimalistActivity.DATA, faceList);
                if (TextUtils.isEmpty(mChatBackgroundThumbnailUrl) || TextUtils.equals(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL, mChatBackgroundThumbnailUrl)) {
                    intent.putExtra(ImageSelectMinimalistActivity.SELECTED, defaultFace);
                } else {
                    intent.putExtra(ImageSelectMinimalistActivity.SELECTED, new ImageSelectMinimalistActivity.ImageBean(mChatBackgroundThumbnailUrl, "", false));
                }
                intent.putExtra(ImageSelectMinimalistActivity.NEED_DOWLOAD_LOCAL, true);
                groupChatBgSetupResultLauncher.launch(intent);
            }

            @Override
            public void onCallBtnClicked(String groupID, boolean isAudioCall) {
                startCall(groupID, isAudioCall);
            }

            @Override
            public void onChatBtnClicked(GroupInfo groupInfo) {
                TUIGroupUtils.startGroupChatActivity(groupInfo);
            }
        });
    }

    private void startCall(String groupID, boolean isAudioCall) {
        groupCallResultLauncher.launch(new Pair<>(groupID, isAudioCall));
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (groupInfoResultRegistry.dispatchResult(requestCode, resultCode, data)) {
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
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
                    public void onError(String module, int errCode, String errMsg) {

                    }
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
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }


    public interface OnModifyGroupAvatarListener {
        void onModifyGroupAvatar(String originAvatarUrl);
    }

}
