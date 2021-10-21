package com.tencent.qcloud.tim.demo.profile;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.DatePicker;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.demo.utils.TUIKitConstants;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.Calendar;
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
    private LineControllerView mModifyBirthdayView;
    private LineControllerView mIMPrivacyView;
    private LineControllerView mIMStatementView;
    private LineControllerView mAboutIM;
    private ArrayList<String> mJoinTypeTextList = new ArrayList<>();
    private ArrayList<Integer> mJoinTypeIdList = new ArrayList<>();
    private int mJoinTypeIndex = 2;
    private String mIconUrl;
    private String mBirthday;
    private String mSignature;
    private String mNickName;
    private int count = 0;
    private long lastClickTime = 0;

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
        mAccountView = findViewById(R.id.self_account);

        mTitleBar = findViewById(R.id.self_info_title_bar);
        mTitleBar.getLeftGroup().setVisibility(GONE);
        mTitleBar.getRightGroup().setVisibility(GONE);
        mTitleBar.setTitle(getResources().getString(R.string.profile), ITitleBarLayout.Position.MIDDLE);

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
        mIMPrivacyView = findViewById(R.id.im_privacy);
        mIMPrivacyView.setCanNav(true);
        mIMPrivacyView.setOnClickListener(this);
        mIMStatementView = findViewById(R.id.im_statement);
        mIMStatementView.setCanNav(true);
        mIMStatementView.setOnClickListener(this);
        mAboutIM = findViewById(R.id.about_im);
        mAboutIM.setCanNav(true);
        mAboutIM.setOnClickListener(this);
        mModifyBirthdayView = findViewById(R.id.modify_birthday);
        mModifyBirthdayView.setCanNav(true);
        mModifyBirthdayView.setOnClickListener(this);

        mJoinTypeTextList.add(getResources().getString(R.string.allow_type_allow_any));
        mJoinTypeTextList.add(getResources().getString(R.string.allow_type_deny_any));
        mJoinTypeTextList.add(getResources().getString(R.string.allow_type_need_confirm));
        mJoinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_ALLOW_ANY);
        mJoinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_DENY_ANY);
        mJoinTypeIdList.add(V2TIMUserFullInfo.V2TIM_FRIEND_NEED_CONFIRM);

        String selfUserID = V2TIMManager.getInstance().getLoginUser();

        mAccountView.setText(String.format(getResources().getString(R.string.id), selfUserID));
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
        if (TextUtils.isEmpty(mIconUrl)) {
            GlideEngine.loadImage(mUserIcon, R.drawable.default_user_icon);
        } else {
            GlideEngine.loadImage(mUserIcon, Uri.parse(mIconUrl));
        }
        mNickName = info.getNickName();
        mModifyNickNameView.setContent(mNickName);

        String birthday = String.valueOf(info.getBirthday());
        if (TextUtils.isEmpty(birthday) || birthday.length() < 8) {
            birthday = "19700101";
        }
        StringBuilder sb=new StringBuilder(birthday);
        sb.insert(4,"-");
        sb.insert(7,"-");
        mBirthday = sb.toString();
        mModifyBirthdayView.setContent(mBirthday);
        mAccountView.setText(String.format(getResources().getString(R.string.id), info.getUserID()));

        mSignature = info.getSelfSignature();
        mModifySignatureView.setContent(mSignature);
        mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
        int allowType = info.getAllowType();
        if (allowType == V2TIMUserFullInfo.V2TIM_FRIEND_ALLOW_ANY) {
            mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_allow_any));
            mJoinTypeIndex = 0;
        } else if (allowType == V2TIMUserFullInfo.V2TIM_FRIEND_DENY_ANY) {
            mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_deny_any));
            mJoinTypeIndex = 1;
        } else if (allowType == V2TIMUserFullInfo.V2TIM_FRIEND_NEED_CONFIRM) {
            mModifyAllowTypeView.setContent(getResources().getString(R.string.allow_type_need_confirm));
            mJoinTypeIndex = 2;
        } else {
            mModifyAllowTypeView.setContent("");
        }
    }

    private void setUserInfoListener() {
        V2TIMManager.getInstance().addIMSDKListener(new V2TIMSDKListener() {
            @Override
            public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
                setUserInfo(info);
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

            mIconUrl = String.format("https://picsum.photos/id/%d/200/200", new Random().nextInt(1000));
            updateProfile();
        } else if (v.getId() == R.id.modify_nick_name) {
            Bundle bundle = new Bundle();
            bundle.putString(TUIKitConstants.Selection.TITLE, getResources().getString(R.string.modify_nick_name));
            bundle.putString(TUIKitConstants.Selection.INIT_CONTENT, mModifyNickNameView.getContent());
            bundle.putInt(TUIKitConstants.Selection.LIMIT, 20);
            SelectionActivity.startTextSelection((Activity) getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
                @Override
                public void onReturn(Object text) {
                    mNickName = text.toString();
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
                    mSignature = text.toString();
                    updateProfile();
                }
            });
        } else if (v.getId() == R.id.about_im) {
            Intent intent = new Intent((Activity) getContext(), WebViewActivity.class);
            ((Activity) getContext()).startActivity(intent);
        } else if (v.getId() == R.id.modify_birthday) {
            final Calendar c = Calendar.getInstance();
            int year = c.get(Calendar.YEAR);
            int month = c.get(Calendar.MONTH);
            int day = c.get(Calendar.DAY_OF_MONTH);

            //日历控件
            DatePickerDialog dp = new DatePickerDialog(getContext(), new DatePickerDialog.OnDateSetListener() {
                @Override
                public void onDateSet(DatePicker datePicker, int iyear, int monthOfYear, int dayOfMonth) {
                    String year, month, day;

                    year = String.valueOf(iyear);
                    if(monthOfYear < 10){
                        month = "0" + monthOfYear;
                    } else {
                        month = String.valueOf(monthOfYear);
                    }

                    if(dayOfMonth < 10){
                        day  = "0" + dayOfMonth ;
                    } else {
                        day = String.valueOf(dayOfMonth);
                    }
                    String birthday = year + "-" + month + "-" + day;
                    mBirthday = birthday;
                    updateProfile();
                }
            }, year, month, day);
            dp.show();
        } else if (v.getId() == R.id.im_privacy) {
            Intent intent = new Intent();
            intent.setAction("android.intent.action.VIEW");
            Uri content_url = Uri.parse(Constants.IM_PRIVACY_PROTECTION);
            intent.setData(content_url);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            DemoApplication.instance().startActivity(intent);
        } else if (v.getId() == R.id.im_statement) {
            AlertDialog.Builder builder = new AlertDialog.Builder(getContext())
                    .setTitle(getContext().getString(R.string.im_statement))
                    .setMessage(getContext().getString(R.string.im_statement_content))
                    .setPositiveButton(getContext().getString(R.string.sure), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            if (getContext() == null){
                                DemoLog.d(TAG,"getContext is null!");
                                return;
                            }

                            dialog.dismiss();
                        }
                    });

            AlertDialog mDialogStatement = builder.create();
            mDialogStatement.show();
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
        v2TIMUserFullInfo.setNickname(mNickName);

        // 生日
        String birthday = TextUtils.isEmpty(mBirthday) ? "" : mBirthday;
        String birthdayValue = birthday.replace("-","");;
        v2TIMUserFullInfo.setBirthday(Long.valueOf(birthdayValue));

        // 个性签名
        v2TIMUserFullInfo.setSelfSignature(mSignature);

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
            }
        });
    }

}
