package com.tencent.qcloud.tim.demo.profile;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIKitConstants;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.activities.SelectionActivity;
import com.tencent.qcloud.tuicore.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.List;

public class ProfileLayout extends FrameLayout implements View.OnClickListener {

    private static final String TAG = ProfileLayout.class.getSimpleName();

    private ShadeImageView userIcon;
    private TextView accountView;
    private TextView nickNameView;
    private TextView signatureView;
    private TextView signatureTagView;

    private LineControllerView modifyAllowTypeView;
    private LineControllerView aboutIM;
    private LineControllerView modifyThemeView;
    private LineControllerView modifyLanguageView;
    private RelativeLayout selfDetailArea;

    private ArrayList<String> joinTypeTextList = new ArrayList<>();
    private ArrayList<Integer> joinTypeIdList = new ArrayList<>();
    private int mJoinTypeIndex = 2;
    private String mIconUrl;
    private String mSignature;
    private String mNickName;

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

        selfDetailArea = findViewById(R.id.self_detail_area);
        selfDetailArea.setOnClickListener(this);

        userIcon = findViewById(R.id.self_icon);
        int radius = getResources().getDimensionPixelSize(R.dimen.demo_profile_face_radius);
        userIcon.setRadius(radius);
        accountView = findViewById(R.id.self_account);
        nickNameView = findViewById(R.id.self_nick_name);
        signatureView = findViewById(R.id.self_signature);
        signatureTagView = findViewById(R.id.self_signature_tag);
        modifyAllowTypeView = findViewById(R.id.modify_allow_type);
        modifyAllowTypeView.setCanNav(true);
        modifyAllowTypeView.setOnClickListener(this);

        aboutIM = findViewById(R.id.about_im);
        aboutIM.setCanNav(true);
        aboutIM.setOnClickListener(this);

        modifyThemeView = findViewById(R.id.modify_theme);
        modifyThemeView.setCanNav(false);
        modifyThemeView.setOnClickListener(this);
        modifyThemeView.setContent(getResources().getString(R.string.demo_theme_light));
        modifyLanguageView = findViewById(R.id.modify_language);
        modifyLanguageView.setCanNav(false);
        modifyLanguageView.setOnClickListener(this);

        joinTypeTextList.add(getResources().getString(R.string.allow_type_allow_any));
        joinTypeTextList.add(getResources().getString(R.string.allow_type_deny_any));
        joinTypeTextList.add(getResources().getString(R.string.allow_type_need_confirm));
        joinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_ALLOW_ANY);
        joinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_DENY_ANY);
        joinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_NEED_CONFIRM);

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

    private void setUserInfo(V2TIMUserFullInfo info) {
        mIconUrl = info.getFaceUrl();
        int radius = getResources().getDimensionPixelSize(R.dimen.demo_profile_face_radius);
        GlideEngine.loadUserIcon(userIcon, Uri.parse(mIconUrl), radius);
        mNickName = info.getNickName();
        if (TextUtils.isEmpty(mNickName)) {
            nickNameView.setVisibility(GONE);
        } else {
            nickNameView.setVisibility(VISIBLE);
        }
        nickNameView.setText(mNickName);
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
        // 点击个人详情区域
        if (v.getId() == R.id.self_detail_area) {
            Intent intent = new Intent(getContext(), SelfDetailActivity.class);
            getContext().startActivity(intent);
        }
        if (v.getId() == R.id.modify_allow_type) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.add_rule));
            bundle.putStringArrayList(TUIKitConstants.Selection.LIST, joinTypeTextList);
            bundle.putInt(TUIKitConstants.Selection.DEFAULT_SELECT_ITEM_INDEX, mJoinTypeIndex);
            SelectionActivity.startListSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(Object text) {
                    mJoinTypeIndex = (Integer) text;
                    updateProfile();
                }
            });
        } else if (v.getId() == R.id.about_im) {
            Intent intent = new Intent(getContext(), AboutIMActivity.class);
            getContext().startActivity(intent);
        }
    }

    private void updateProfile() {
        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();

        // 加我验证方式
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
