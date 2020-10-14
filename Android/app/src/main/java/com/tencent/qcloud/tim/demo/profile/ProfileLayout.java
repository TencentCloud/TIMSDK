package com.tencent.qcloud.tim.demo.profile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.Nullable;

import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.login.UserInfo;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.qcloud.tim.tuikit.live.base.TUILiveRequestCallback;
import com.tencent.qcloud.tim.uikit.component.LineControllerView;
import com.tencent.qcloud.tim.uikit.component.SelectionActivity;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;

public class ProfileLayout extends LinearLayout implements View.OnClickListener {

    private static final String TAG = ProfileLayout.class.getSimpleName();

    private ImageView mUserIcon;
    private TextView mAccountView;
    private TitleBarLayout mTitleBar;

    private LineControllerView mModifyUserIconView;
    private LineControllerView mModifyNickNameView;
    private LineControllerView mModifyAllowTypeView;
    private LineControllerView mModifySignatureView;
    private LineControllerView mAboutIM;
    private ArrayList<String> mJoinTypeTextList = new ArrayList<>();
    private ArrayList<Integer> mJoinTypeIdList = new ArrayList<>();
    private int mJoinTypeIndex = 2;
    private String mIconUrl;

    public ProfileLayout(Context context) {
        super(context);
        init();
    }

