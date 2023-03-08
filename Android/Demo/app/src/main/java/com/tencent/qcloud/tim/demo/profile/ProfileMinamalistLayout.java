package com.tencent.qcloud.tim.demo.profile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIKitConstants;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuicore.component.activities.SelectionActivity;
import com.tencent.qcloud.tuicore.component.activities.SelectionMinimalistActivity;
import com.tencent.qcloud.tuicore.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuicontact.TUIContactService;
import com.tencent.qcloud.tuikit.tuicontact.config.TUIContactConfig;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.ContactEventListener;
import com.tencent.qcloud.tuikit.tuiconversation.TUIConversationService;
import com.tencent.qcloud.tuikit.tuiconversation.config.TUIConversationConfig;
import com.tencent.qcloud.tuikit.tuiconversation.interfaces.ConversationEventListener;

import java.util.ArrayList;
import java.util.List;

public class ProfileMinamalistLayout extends FrameLayout implements View.OnClickListener {

    private static final String TAG = ProfileMinamalistLayout.class.getSimpleName();

    private ShadeImageView userIcon;
    private TextView accountView;
    private TextView nickNameView;
    private TextView signatureView;
    private TextView signatureTagView;

    private MinimalistLineControllerView modifyAllowTypeView;
    private MinimalistLineControllerView aboutIM;
    private RelativeLayout selfDetailArea;
    private SwitchCompat messageReadStatusSwitch;
    private TextView messageReadStatusSubtitle;
    private SwitchCompat userStatusSwitch;
    private TextView userStatusSubTitle;
    private View profileHeader;
    private SharedPreferences mSharedPreferences;

    private ArrayList<String> joinTypeTextList = new ArrayList<>();
    private ArrayList<Integer> joinTypeIdList = new ArrayList<>();
    private int mJoinTypeIndex = 2;
    private String mIconUrl;
    private String mSignature;
    private String mNickName;

    public ProfileMinamalistLayout(Context context) {
        super(context);
        init();
    }

