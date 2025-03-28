package com.tencent.cloud.tuikit.roomkit.view.basic;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
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

    private TextView       mTextCountDown;
    private CountDownTimer mCountDownTimer;
    private int            mAutoConfirmSeconds = 0;

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
        initTextCountDown();
    }

    @Override
    public void show() {
        super.show();
        if (mAutoConfirmSeconds == 0) {
            return;
        }
        mCountDownTimer = new CountDownTimer(mAutoConfirmSeconds * 1000L, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                mTextCountDown.setText(getContext().getString(R.string.tuiroomkit_confirm_dialog_count_down_text, String.valueOf(millisUntilFinished / 1000)));
            }

            @Override
            public void onFinish() {
                if (mPositiveClickListener != null) {
                    mPositiveClickListener.onClick();
                }
                mCountDownTimer.cancel();
            }
        };
        mCountDownTimer.start();
    }

    @Override
    public void dismiss() {
        super.dismiss();
        if (mCountDownTimer != null) {
            mCountDownTimer.cancel();
        }
    }

    private void initTextMessage() {
        TextView textMessage = findViewById(R.id.tv_message);
        textMessage.setText(mMessageText);
    }

    private void initButtonPositive() {
        LinearLayout positiveLayout = findViewById(R.id.btn_positive);

        if (mPositiveClickListener == null) {
            positiveLayout.setVisibility(View.GONE);
            return;
        }
        if (!TextUtils.isEmpty(mPositiveText)) {
            TextView positiveTextView = findViewById(R.id.text_positive);
            positiveTextView.setText(mPositiveText);
        }
        positiveLayout.setOnClickListener(new View.OnClickListener() {
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

    private void initTextCountDown() {
        mTextCountDown = findViewById(R.id.tv_count_down);
        if (mAutoConfirmSeconds == 0) {
            return;
        }
        mTextCountDown.setVisibility(View.VISIBLE);
        mTextCountDown.setText(getContext().getString(R.string.tuiroomkit_confirm_dialog_count_down_text, String.valueOf(mAutoConfirmSeconds)));
    }

    public void setAutoConfirmSeconds(int seconds) {
        mAutoConfirmSeconds = seconds;
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