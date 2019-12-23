package com.tencent.qcloud.tim.demo.profile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMFriendAllowType;
import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMUserProfile;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.component.LineControllerView;
import com.tencent.qcloud.tim.uikit.component.SelectionActivity;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;
import com.tencent.qcloud.tim.uikit.component.picture.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.HashMap;
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
    private ArrayList<String> mJoinTypeIdList = new ArrayList<>();
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
        TIMUserProfile profile = TIMFriendshipManager.getInstance().querySelfProfile();
        if (profile != null) {
            if (!TextUtils.isEmpty(profile.getFaceUrl())) {
                GlideEngine.loadImage(mUserIcon, Uri.parse(profile.getFaceUrl()));
            }
        } else {
            SharedPreferences shareInfo = getContext().getSharedPreferences(Constants.USERINFO, Context.MODE_PRIVATE);
            String url = shareInfo.getString(Constants.ICON_URL, "");
            if (!TextUtils.isEmpty(url)) {
                GlideEngine.loadImage(mUserIcon, Uri.parse(url));
            }
        }

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
        mJoinTypeIdList.add(TIMFriendAllowType.TIM_FRIEND_ALLOW_ANY);
        mJoinTypeIdList.add(TIMFriendAllowType.TIM_FRIEND_DENY_ANY);
        mJoinTypeIdList.add(TIMFriendAllowType.TIM_FRIEND_NEED_CONFIRM);

        mAccountView.setText(String.format(getResources().getString(R.string.id), TIMManager.getInstance().getLoginUser()));
        TIMFriendshipManager.getInstance().getSelfProfile(new TIMValueCallBack<TIMUserProfile>() {
            @Override
            public void onError(int i, String s) {
                DemoLog.e(TAG, "initSelfProfile err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
            }

            @Override
            public void onSuccess(TIMUserProfile profile) {
                DemoLog.i(TAG, "initSelfProfile success, timUserProfile = " + profile.toString());
                mModifyNickNameView.setContent(profile.getNickName());
                mAccountView.setText(String.format(getResources().getString(R.string.id), profile.getIdentifier()));
                mModifySignatureView.setContent(profile.getSelfSignature());
                mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
                if (TextUtils.equals(TIMFriendAllowType.TIM_FRIEND_ALLOW_ANY, profile.getAllowType())) {
                    mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_allow_any));
                    mJoinTypeIndex = 0;
                } else if (TextUtils.equals(TIMFriendAllowType.TIM_FRIEND_DENY_ANY, profile.getAllowType())) {
                    mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_deny_any));
                    mJoinTypeIndex = 1;
                } else if (TextUtils.equals(TIMFriendAllowType.TIM_FRIEND_NEED_CONFIRM, profile.getAllowType())) {
                    mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
                    mJoinTypeIndex = 2;
                } else {
                    mModifyAllowTypeView.setContent(profile.getAllowType());
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.modify_user_icon) {
            mIconUrl = String.format("https://picsum.photos/id/%d/200/200", new Random().nextInt(1000));
            GlideEngine.loadImage(mUserIcon, Uri.parse(mIconUrl));
            updateProfile();

            SharedPreferences shareInfo = getContext().getSharedPreferences(Constants.USERINFO, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = shareInfo.edit();
            editor.putString(Constants.ICON_URL, mIconUrl);
            editor.commit();

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

        // 头像
        if (!TextUtils.isEmpty(mIconUrl)) {
            hashMap.put(TIMUserProfile.TIM_PROFILE_TYPE_KEY_FACEURL, mIconUrl);
        }

        // 昵称
        String nickName = mModifyNickNameView.getContent();
        hashMap.put(TIMUserProfile.TIM_PROFILE_TYPE_KEY_NICK, nickName);

        // 个性签名
        String signature = mModifySignatureView.getContent();
        hashMap.put(TIMUserProfile.TIM_PROFILE_TYPE_KEY_SELFSIGNATURE, signature);

        // 地区
        hashMap.put(TIMUserProfile.TIM_PROFILE_TYPE_KEY_LOCATION, "sz");

        // 加我验证方式
        String allowType = mJoinTypeIdList.get(mJoinTypeIndex);
        hashMap.put(TIMUserProfile.TIM_PROFILE_TYPE_KEY_ALLOWTYPE, allowType);

        TIMFriendshipManager.getInstance().modifySelfProfile(hashMap, new TIMCallBack() {
            @Override
            public void onError(int i, String s) {
                DemoLog.e(TAG, "modifySelfProfile err code = " + i + ", desc = " + s);
                ToastUtil.toastShortMessage("Error code = " + i + ", desc = " + s);
            }

            @Override
            public void onSuccess() {
                DemoLog.i(TAG, "modifySelfProfile success");
            }
        });
    }

}