    public ProfileMinamalistLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ProfileMinamalistLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }


    private void init() {
        inflate(getContext(), R.layout.minimalist_profile_layout, this);

        selfDetailArea = findViewById(R.id.self_detail_area);
        selfDetailArea.setOnClickListener(this);

        userIcon = findViewById(R.id.self_icon);
        int radius = ScreenUtil.dip2px(33);
        userIcon.setRadius(radius);
        accountView = findViewById(R.id.self_account);
        nickNameView = findViewById(R.id.self_nick_name);
        signatureView = findViewById(R.id.self_signature);
        signatureTagView = findViewById(R.id.self_signature_tag);
        modifyAllowTypeView = findViewById(R.id.modify_allow_type);
        profileHeader = findViewById(R.id.profile_header_layout);
        modifyAllowTypeView.setCanNav(true);
        modifyAllowTypeView.setOnClickListener(this);

        aboutIM = findViewById(R.id.about_im);
        aboutIM.setCanNav(true);
        aboutIM.setOnClickListener(this);

        joinTypeTextList.add(getResources().getString(R.string.allow_type_allow_any));
        joinTypeTextList.add(getResources().getString(R.string.allow_type_deny_any));
        joinTypeTextList.add(getResources().getString(R.string.allow_type_need_confirm));
        joinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_ALLOW_ANY);
        joinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_DENY_ANY);
        joinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_NEED_CONFIRM);

        mSharedPreferences = getContext().getSharedPreferences(Constants.DEMO_SETTING_SP_NAME, Context.MODE_PRIVATE);
        messageReadStatusSwitch = findViewById(R.id.message_read_switch);
        messageReadStatusSubtitle = findViewById(R.id.message_read_status_subtitle);
        initMessageReadStatus();
        messageReadStatusSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    ToastUtil.toastShortMessage(getResources().getString(R.string.demo_buying_tips));
                    messageReadStatusSubtitle.setText(R.string.demo_message_read_switch_open_text);
                } else {
                    messageReadStatusSubtitle.setText(R.string.demo_message_read_switch_close_text);
                }
                setMessageReadStatus(isChecked, true);
            }
        });

        userStatusSwitch = findViewById(R.id.user_status_switch);
        userStatusSubTitle = findViewById(R.id.user_status_subtitle);
        boolean userStatus = mSharedPreferences.getBoolean(Constants.DEMO_SP_KEY_USER_STATUS, false);
        userStatusSwitch.setChecked(userStatus);
        TUIConversationConfig.getInstance().setShowUserStatus(userStatus);
        TUIContactConfig.getInstance().setShowUserStatus(userStatus);
        userStatusSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    userStatusSubTitle.setText(getResources().getString(R.string.demo_user_status_switch_on_text));
                    ToastUtil.toastLongMessage(getResources().getString(R.string.demo_buying_tips));
                } else {
                    userStatusSubTitle.setText(getResources().getString(R.string.demo_user_status_switch_off_text));
                }

                TUIConversationConfig.getInstance().setShowUserStatus(isChecked);
                TUIContactConfig.getInstance().setShowUserStatus(isChecked);
                mSharedPreferences.edit().putBoolean(Constants.DEMO_SP_KEY_USER_STATUS, isChecked).commit();
                refreshFragmentUI();
            }
        });

        String selfUserID = V2TIMManager.getInstance().getLoginUser();

        accountView.setText(selfUserID);
        List<String> selfIdList = new ArrayList<>();
        selfIdList.add(selfUserID);
        V2TIMManager.getInstance().getUsersInfo(selfIdList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                setUserInfo(v2TIMUserFullInfos.get(0));
            }

            @Override
            public void onError(int code, String desc) {

            }
        });
        setUserInfoListener();
    }

    private void refreshFragmentUI() {
        ConversationEventListener conversationEventListener = TUIConversationService.getInstance().getConversationEventListener();
        if (conversationEventListener != null) {
            conversationEventListener.refreshUserStatusFragmentUI();
        } else {
            DemoLog.e(TAG, "refreshFragmentUI conversationEventListener is null");
        }

        List<ContactEventListener> contactEventListenerList = TUIContactService.getInstance().getContactEventListenerList();
        for (ContactEventListener contactEventListener : contactEventListenerList) {
            contactEventListener.refreshUserStatusFragmentUI();
        }
    }

    private void initMessageReadStatus() {
        SharedPreferences sharedPreferences = getContext().getSharedPreferences(Constants.DEMO_SETTING_SP_NAME, Context.MODE_PRIVATE );
        boolean messageReadStatus = sharedPreferences.getBoolean(Constants.DEMO_SP_KEY_MESSAGE_READ_STATUS, false);
        setMessageReadStatus(messageReadStatus, false);
        messageReadStatusSwitch.setChecked(messageReadStatus);
    }

    private void setMessageReadStatus(boolean isShowReadStatus, boolean needUpdate) {
        TUIChatConfigs.getConfigs().getGeneralConfig().setShowRead(isShowReadStatus);
        if (needUpdate) {
            SharedPreferences sharedPreferences = getContext().getSharedPreferences(Constants.DEMO_SETTING_SP_NAME, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putBoolean(Constants.DEMO_SP_KEY_MESSAGE_READ_STATUS, isShowReadStatus);
            editor.commit();
        }
    }

    private void setUserInfo(V2TIMUserFullInfo info) {
        mIconUrl = info.getFaceUrl();
        int radius = getResources().getDimensionPixelSize(R.dimen.demo_profile_face_radius);
        GlideEngine.loadUserIcon(userIcon, mIconUrl, radius);
        mNickName = info.getNickName();
        if (TextUtils.isEmpty(mNickName)) {
            nickNameView.setText(info.getUserID());
        } else {
            nickNameView.setText(mNickName);
        }
        accountView.setText(info.getUserID());

        mSignature = info.getSelfSignature();
        if (TextUtils.isEmpty(mSignature)) {
            signatureTagView.setText(getResources().getString(R.string.demo_no_status));
        } else {
            signatureTagView.setText(getResources().getString(R.string.demo_signature_tag));
        }
        signatureView.setText(mSignature);
        modifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
        int allowType = info.getAllowType();
        if (allowType == V2TIMUserFullInfo.V2TIM_FRIEND_ALLOW_ANY) {
            modifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_allow_any));
            mJoinTypeIndex = 0;
        } else if (allowType == V2TIMUserFullInfo.V2TIM_FRIEND_DENY_ANY) {
            modifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_deny_any));
            mJoinTypeIndex = 1;
        } else if (allowType == V2TIMUserFullInfo.V2TIM_FRIEND_NEED_CONFIRM) {
            modifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
            mJoinTypeIndex = 2;
        } else {
            modifyAllowTypeView.setContent("");
        }
    }

    private void setUserInfoListener() {
        V2TIMSDKListener v2TIMSDKListener = new V2TIMSDKListener() {
            @Override
            public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
                setUserInfo(info);
            }
        };
        V2TIMManager.getInstance().addIMSDKListener(v2TIMSDKListener);
    }


    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.self_detail_area) {
            Intent intent = new Intent(getContext(), SelfDetailMinamalistActivity.class);
            getContext().startActivity(intent);
        }
        if (v.getId() == R.id.modify_allow_type) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.add_rule));
            bundle.putStringArrayList(TUIKitConstants.Selection.LIST, joinTypeTextList);
            bundle.putInt(TUIKitConstants.Selection.DEFAULT_SELECT_ITEM_INDEX, mJoinTypeIndex);
            SelectionMinimalistActivity.startListSelection((Activity) getContext(), bundle, new SelectionMinimalistActivity.OnResultReturnListener() {
                @Override
                public void onReturn(Object text) {
                    mJoinTypeIndex = (Integer) text;
                    updateProfile();
                }
            });
        } else if (v.getId() == R.id.about_im) {
            Intent intent = new Intent(getContext(), AboutIMMinimalistActivity.class);
            getContext().startActivity(intent);
        }
    }

    private void updateProfile() {
        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();

        int allowType = joinTypeIdList.get(mJoinTypeIndex);
        v2TIMUserFullInfo.setAllowType(allowType);

        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG, "modifySelfProfile err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess() {
                DemoLog.i(TAG, "modifySelfProfile success");
            }
        });
    }

}
