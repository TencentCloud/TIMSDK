package com.tencent.cloud.tuikit.roomkit.view.component;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.roomkit.R;

public class ConfirmDialog extends Dialog {
    private static final String TAG = "ConfirmDialogFragment";

    private View                  mDivideLine;
    private String                mMessageText;
    private String                mPositiveText;
    private String                mNegativeText;
    private PositiveClickListener mPositiveClickListener;
    private NegativeClickListener mNegativeClickListener;

    public ConfirmDialog(@NonNull Context context) {
        super(context, R.style.TUIRoomDialogTheme);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tuiroomkit_dialog_confirm);
        setCancelable(false);
        mDivideLine = findViewById(R.id.divide_line);
        initTextMessage();
        initButtonPositive();
        initButtonNegative();
    }

    private void initTextMessage() {
        TextView textMessage = findViewById(R.id.tv_message);
        textMessage.setText(mMessageText);
    }

    private void initButtonPositive() {
        Button buttonPositive = findViewById(R.id.btn_positive);

        if (mPositiveClickListener == null) {
            buttonPositive.setVisibility(View.GONE);
            return;
        }
        if (!TextUtils.isEmpty(mPositiveText)) {
            buttonPositive.setText(mPositiveText);
        }
        buttonPositive.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mPositiveClickListener.onClick();
            }
        });
    }

    private void initButtonNegative() {
        Button buttonNegative = findViewById(R.id.btn_negative);

        if (mNegativeClickListener == null) {
            buttonNegative.setVisibility(View.GONE);
            mDivideLine.setVisibility(View.GONE);
            return;
        }
        if (!TextUtils.isEmpty(mNegativeText)) {
            buttonNegative.setText(mNegativeText);
        }
        buttonNegative.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mNegativeClickListener.onClick();
            }
        });
    }

    public void setMessage(String message) {
        mMessageText = message;
    }

    public void setPositiveText(String text) {
        mPositiveText = text;
    }

    public void setNegativeText(String text) {
        mNegativeText = text;
    }

    public void setPositiveClickListener(PositiveClickListener listener) {
        this.mPositiveClickListener = listener;
    }

    public void setNegativeClickListener(NegativeClickListener listener) {
        this.mNegativeClickListener = listener;
    }

    public interface PositiveClickListener {
        void onClick();
    }

    public interface NegativeClickListener {
        void onClick();
    }
}