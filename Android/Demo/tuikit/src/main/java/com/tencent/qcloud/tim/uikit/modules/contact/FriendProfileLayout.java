package com.tencent.qcloud.tim.uikit.modules.contact;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendOperationResult;
import com.tencent.imsdk.v2.V2TIMGroupApplication;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMReceiveMessageOptInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.component.CircleImageView;
import com.tencent.qcloud.tim.uikit.component.LineControllerView;
import com.tencent.qcloud.tim.uikit.component.SelectionActivity;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.modules.chat.GroupChatManagerKit;
import com.tencent.qcloud.tim.uikit.modules.chat.base.ChatInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationManagerKit;
import com.tencent.qcloud.tim.uikit.modules.group.apply.GroupApplyInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class FriendProfileLayout extends LinearLayout implements View.OnClickListener {

    private static final String TAG = FriendProfileLayout.class.getSimpleName();

    private final int CHANGE_REMARK_CODE = 200;

    private TitleBarLayout mTitleBar;
    private CircleImageView mHeadImageView;
    private TextView mNickNameView;
    private LineControllerView mIDView;
    private LineControllerView mAddWordingView;
    private LineControllerView mRemarkView;
    private LineControllerView mAddBlackView;
    private LineControllerView mChatTopView;
    private LineControllerView mMessageOptionView;
    private TextView mDeleteView;
    private TextView mChatView;

    private ContactItemBean mContactInfo;
    private ChatInfo mChatInfo;
    private V2TIMFriendApplication mFriendApplication;
    private OnButtonClickListener mListener;
    private String mId;
    private String mNickname;
    private String mRemark;
    private String mAddWords;

    private IUIKitCallBack mIUICallback;

    public FriendProfileLayout(Context context) {
        super(context);
        init();
    }

    public FriendProfileLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public FriendProfileLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.contact_friend_profile_layout, this);

        mHeadImageView = findViewById(R.id.avatar);
        mNickNameView = findViewById(R.id.name);
        mIDView = findViewById(R.id.id);
        mAddWordingView = findViewById(R.id.add_wording);
        mAddWordingView.setCanNav(false);
        mAddWordingView.setSingleLine(false);
        mRemarkView = findViewById(R.id.remark);
        mRemarkView.setOnClickListener(this);
        mMessageOptionView = findViewById(R.id.msg_rev_opt);
        mMessageOptionView.setOnClickListener(this);
        mChatTopView = findViewById(R.id.chat_to_top);
        mAddBlackView = findViewById(R.id.blackList);
        mDeleteView = findViewById(R.id.btnDel);
        mDeleteView.setOnClickListener(this);
        mChatView = findViewById(R.id.btnChat);
        mChatView.setOnClickListener(this);
        mTitleBar = findViewById(R.id.friend_titlebar);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), TitleBarLayout.POSITION.MIDDLE);
        mTitleBar.getRightGroup().setVisibility(View.GONE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ((Activity) getContext()).finish();
            }
        });
    }

    public void initData(Object data) {
        if (data instanceof ChatInfo) {
            mChatInfo = (ChatInfo) data;
            mId = mChatInfo.getId();
            mChatTopView.setVisibility(View.VISIBLE);
            mChatTopView.setChecked(ConversationManagerKit.getInstance().isTopConversation(mId));
            mChatTopView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
                    ConversationManagerKit.getInstance().setConversationTop(mId, isChecked, new IUIKitCallBack() {
                        @Override
                        public void onSuccess(Object data) {

                        }

                        @Override
                        public void onError(String module, int errCode, String errMsg) {
                            buttonView.setChecked(false);
                            if (mIUICallback != null) {
                                mIUICallback.onError(module, errCode, errMsg);
                            }
                        }
                    });
                }
            });
            loadUserProfile();
            return;
        } else if (data instanceof ContactItemBean) {
            mContactInfo = (ContactItemBean) data;
            mId = mContactInfo.getId();
            mNickname = mContactInfo.getNickname();
            mRemarkView.setVisibility(VISIBLE);
            mRemarkView.setContent(mContactInfo.getRemark());
            mAddBlackView.setChecked(mContactInfo.isBlackList());
            mAddBlackView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (isChecked) {
                        addBlack();
                    } else {
                        deleteBlack();
                    }
                }
            });
            if (!TextUtils.isEmpty(mContactInfo.getAvatarurl())) {
                GlideEngine.loadImage(mHeadImageView, Uri.parse(mContactInfo.getAvatarurl()));
            }

            updateMessageOptionView();
        } else if (data instanceof V2TIMFriendApplication) {
            mFriendApplication = (V2TIMFriendApplication) data;
            mId = mFriendApplication.getUserID();
            mNickname = mFriendApplication.getNickname();
            mAddWordingView.setVisibility(View.VISIBLE);
            mAddWordingView.setContent(mFriendApplication.getAddWording());
            mRemarkView.setVisibility(GONE);
            mAddBlackView.setVisibility(GONE);
            mMessageOptionView.setVisibility(GONE);
            mDeleteView.setText(R.string.refuse);
            mDeleteView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    refuse();
                }
            });
            mChatView.setText(R.string.accept);
            mChatView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    accept();
                }
            });
        } else if (data instanceof GroupApplyInfo) {
            final GroupApplyInfo info = (GroupApplyInfo) data;
            V2TIMGroupApplication item = ((GroupApplyInfo) data).getGroupApplication();
            mId = item.getFromUser();
            mNickname = item.getFromUserNickName();
            mAddWordingView.setVisibility(View.VISIBLE);
            mAddWordingView.setContent(item.getRequestMsg());
            mRemarkView.setVisibility(GONE);
            mAddBlackView.setVisibility(GONE);
            mMessageOptionView.setVisibility(GONE);
            mDeleteView.setText(R.string.refuse);
            mDeleteView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    refuseApply(info);
                }
            });
            mChatView.setText(R.string.accept);
            mChatView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    acceptApply(info);
                }
            });
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }
        mIDView.setContent(mId);
    }

    public void setUICallback(IUIKitCallBack callback) {
        this.mIUICallback = callback;
    }

    private void updateMessageOptionView() {
        mMessageOptionView.setVisibility(VISIBLE);
        //get
        final ArrayList userIdList = new ArrayList();
        userIdList.add(mId);
        V2TIMManager.getMessageManager().getC2CReceiveMessageOpt(userIdList, new V2TIMValueCallback<List<V2TIMReceiveMessageOptInfo>>(){
            @Override
            public void onSuccess(List<V2TIMReceiveMessageOptInfo> V2TIMReceiveMessageOptInfos) {
                if (V2TIMReceiveMessageOptInfos == null || V2TIMReceiveMessageOptInfos.isEmpty()) {
                    TUIKitLog.d(TAG, "getC2CReceiveMessageOpt null");
                    return;
                }
                V2TIMReceiveMessageOptInfo V2TIMReceiveMessageOptInfo = V2TIMReceiveMessageOptInfos.get(0);
                int option = V2TIMReceiveMessageOptInfo.getC2CReceiveMessageOpt();

                TUIKitLog.d(TAG, "getC2CReceiveMessageOpt option = " + option);
                mMessageOptionView.setChecked(option == V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE ? true : false);
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.d(TAG, "getC2CReceiveMessageOpt onError code = " + code + ", desc = " + desc);
                mMessageOptionView.setChecked(false);
            }
        });

        //set
        mMessageOptionView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                int option;
                if (isChecked) {
                    option = V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE;
                } else {
                    option = V2TIMMessage.V2TIM_RECEIVE_MESSAGE;
                }

                V2TIMManager.getMessageManager().setC2CReceiveMessageOpt(userIdList, option, new V2TIMCallback(){
                    @Override
                    public void onSuccess() {
                        TUIKitLog.d(TAG, "setC2CReceiveMessageOpt onSuccess");
                    }

                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.d(TAG, "setC2CReceiveMessageOpt onError code = " + code + ", desc = " + desc);
                    }
                });
            }
        });
    }

    private void updateViews(ContactItemBean bean) {
        mContactInfo = bean;
        mChatTopView.setVisibility(View.VISIBLE);
        boolean top = ConversationManagerKit.getInstance().isTopConversation(mId);
        if (mChatTopView.isChecked() != top) {
            mChatTopView.setChecked(top);
        }
        mChatTopView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
                ConversationManagerKit.getInstance().setConversationTop(mId, isChecked, new IUIKitCallBack() {
                    @Override
                    public void onSuccess(Object data) {

                    }

                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        buttonView.setChecked(false);
                        if (mIUICallback != null) {
                            mIUICallback.onError(module, errCode, errMsg);
                        }
                    }
                });
            }
        });
        mId = bean.getId();
        mNickname = bean.getNickname();
        if (bean.isFriend()) {
            mRemarkView.setVisibility(VISIBLE);
            mRemarkView.setContent(bean.getRemark());
            mAddBlackView.setVisibility(VISIBLE);
            mAddBlackView.setChecked(bean.isBlackList());
            mMessageOptionView.setVisibility(VISIBLE);

            updateMessageOptionView();

            mAddBlackView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    if (isChecked) {
                        addBlack();
                    } else {
                        deleteBlack();
                    }
                }
            });
            mDeleteView.setVisibility(VISIBLE);
        } else {
            mRemarkView.setVisibility(GONE);
            mAddBlackView.setVisibility(GONE);
            mDeleteView.setVisibility(GONE);
            mMessageOptionView.setVisibility(GONE);
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }

        if (!TextUtils.isEmpty(bean.getAvatarurl())) {
            GlideEngine.loadImage(mHeadImageView, Uri.parse(bean.getAvatarurl()));
        }
        mIDView.setContent(mId);
    }

    private void loadUserProfile() {
        ArrayList<String> list = new ArrayList<>();
        list.add(mId);
        final ContactItemBean bean = new ContactItemBean();
        bean.setFriend(false);

        V2TIMManager.getInstance().getUsersInfo(list, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "loadUserProfile err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.size() != 1) {
                    return;
                }
                final V2TIMUserFullInfo timUserFullInfo = v2TIMUserFullInfos.get(0);
                bean.setNickname(timUserFullInfo.getNickName());
                bean.setId(timUserFullInfo.getUserID());
                bean.setAvatarurl(timUserFullInfo.getFaceUrl());
                updateViews(bean);
            }
        });

        V2TIMManager.getFriendshipManager().getBlackList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "getBlackList err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                if (v2TIMFriendInfos != null && v2TIMFriendInfos.size() > 0) {
                    for (V2TIMFriendInfo friendInfo : v2TIMFriendInfos) {
                        if (TextUtils.equals(friendInfo.getUserID(), mId)) {
                            bean.setBlackList(true);
                            updateViews(bean);
                            break;
                        }
                    }
                }
            }
        });

        V2TIMManager.getFriendshipManager().getFriendList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "getFriendList err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                if (v2TIMFriendInfos != null && v2TIMFriendInfos.size() > 0) {
                    for (V2TIMFriendInfo friendInfo : v2TIMFriendInfos) {
                        if (TextUtils.equals(friendInfo.getUserID(), mId)) {
                            bean.setFriend(true);
                            bean.setRemark(friendInfo.getFriendRemark());
                            bean.setAvatarurl(friendInfo.getUserProfile().getFaceUrl());
                            break;
                        }
                    }
                }
                updateViews(bean);
            }
        });
    }

    private void accept() {
        V2TIMManager.getFriendshipManager().acceptFriendApplication(
                mFriendApplication, V2TIMFriendApplication.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "accept err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                TUIKitLog.i(TAG, "accept success");
                mChatView.setText(R.string.accepted);
                ((Activity) getContext()).finish();
            }
        });
    }

    private void refuse() {
        V2TIMManager.getFriendshipManager().refuseFriendApplication(mFriendApplication, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.e(TAG, "accept err code = " + code + ", desc = " + desc);
                        ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
                    }

                    @Override
                    public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                        TUIKitLog.i(TAG, "refuse success");
                        mDeleteView.setText(R.string.refused);
                        ((Activity) getContext()).finish();
                    }
                });
    }

    public void acceptApply(final GroupApplyInfo item) {
        GroupChatManagerKit.getInstance().getProvider().acceptApply(item, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                Intent intent = new Intent();
                intent.putExtra(TUIKitConstants.Group.MEMBER_APPLY, item);
                ((Activity) getContext()).setResult(Activity.RESULT_OK, intent);
                ((Activity) getContext()).finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    public void refuseApply(final GroupApplyInfo item) {
        GroupChatManagerKit.getInstance().getProvider().refuseApply(item, new IUIKitCallBack() {
            @Override
            public void onSuccess(Object data) {
                Intent intent = new Intent();
                intent.putExtra(TUIKitConstants.Group.MEMBER_APPLY, item);
                ((Activity) getContext()).setResult(Activity.RESULT_OK, intent);
                ((Activity) getContext()).finish();
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastLongMessage(errMsg);
            }
        });
    }

    private void delete() {
        List<String> identifiers = new ArrayList<>();
        identifiers.add(mId);

        V2TIMManager.getFriendshipManager().deleteFromFriendList(identifiers, V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "deleteFriends err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                TUIKitLog.i(TAG, "deleteFriends success");
                ConversationManagerKit.getInstance().deleteConversation(mId, false);
                if (mListener != null) {
                    mListener.onDeleteFriendClick(mId);
                }
                ((Activity) getContext()).finish();
            }
        });
    }

    private void chat() {
        if (mListener != null || mContactInfo != null) {
            mListener.onStartConversationClick(mContactInfo);
        }
        ((Activity) getContext()).finish();
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.btnChat) {
            chat();
        } else if (v.getId() == R.id.btnDel) {
            delete();
        } else if (v.getId() == R.id.remark) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.profile_remark_edit));
            bundle.putString(TUIKitConstants.Selection.INIT_CONTENT, mRemarkView.getContent());
            bundle.putInt(TUIKitConstants.Selection.LIMIT, 20);
            SelectionActivity.startTextSelection(TUIKit.getAppContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(Object text) {
                    mRemarkView.setContent(text.toString());
                    if (TextUtils.isEmpty(text.toString())) {
                        text = "";
                    }
                    modifyRemark(text.toString());
                }
            });
        }
    }

    private void modifyRemark(final String txt) {
        V2TIMFriendInfo v2TIMFriendInfo = new V2TIMFriendInfo();
        v2TIMFriendInfo.setUserID(mId);
        v2TIMFriendInfo.setFriendRemark(txt);

        V2TIMManager.getFriendshipManager().setFriendInfo(v2TIMFriendInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "modifyRemark err code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess() {
                mContactInfo.setRemark(txt);
                TUIKitLog.i(TAG, "modifyRemark success");
            }
        });
    }

    private void addBlack() {
        String[] idStringList = mId.split(",");

        List<String> idList = new ArrayList<>();
        for (String id : idStringList) {
            idList.add(id);
        }

        V2TIMManager.getFriendshipManager().addToBlackList(idList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "addBlackList err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                TUIKitLog.v(TAG, "addBlackList success");
            }
        });
    }

    private void deleteBlack() {
        String[] idStringList = mId.split(",");

        List<String> idList = new ArrayList<>();
        for (String id : idStringList) {
            idList.add(id);
        }

        V2TIMManager.getFriendshipManager().deleteFromBlackList(idList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "deleteBlackList err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                TUIKitLog.i(TAG, "deleteBlackList success");
            }
        });
    }

    public void setOnButtonClickListener(OnButtonClickListener l) {
        mListener = l;
    }

    public interface OnButtonClickListener {
        void onStartConversationClick(ContactItemBean info);

        void onDeleteFriendClick(String id);
    }

}
