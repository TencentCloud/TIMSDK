package com.tencent.qcloud.tuikit.tuicontact.minimalistui.widget;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuicore.component.MinimalistTitleBar;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.component.popupcard.PopupInputCard;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuicontact.R;
import com.tencent.qcloud.tuikit.tuicontact.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.IFriendProfileLayout;
import com.tencent.qcloud.tuikit.tuicontact.presenter.FriendProfilePresenter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FriendProfileLayout extends LinearLayout implements View.OnClickListener, IFriendProfileLayout {

    private static final String TAG = FriendProfileLayout.class.getSimpleName();

    private MinimalistTitleBar mTitleBar;
    private ShadeImageView mHeadImageView;
    private TextView mNickNameView;
    private MinimalistLineControllerView mRemarkView;
    private MinimalistLineControllerView mAddBlackView;
    private MinimalistLineControllerView mChatTopView;
    private MinimalistLineControllerView mMessageOptionView;
    private MinimalistLineControllerView mChatBackground;
    private MinimalistLineControllerView deleteFriendBtn;
    private MinimalistLineControllerView clearMessageBtn;
    private TextView friendIDTv;
    private View messageBtn;
    private View audioCallBtn;
    private View videoCallBtn;

    private ContactItemBean mContactInfo;
    private FriendApplicationBean friendApplicationBean;
    private OnButtonClickListener mListener;
    private String mId;
    private String mNickname;
    private boolean isFriend;
    private boolean isGroup = false;

    private FriendProfilePresenter presenter;

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

    public void setPresenter(FriendProfilePresenter presenter) {
        this.presenter = presenter;
    }

    private void init() {
        inflate(getContext(), R.layout.minimalist_contact_friend_profile_layout, this);

        mHeadImageView = findViewById(R.id.friend_icon);
        mNickNameView = findViewById(R.id.friend_nick_name);
        friendIDTv = findViewById(R.id.friend_account);
        mRemarkView = findViewById(R.id.remark);
        mRemarkView.setOnClickListener(this);
        mMessageOptionView = findViewById(R.id.msg_rev_opt);
        mMessageOptionView.setOnClickListener(this);
        mChatTopView = findViewById(R.id.chat_to_top);
        mAddBlackView = findViewById(R.id.blackList);
        deleteFriendBtn = findViewById(R.id.btn_delete);
        deleteFriendBtn.setOnClickListener(this);
        deleteFriendBtn.setNameColor(0xFFFF584C);
        clearMessageBtn = findViewById(R.id.clear_chat_history);
        clearMessageBtn.setOnClickListener(this);
        clearMessageBtn.setNameColor(0xFFFF584C);
        messageBtn = findViewById(R.id.message_btn);
        messageBtn.setOnClickListener(this);
        mChatBackground = findViewById(R.id.chat_background);
        mChatBackground.setOnClickListener(this);

        audioCallBtn = findViewById(R.id.audio_call_btn);
        audioCallBtn.setOnClickListener(this);
        videoCallBtn = findViewById(R.id.video_call_btn);
        videoCallBtn.setOnClickListener(this);

        mTitleBar = findViewById(R.id.friend_title_bar);
        mTitleBar.setTitle(getResources().getString(R.string.profile_detail), ITitleBarLayout.Position.MIDDLE);

        mRemarkView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mAddBlackView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mChatTopView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mMessageOptionView.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        mChatBackground.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        deleteFriendBtn.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
        clearMessageBtn.setBackground(new ColorDrawable(getResources().getColor(R.color.contact_line_controller_color)));
    }

    private void setupCall() {
        HashMap<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.CHAT_ID, mId);
        param.put(TUIConstants.TUIChat.CHAT_NAME, mNickname);
        param.put(TUIConstants.TUIChat.CHAT_TYPE, ChatInfo.TYPE_C2C);
        param.put(TUIConstants.TUIChat.CONTEXT, getContext());
        Map<String, Object> videoCallExtension = TUICore.getExtensionInfo(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_VIDEO_CALL, param);
        if (videoCallExtension == null) {
            videoCallBtn.setVisibility(GONE);
        }

        Map<String, Object> audioCallExtension = TUICore.getExtensionInfo(TUIConstants.TUIChat.EXTENSION_INPUT_MORE_AUDIO_CALL, param);
        if (audioCallExtension == null) {
            audioCallBtn.setVisibility(GONE);
        }
    }

    private void initEvent() {
        mChatTopView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
                if (presenter != null) {
                    presenter.setConversationTop(mId, isChecked);
                }
            }
        });

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
    }

    public void initData(Object data) {
        initEvent();

        if (data instanceof String) {
            mId = (String) data;
            friendIDTv.setText(mId);
            loadUserProfile(mId);
        } else if (data instanceof ContactItemBean) {
            setViewContentFromItemBean((ContactItemBean) data);
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }

        setupCall();
    }

    private void setViewContentFromItemBean(ContactItemBean data) {
        mContactInfo = data;
        isFriend = mContactInfo.isFriend();
        mId = mContactInfo.getId();
        mNickname = mContactInfo.getNickName();
        int radius = getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
        GlideEngine.loadUserIcon(mHeadImageView, mContactInfo.getAvatarUrl(), radius);
        mChatTopView.setChecked(presenter.isTopConversation(mId));
        mAddBlackView.setChecked(mContactInfo.isBlackList());
        mRemarkView.setContent(mContactInfo.getRemark());
        if (isFriend) {
            deleteFriendBtn.setVisibility(VISIBLE);
        }
        if (TextUtils.equals(mContactInfo.getId(), TUILogin.getLoginUser())) {
            if (isFriend) {
                mRemarkView.setVisibility(VISIBLE);
                messageBtn.setVisibility(VISIBLE);
                audioCallBtn.setVisibility(VISIBLE);
                videoCallBtn.setVisibility(VISIBLE);
                mAddBlackView.setVisibility(VISIBLE);
                mChatTopView.setVisibility(View.VISIBLE);
                mChatBackground.setVisibility(VISIBLE);
                updateMessageOptionView();
            }
        } else {
            if (mContactInfo.isBlackList()) {
                messageBtn.setVisibility(VISIBLE);
                audioCallBtn.setVisibility(VISIBLE);
                videoCallBtn.setVisibility(VISIBLE);
                mRemarkView.setVisibility(VISIBLE);
                mAddBlackView.setVisibility(VISIBLE);
                mMessageOptionView.setVisibility(VISIBLE);
                mChatTopView.setVisibility(VISIBLE);
                mChatBackground.setVisibility(VISIBLE);
            } else {
                mRemarkView.setVisibility(VISIBLE);
                messageBtn.setVisibility(VISIBLE);
                audioCallBtn.setVisibility(VISIBLE);
                videoCallBtn.setVisibility(VISIBLE);
                mAddBlackView.setVisibility(VISIBLE);
                mChatTopView.setVisibility(View.VISIBLE);
                mChatBackground.setVisibility(VISIBLE);
                updateMessageOptionView();
            }
        }
    }

    private void updateMessageOptionView() {
        mMessageOptionView.setVisibility(VISIBLE);
        //get
        final ArrayList<String> userIdList = new ArrayList<>();
        userIdList.add(mId);

        presenter.getC2CReceiveMessageOpt(userIdList, new IUIKitCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                mMessageOptionView.setChecked(data);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                mMessageOptionView.setChecked(false);
            }
        });

        //set
        mMessageOptionView.setCheckListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                presenter.setC2CReceiveMessageOpt(userIdList, isChecked);
            }
        });
    }

    @Override
    public void onDataSourceChanged(ContactItemBean bean) {
        setViewContentFromItemBean(bean);
        setupCall();
        if (bean.isFriend()) {
            updateMessageOptionView();
            clearMessageBtn.setVisibility(VISIBLE);
        }

        if (!TextUtils.isEmpty(mNickname)) {
            mNickNameView.setText(mNickname);
        } else {
            mNickNameView.setText(mId);
        }

        if (!TextUtils.isEmpty(bean.getAvatarUrl())) {
            int radius = getResources().getDimensionPixelSize(R.dimen.contact_profile_face_radius);
            GlideEngine.loadUserIcon(mHeadImageView, bean.getAvatarUrl(), radius);
        }
    }

    private void loadUserProfile(String id) {
        final ContactItemBean bean = new ContactItemBean();
        presenter.getUsersInfo(id, bean);
    }

    private void delete() {
        List<String> identifiers = new ArrayList<>();
        identifiers.add(mId);

        presenter.deleteFriend(identifiers, new IUIKitCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                if (mListener != null) {
                    mListener.onDeleteFriendClick(mId);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage("deleteFriend Error code = " + errCode + ", desc = " + errMsg);
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
        if (v == messageBtn) {
            chat();
        } else if (v == deleteFriendBtn) {
            new TUIKitDialog(getContext())
                    .builder()
                    .setCancelable(true)
                    .setCancelOutside(true)
                    .setTitle(getContext().getString(R.string.contact_delete_friend_tip))
                    .setDialogWidth(0.75f)
                    .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            delete();
                        }
                    })
                    .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new OnClickListener() {
                        @Override
                        public void onClick(View v) {

                        }
                    })
                    .show();
        } else if (v == clearMessageBtn) {
            new TUIKitDialog(getContext())
                    .builder()
                    .setCancelable(true)
                    .setCancelOutside(true)
                    .setTitle(getContext().getString(R.string.clear_msg_tip))
                    .setDialogWidth(0.75f)
                    .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Map<String, Object> hashMap = new HashMap<>();
                            hashMap.put(TUIConstants.TUIContact.FRIEND_ID, mId);
                            TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_USER,
                                    TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_MESSAGE, hashMap);
                        }
                    })
                    .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), new OnClickListener() {
                        @Override
                        public void onClick(View v) {

                        }
                    })
                    .show();
        } else if (v == videoCallBtn) {
            Map<String, Object> map = new HashMap<>();
            map.put(TUIConstants.TUICalling.PARAM_NAME_USERIDS, new String[]{mId});
            map.put(TUIConstants.TUICalling.PARAM_NAME_TYPE, TUIConstants.TUICalling.TYPE_VIDEO);
            TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_CALL, map);
        } else if (v == audioCallBtn) {
            Map<String, Object> map = new HashMap<>();
            map.put(TUIConstants.TUICalling.PARAM_NAME_USERIDS, new String[]{mId});
            map.put(TUIConstants.TUICalling.PARAM_NAME_TYPE, TUIConstants.TUICalling.TYPE_AUDIO);
            TUICore.callService(TUIConstants.TUICalling.SERVICE_NAME, TUIConstants.TUICalling.METHOD_NAME_CALL, map);
        } else if (v == mRemarkView) {
            PopupInputCard popupInputCard = new PopupInputCard((Activity) getContext());
            popupInputCard.setContent(mRemarkView.getContent());
            popupInputCard.setTitle(getResources().getString(R.string.profile_remark_edit));
            String description = getResources().getString(R.string.contact_modify_remark_rule);
            popupInputCard.setRule("^[a-zA-Z0-9_\u4e00-\u9fa5]*$");
            popupInputCard.setDescription(description);
            popupInputCard.setOnPositive((result -> {
                mRemarkView.setContent(result);
                if (TextUtils.isEmpty(result)) {
                    result = "";
                }
                modifyRemark(result);
            }));
            popupInputCard.show(mRemarkView, Gravity.BOTTOM);

        } else if (v == mChatBackground) {
            if (mListener != null) {
                mListener.onSetChatBackground();
            }
        }
    }

    private void modifyRemark(final String txt) {
        presenter.modifyRemark(mId, txt, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {
                mContactInfo.setRemark(txt);
                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.FRIEND_ID, mId);
                param.put(TUIConstants.TUIContact.FRIEND_REMARK, txt);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, param);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {

            }
        });
    }

    private void addBlack() {
        String[] idStringList = mId.split(",");
        List<String> idList = new ArrayList<>(Arrays.asList(idStringList));
        presenter.addToBlackList(idList);
    }

    private void deleteBlack() {
        String[] idStringList = mId.split(",");
        List<String> idList = new ArrayList<>(Arrays.asList(idStringList));
        presenter.deleteFromBlackList(idList);
    }

    public void setOnButtonClickListener(OnButtonClickListener l) {
        mListener = l;
    }

    public interface OnButtonClickListener {
        void onStartConversationClick(ContactItemBean info);

        void onDeleteFriendClick(String id);

        default void onSetChatBackground() {
        }

        ;
    }

}