    public ProfileLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ProfileLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.profile_layout, this);

        mUserIcon = findViewById(R.id.self_icon);
        GlideEngine.loadImage(mUserIcon, UserInfo.getInstance().getAvatar());
        mAccountView = findViewById(R.id.self_account);

        mTitleBar = findViewById(R.id.self_info_title_bar);
        mTitleBar.getLeftGroup().setVisibility(GONE);
        mTitleBar.getRightGroup().setVisibility(GONE);
        mTitleBar.setTitle(getResources().getString(R.string.profile), TitleBarLayout.POSITION.MIDDLE);

        mModifyUserIconView = findViewById(R.id.modify_user_icon);
        mModifyUserIconView.setCanNav(false);
        mModifyUserIconView.setOnClickListener(this);
        mModifySignatureView = findViewById(R.id.modify_signature);
        mModifySignatureView.setCanNav(true);
        mModifySignatureView.setOnClickListener(this);
        mModifyNickNameView = findViewById(R.id.modify_nick_name);
        mModifyNickNameView.setCanNav(true);
        mModifyNickNameView.setOnClickListener(this);
        mModifyAllowTypeView = findViewById(R.id.modify_allow_type);
        mModifyAllowTypeView.setCanNav(true);
        mModifyAllowTypeView.setOnClickListener(this);
        mAboutIM = findViewById(R.id.about_im);
        mAboutIM.setCanNav(true);
        mAboutIM.setOnClickListener(this);

        mJoinTypeTextList.add(getResources().getString(R.string.allow_type_allow_any));
        mJoinTypeTextList.add(getResources().getString(R.string.allow_type_deny_any));
        mJoinTypeTextList.add(getResources().getString(R.string.allow_type_need_confirm));
        mJoinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_ALLOW_ANY);
        mJoinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_DENY_ANY);
        mJoinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_NEED_CONFIRM);

        String selfUserID = V2TIMManager.getInstance().getLoginUser();

        mAccountView.setText(String.format(getResources().getString(R.string.id), selfUserID));

        List<String> userList = new ArrayList<>();
        userList.add(selfUserID);
        V2TIMManager.getInstance().getUsersInfo(userList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG, "initSelfProfile err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                if (v2TIMUserFullInfos == null || v2TIMUserFullInfos.size() == 0) {
                    DemoLog.e(TAG, "getUsersInfo success but is empty");
                    return;
                }
                V2TIMUserFullInfo v2TIMUserFullInfo = v2TIMUserFullInfos.get(0);
                DemoLog.i(TAG, "initSelfProfile success, v2TIMUserFullInfo = " + v2TIMUserFullInfo.toString());
                if (TextUtils.isEmpty(v2TIMUserFullInfo.getFaceUrl())) {
                    GlideEngine.loadImage(mUserIcon, R.drawable.default_user_icon);
                } else {
                    GlideEngine.loadImage(mUserIcon, Uri.parse(v2TIMUserFullInfo.getFaceUrl()));
                }
                TUIKitConfigs.getConfigs().getGeneralConfig().setUserFaceUrl(v2TIMUserFullInfo.getFaceUrl());
                TUIKitConfigs.getConfigs().getGeneralConfig().setUserNickname(v2TIMUserFullInfo.getNickName());

                mModifyNickNameView.setContent(v2TIMUserFullInfo.getNickName());
                mAccountView.setText(String.format(getResources().getString(R.string.id), v2TIMUserFullInfo.getUserID()));
                mModifySignatureView.setContent(v2TIMUserFullInfo.getSelfSignature());
                mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
                if (v2TIMUserFullInfo.getAllowType() == V2TIMUserFullInfo.V2TIM_FRIEND_ALLOW_ANY) {
                    mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_allow_any));
                    mJoinTypeIndex = 0;
                } else if (v2TIMUserFullInfo.getAllowType() == V2TIMUserFullInfo.V2TIM_FRIEND_DENY_ANY) {
                    mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_deny_any));
                    mJoinTypeIndex = 1;
                } else if (v2TIMUserFullInfo.getAllowType() == V2TIMUserFullInfo.V2TIM_FRIEND_NEED_CONFIRM) {
                    mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
                    mJoinTypeIndex = 2;
                } else {
                    mModifyAllowTypeView.setContent("");
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.modify_user_icon) {
            String selfUserID = V2TIMManager.getInstance().getLoginUser();
            if (TextUtils.isEmpty(selfUserID)) {
                DemoLog.e(TAG, "selfUserID:" + selfUserID);
                return;
            }
            byte[] bytes = selfUserID.getBytes();
            int index = bytes[bytes.length - 1] % 10;
            String avatarName = "avatar" + index + "_100";
            mIconUrl = "https://imgcache.qq.com/qcloud/public/static/" + avatarName + ".20191230.png";
            GlideEngine.loadImage(mUserIcon, Uri.parse(mIconUrl));
            updateProfile();
        } else if (v.getId() == R.id.modify_nick_name) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.modify_nick_name));
            bundle.putString(TUIKitConstants.Selection.INIT_CONTENT, mModifyNickNameView.getContent());
            bundle.putInt(TUIKitConstants.Selection.LIMIT, 20);
            SelectionActivity.startTextSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(Object text) {
                    mModifyNickNameView.setContent(text.toString());
                    updateProfile();
                }
            });
        } else if (v.getId() == R.id.modify_allow_type) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.add_rule));
            bundle.putStringArrayList(TUIKitConstants.Selection.LIST, mJoinTypeTextList);
            bundle.putInt(TUIKitConstants.Selection.DEFAULT_SELECT_ITEM_INDEX, mJoinTypeIndex);
            SelectionActivity.startListSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(Object text) {
                    mModifyAllowTypeView.setContent(mJoinTypeTextList.get((Integer) text));
                    mJoinTypeIndex = (Integer) text;
                    updateProfile();
                }
            });
        } else if (v.getId() == R.id.modify_signature) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.modify_signature));
            bundle.putString(TUIKitConstants.Selection.INIT_CONTENT, mModifySignatureView.getContent());
            bundle.putInt(TUIKitConstants.Selection.LIMIT, 20);
            SelectionActivity.startTextSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(Object text) {
                    mModifySignatureView.setContent(text.toString());
                    updateProfile();
                }
            });
        } else if (v.getId() == R.id.about_im) {
            Intent intent = new Intent((Activity) getContext(), WebViewActivity.class);
            ((Activity) getContext()).startActivity(intent);
        }
    }

    private void updateProfile() {
        HashMap<String, Object> hashMap = new HashMap<>();

        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        // 头像
        if (!TextUtils.isEmpty(mIconUrl)) {
            v2TIMUserFullInfo.setFaceUrl(mIconUrl);
            UserInfo.getInstance().setAvatar(mIconUrl);
        }

        // 昵称
        String nickName = mModifyNickNameView.getContent();
        v2TIMUserFullInfo.setNickname(nickName);

        // 个性签名
        String signature = mModifySignatureView.getContent();
        v2TIMUserFullInfo.setSelfSignature(signature);

        // 加我验证方式
        int allowType = mJoinTypeIdList.get(mJoinTypeIndex);
        v2TIMUserFullInfo.setAllowType(allowType);

        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG, "modifySelfProfile err code = " + code + ", desc = " + desc);
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess() {
                DemoLog.i(TAG, "modifySelfProfile success");
                TUIKitConfigs.getConfigs().getGeneralConfig().setUserFaceUrl(mIconUrl);
                TUIKitConfigs.getConfigs().getGeneralConfig().setUserNickname(mModifyNickNameView.getContent());
                TUIKitLive.refreshLoginUserInfo(null);
            }
        });
    }

}
