package com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo;

import android.content.Context;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.FrameLayout;

import androidx.appcompat.widget.SwitchCompat;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.tencent.cloud.tuikit.roomkit.R;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.Random;

public class SetConferenceEncryptView extends FrameLayout {
    private static final int              PASSWORD_LENGTH = 6;
    private              Context          mContext;
    private              SwitchCompat     mSwitchEncryption;
    private              ConstraintLayout mLayoutRoomPassword;
    private              EditText         mEditPassword;

    private       ScheduleConferenceStateHolder             mStateHolder;
    private final Observer<SetConferenceEncryptViewUiState> mEncryptObserver = this::updateView;

    public SetConferenceEncryptView(Context context) {
        super(context);
        mContext = context;
        initView();
    }

    public void setStateHolder(ScheduleConferenceStateHolder stateHolder) {
        mStateHolder = stateHolder;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeEncrypt(mEncryptObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeEncryptObserver(mEncryptObserver);
    }

    private void initView() {
        addView(LayoutInflater.from(mContext)
                .inflate(R.layout.tuiroomkit_view_set_conference_encrypt,
                        this, false));
        mSwitchEncryption = findViewById(R.id.switch_room_encryption);
        mLayoutRoomPassword = findViewById(R.id.cl_room_password);
        mEditPassword = findViewById(R.id.edit_room_password);
        mEditPassword.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable password) {
                mStateHolder.updatePassword(password.toString());
            }
        });
        mSwitchEncryption.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean isEnable) {
                mStateHolder.updateEnableEncrypt(isEnable);
                if (isEnable) {
                    mEditPassword.setText(generateRandomPassword());
                }
            }
        });

        if (!mSwitchEncryption.isEnabled()) {
            mLayoutRoomPassword.setVisibility(GONE);
        }
    }

    private String generateRandomPassword() {
        Random random = new Random();
        int minNumber = (int) Math.pow(10, PASSWORD_LENGTH - 1);
        int maxNumber = (int) Math.pow(10, PASSWORD_LENGTH) - 1;
        int randomNumber = random.nextInt(maxNumber - minNumber) + minNumber;
        String password = randomNumber + "";
        return password;
    }

    public void disableSetEncrypt() {
        mSwitchEncryption.setClickable(false);
        mLayoutRoomPassword.setClickable(false);
    }

    private void updateView(SetConferenceEncryptViewUiState uiState) {
        mLayoutRoomPassword.setVisibility(uiState.isEnableEncrypt ? VISIBLE : GONE);
        if (!uiState.isEnableEncrypt && !TextUtils.isEmpty(mEditPassword.getText())) {
            mEditPassword.setText("");
        }
    }
}
