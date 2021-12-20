package com.tencent.qcloud.tim.demo.profile;

import androidx.appcompat.app.AppCompatActivity;

import android.app.DatePickerDialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.DatePicker;
import android.widget.ImageView;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tuicore.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuicore.component.popupcard.PopupInputCard;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.SelectionActivity;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Random;
import java.util.regex.Pattern;

public class SelfDetailActivity extends AppCompatActivity implements View.OnClickListener {
    private static final String TAG = SelfDetailActivity.class.getSimpleName();

    private TitleBarLayout titleBarLayout;
    private ShadeImageView selfIcon;
    private LineControllerView nickNameLv;
    private LineControllerView accountLv;
    private LineControllerView genderLv;
    private LineControllerView birthdayLv;
    private LineControllerView signatureLv;

    private String faceUrl;
    private String nickName;
    private int gender;
    private long birthday;
    private String signature;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_self_detail);

        titleBarLayout = findViewById(R.id.self_detail_title_bar);
        selfIcon = findViewById(R.id.self_icon);
        nickNameLv = findViewById(R.id.modify_nick_name_lv);
        accountLv = findViewById(R.id.modify_account_lv);
        genderLv = findViewById(R.id.modify_gender_lv);
        birthdayLv = findViewById(R.id.modify_birthday_lv);
        signatureLv = findViewById(R.id.modify_signature_lv);

        setupViews();
    }

    private void setupViews() {
        titleBarLayout.setLeftIcon(R.drawable.demo_back);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.setTitle(getString(R.string.demo_profile_detail), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.setOnLeftClickListener(this);

        int radius = getResources().getDimensionPixelSize(R.dimen.demo_profile_face_radius);
        selfIcon.setRadius(radius);
        selfIcon.setOnClickListener(this);
        nickNameLv.setOnClickListener(this);
        accountLv.setOnClickListener(this);
        genderLv.setOnClickListener(this);
        birthdayLv.setOnClickListener(this);
        signatureLv.setOnClickListener(this);

        String selfUserID = V2TIMManager.getInstance().getLoginUser();
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
        faceUrl = info.getFaceUrl();
        int radius = getResources().getDimensionPixelSize(R.dimen.demo_profile_face_radius);
        GlideEngine.loadUserIcon(selfIcon, faceUrl, radius);
        nickName = info.getNickName();
        nickNameLv.setContent(nickName);
        birthday = info.getBirthday();
        String birthdayStr = String.valueOf(info.getBirthday());
        if (TextUtils.isEmpty(birthdayStr) || birthdayStr.length() < 8) {
            birthdayStr = "19700101";
        }
        StringBuilder sb=new StringBuilder(birthdayStr);
        sb.insert(4,"-");
        sb.insert(7,"-");
        birthdayStr = sb.toString();
        birthdayLv.setContent(birthdayStr);
        accountLv.setContent(info.getUserID());

        signature = info.getSelfSignature();
        signatureLv.setContent(signature);

        gender = info.getGender();
        String genderStr = getString(R.string.demo_self_detail_gender_unknown);
        if (gender == 1) {
            genderStr = getString(R.string.demo_self_detail_gender_male);
        } else if (gender == 2) {
            genderStr = getString(R.string.demo_self_detail_gender_female);
        }
        genderLv.setContent(genderStr);
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
        if (v == selfIcon) {
            faceUrl = String.format("https://picsum.photos/id/%d/200/200", new Random().nextInt(1000));
            updateProfile();
        } else if (v == nickNameLv) {
            PopupInputCard popupInputCard = new PopupInputCard(this);
            popupInputCard.setContent(nickName);
            popupInputCard.setTitle(getString(R.string.demo_self_detail_modify_nickname));
            String description = getString(R.string.demo_self_detail_modify_nickname_rule);
            popupInputCard.setDescription(description);
            popupInputCard.setOnPositive((result -> {
                if (!Pattern.matches("^[a-zA-Z0-9_\u4e00-\u9fa5]*$", result)) {
                    ToastUtil.toastShortMessage(description);
                    return;
                }

                nickName = result;
                updateProfile();
            }));
            View rootView = findViewById(android.R.id.content);
            popupInputCard.show(rootView, Gravity.BOTTOM);
        } else if (v == accountLv) {
            // do nothing
        } else if (v == genderLv) {
            setGender();
        } else if (v == birthdayLv) {
            setBirthday();
        } else if (v == signatureLv) {
            PopupInputCard popupInputCard = new PopupInputCard(this);
            popupInputCard.setContent(signature);
            popupInputCard.setTitle(getString(R.string.demo_self_detail_modify_signature));
            String description = getString(R.string.demo_self_detail_modify_nickname_rule);
            popupInputCard.setDescription(description);
            popupInputCard.setOnPositive((result -> {
                if (!Pattern.matches("^[a-zA-Z0-9_\u4e00-\u9fa5]*$", result)) {
                    ToastUtil.toastShortMessage(description);
                    return;
                }

                signature = result;
                updateProfile();
            }));
            View rootView = findViewById(android.R.id.content);
            popupInputCard.show(rootView, Gravity.BOTTOM);
        } else if (v == titleBarLayout.getLeftGroup()) {
            finish();
        }
    }

    private void setGender() {
        Bundle bundle = new Bundle();
        ArrayList<String> genderList = new ArrayList<>();
        genderList.add(getString(R.string.demo_self_detail_gender_male));
        genderList.add(getString(R.string.demo_self_detail_gender_female));
        bundle.putString(SelectionActivity.Selection.TITLE, getString(R.string.modify_gender));
        bundle.putStringArrayList(SelectionActivity.Selection.LIST, genderList);
        bundle.putInt(SelectionActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, gender - 1);

        SelectionActivity.startListSelection(this, bundle, new SelectionActivity.OnResultReturnListener() {
            @Override
            public void onReturn(Object res) {
                gender = (Integer) res + 1;
                updateProfile();
            }
        });
    }

    public void setBirthday() {
        final Calendar c = Calendar.getInstance();
        int year = c.get(Calendar.YEAR);
        int month = c.get(Calendar.MONTH);
        int day = c.get(Calendar.DAY_OF_MONTH);

        //日历控件
        DatePickerDialog dp = new DatePickerDialog(this, new DatePickerDialog.OnDateSetListener() {
            @Override
            public void onDateSet(DatePicker datePicker, int iyear, int monthOfYear, int dayOfMonth) {
                birthday = iyear * 10000 + (monthOfYear + 1) * 100 + dayOfMonth;
                updateProfile();
            }
        }, year, month, day);
        dp.show();
    }

    private void updateProfile() {
        V2TIMUserFullInfo v2TIMUserFullInfo = new V2TIMUserFullInfo();
        // 头像
        if (!TextUtils.isEmpty(faceUrl)) {
            v2TIMUserFullInfo.setFaceUrl(faceUrl);
            UserInfo.getInstance().setAvatar(faceUrl);
        }

        // 昵称
        v2TIMUserFullInfo.setNickname(nickName);
        UserInfo.getInstance().setName(nickName);

        // 生日
        if (birthday != 0) {
            v2TIMUserFullInfo.setBirthday(birthday);
        }

        // 个性签名
        v2TIMUserFullInfo.setSelfSignature(signature);

        v2TIMUserFullInfo.setGender(gender);

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