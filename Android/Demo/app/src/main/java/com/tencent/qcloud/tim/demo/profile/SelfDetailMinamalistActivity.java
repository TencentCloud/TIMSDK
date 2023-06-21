package com.tencent.qcloud.tim.demo.profile;

import android.app.DatePickerDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.DatePicker;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.PopupInputCard;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseMinimalistLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.ImageSelectMinimalistActivity;
import com.tencent.qcloud.tuikit.timcommon.component.activities.SelectionMinimalistActivity;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.ShadeImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.regex.Pattern;

public class SelfDetailMinamalistActivity extends BaseMinimalistLightActivity implements View.OnClickListener {
    private static final String TAG = SelfDetailMinamalistActivity.class.getSimpleName();

    private static final int CHOOSE_AVATAR_REQUEST_CODE = 1;
    private TitleBarLayout titleBarLayout;
    private ShadeImageView selfIcon;
    private TextView modifyNickNameTv;
    private TextView nickNameTv;
    private MinimalistLineControllerView accountLv;
    private MinimalistLineControllerView genderLv;
    private MinimalistLineControllerView birthdayLv;
    private MinimalistLineControllerView signatureLv;

    private String faceUrl;
    private String nickName;
    private int gender;
    private long birthday;
    private String signature;
    private V2TIMSDKListener v2TIMSDKListener = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.minimalist_activity_self_detail);

        titleBarLayout = findViewById(R.id.self_detail_title_bar);
        selfIcon = findViewById(R.id.self_icon);
        modifyNickNameTv = findViewById(R.id.modify_nick_name_lv);
        nickNameTv = findViewById(R.id.user_nick_name_tv);
        accountLv = findViewById(R.id.modify_account_lv);
        genderLv = findViewById(R.id.modify_gender_lv);
        birthdayLv = findViewById(R.id.modify_birthday_lv);
        signatureLv = findViewById(R.id.modify_signature_lv);

        setupViews();
    }

    private void setupViews() {
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.setTitle(getString(R.string.demo_profile_detail), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.setOnLeftClickListener(this);

        int radius = ScreenUtil.dip2px(48);
        selfIcon.setRadius(radius);
        selfIcon.setOnClickListener(this);
        modifyNickNameTv.setOnClickListener(this);
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
            public void onError(int code, String desc) {}
        });
        setUserInfoListener();
    }

    private void setUserInfo(V2TIMUserFullInfo info) {
        faceUrl = info.getFaceUrl();
        int radius = getResources().getDimensionPixelSize(R.dimen.demo_profile_face_radius);
        GlideEngine.loadUserIcon(selfIcon, faceUrl, radius);
        nickName = info.getNickName();
        nickNameTv.setText(nickName);
        birthday = info.getBirthday();
        String birthdayStr = String.valueOf(info.getBirthday());
        if (TextUtils.isEmpty(birthdayStr) || birthdayStr.length() < 8) {
            birthdayStr = "19700101";
        }
        StringBuilder sb = new StringBuilder(birthdayStr);
        sb.insert(4, "-");
        sb.insert(7, "-");
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
        v2TIMSDKListener = new V2TIMSDKListener() {
            @Override
            public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
                setUserInfo(info);
            }
        };
        V2TIMManager.getInstance().addIMSDKListener(v2TIMSDKListener);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        V2TIMManager.getInstance().removeIMSDKListener(v2TIMSDKListener);
    }

    @Override
    public void onClick(View v) {
        if (v == selfIcon) {
            ArrayList<ImageSelectMinimalistActivity.ImageBean> faceList = new ArrayList<>();
            for (int i = 0; i < Constants.AVATAR_FACE_COUNT; i++) {
                ImageSelectMinimalistActivity.ImageBean imageBean = new ImageSelectMinimalistActivity.ImageBean();
                imageBean.setThumbnailUri(String.format(Constants.AVATAR_FACE_URL, (i + 1) + ""));
                imageBean.setImageUri(String.format(Constants.AVATAR_FACE_URL, (i + 1) + ""));
                faceList.add(imageBean);
            }

            Intent intent = new Intent(SelfDetailMinamalistActivity.this, ImageSelectMinimalistActivity.class);
            intent.putExtra(ImageSelectMinimalistActivity.TITLE, getString(R.string.demo_choose_avatar));
            intent.putExtra(ImageSelectMinimalistActivity.SPAN_COUNT, 4);
            intent.putExtra(ImageSelectMinimalistActivity.ITEM_WIDTH, ScreenUtil.dip2px(77));
            intent.putExtra(ImageSelectMinimalistActivity.ITEM_HEIGHT, ScreenUtil.dip2px(77));
            intent.putExtra(ImageSelectMinimalistActivity.DATA, faceList);
            intent.putExtra(ImageSelectMinimalistActivity.SELECTED, new ImageSelectMinimalistActivity.ImageBean(faceUrl, faceUrl, false));
            startActivityForResult(intent, CHOOSE_AVATAR_REQUEST_CODE);
        } else if (v == modifyNickNameTv) {
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
        bundle.putString(SelectionMinimalistActivity.Selection.TITLE, getString(R.string.modify_gender));
        bundle.putStringArrayList(SelectionMinimalistActivity.Selection.LIST, genderList);
        bundle.putInt(SelectionMinimalistActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, gender - 1);

        SelectionMinimalistActivity.startListSelection(this, bundle, new SelectionMinimalistActivity.OnResultReturnListener() {
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
        if (!TextUtils.isEmpty(faceUrl)) {
            v2TIMUserFullInfo.setFaceUrl(faceUrl);
        }

        v2TIMUserFullInfo.setNickname(nickName);

        if (birthday != 0) {
            v2TIMUserFullInfo.setBirthday(birthday);
        }

        v2TIMUserFullInfo.setSelfSignature(signature);

        v2TIMUserFullInfo.setGender(gender);

        V2TIMManager.getInstance().setSelfInfo(v2TIMUserFullInfo, new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                DemoLog.e(TAG, "modifySelfProfile err code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
                ToastUtil.toastShortMessage("Error code = " + code + ", desc = " + ErrorMessageConverter.convertIMError(code, desc));
            }

            @Override
            public void onSuccess() {
                DemoLog.i(TAG, "modifySelfProfile success");
                if (!TextUtils.isEmpty(faceUrl)) {
                    UserInfo.getInstance().setAvatar(faceUrl);
                }
                UserInfo.getInstance().setName(nickName);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CHOOSE_AVATAR_REQUEST_CODE && resultCode == ImageSelectMinimalistActivity.RESULT_CODE_SUCCESS) {
            if (data != null) {
                ImageSelectMinimalistActivity.ImageBean imageBean =
                    (ImageSelectMinimalistActivity.ImageBean) data.getSerializableExtra(ImageSelectMinimalistActivity.DATA);
                if (imageBean == null) {
                    return;
                }

                faceUrl = imageBean.getImageUri();
                updateProfile();
            }
        }
    }
}