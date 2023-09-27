package com.tencent.qcloud.tuikit.timcommon.component;

import android.animation.ValueAnimator;
import android.app.Activity;
import android.graphics.drawable.ColorDrawable;
import android.text.Editable;
import android.text.InputFilter;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.EditText;
import android.widget.PopupWindow;
import android.widget.TextView;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.util.SoftKeyBoardUtil;
import java.util.regex.Pattern;

public class PopupInputCard {
    private PopupWindow popupWindow;

    private TextView titleTv;
    private EditText editText;
    private TextView descriptionTv;
    private Button positiveBtn;
    private View closeBtn;
    private OnClickListener positiveOnClickListener;
    private OnTextExceedListener textExceedListener;

    private int minLimit = 0;
    private int maxLimit = Integer.MAX_VALUE;
    private String rule;
    private String notMachRuleTip;
    private ByteLengthFilter lengthFilter = new ByteLengthFilter();

    public PopupInputCard(Activity activity) {
        View popupView = LayoutInflater.from(activity).inflate(R.layout.timcommon_layout_popup_card, null);
        titleTv = popupView.findViewById(R.id.popup_card_title);
        editText = popupView.findViewById(R.id.popup_card_edit);
        descriptionTv = popupView.findViewById(R.id.popup_card_description);
        positiveBtn = popupView.findViewById(R.id.popup_card_positive_btn);
        closeBtn = popupView.findViewById(R.id.close_btn);

        popupWindow = new PopupWindow(popupView, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT, true) {
            @Override
            public void showAtLocation(View anchor, int gravity, int x, int y) {
                if (activity != null && !activity.isFinishing()) {
                    Window dialogWindow = activity.getWindow();
                    startAnimation(dialogWindow, true);
                }
                editText.requestFocus();
                if (activity.getWindow() != null) {
                    SoftKeyBoardUtil.showKeyBoard(activity.getWindow());
                }
                super.showAtLocation(anchor, gravity, x, y);
            }

            @Override
            public void dismiss() {
                if (activity != null && !activity.isFinishing()) {
                    Window dialogWindow = activity.getWindow();
                    startAnimation(dialogWindow, false);
                }

                super.dismiss();
            }
        };
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setTouchable(true);
        popupWindow.setOutsideTouchable(false);
        popupWindow.setAnimationStyle(R.style.PopupInputCardAnim);
        popupWindow.setInputMethodMode(PopupWindow.INPUT_METHOD_NEEDED);
        popupWindow.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        popupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                if (activity.getWindow() != null) {
                    SoftKeyBoardUtil.hideKeyBoard(activity.getWindow());
                }
            }
        });

        positiveBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String result = editText.getText().toString();

                if (result.length() < minLimit || result.length() > maxLimit) {
                    ToastUtil.toastShortMessage(notMachRuleTip);
                    return;
                }

                if (!TextUtils.isEmpty(rule) && !Pattern.matches(rule, result)) {
                    ToastUtil.toastShortMessage(notMachRuleTip);
                    return;
                }

                if (positiveOnClickListener != null) {
                    positiveOnClickListener.onClick(editText.getText().toString());
                }
                popupWindow.dismiss();
            }
        });

        closeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                popupWindow.dismiss();
            }
        });
        editText.setFilters(new InputFilter[] {lengthFilter});
        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                if (!TextUtils.isEmpty(rule)) {
                    if (!Pattern.matches(rule, s.toString())) {
                        positiveBtn.setEnabled(false);
                    } else {
                        positiveBtn.setEnabled(true);
                    }
                }
            }
        });
    }

    private void startAnimation(Window window, boolean isShow) {
        ValueAnimator animator;
        if (isShow) {
            animator = ValueAnimator.ofFloat(1.0f, 0.5f);
        } else {
            animator = ValueAnimator.ofFloat(0.5f, 1.0f);
        }
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                WindowManager.LayoutParams lp = window.getAttributes();
                lp.alpha = (float) animation.getAnimatedValue();
                window.setAttributes(lp);
            }
        });
        LinearInterpolator interpolator = new LinearInterpolator();
        animator.setDuration(200);
        animator.setInterpolator(interpolator);
        animator.start();
    }

    public void show(View rootView, int gravity) {
        if (popupWindow != null) {
            popupWindow.showAtLocation(rootView, gravity, 0, 0);
        }
    }

    public void setTitle(String title) {
        titleTv.setText(title);
    }

    public void setDescription(String description) {
        if (!TextUtils.isEmpty(description)) {
            descriptionTv.setVisibility(View.VISIBLE);
            descriptionTv.setText(description);
        }
    }

    public void setContent(String content) {
        editText.setText(content);
    }

    public void setOnPositive(OnClickListener clickListener) {
        positiveOnClickListener = clickListener;
    }

    public void setTextExceedListener(OnTextExceedListener textExceedListener) {
        this.textExceedListener = textExceedListener;
    }

    public void setSingleLine(boolean isSingleLine) {
        editText.setSingleLine(isSingleLine);
    }

    public void setMaxLimit(int maxLimit) {
        this.maxLimit = maxLimit;
        lengthFilter.setLength(maxLimit);
    }

    public void setMinLimit(int minLimit) {
        this.minLimit = minLimit;
    }

    public void setRule(String rule) {
        if (TextUtils.isEmpty(rule)) {
            this.rule = "";
        } else {
            this.rule = rule;
        }
    }

    public void setNotMachRuleTip(String notMachRuleTip) {
        this.notMachRuleTip = notMachRuleTip;
    }

    class ByteLengthFilter implements InputFilter {
        private int length = Integer.MAX_VALUE;

        public ByteLengthFilter() {}

        public void setLength(int length) {
            this.length = length;
        }

        @Override
        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
            int destLength = 0;
            int destReplaceLength = 0;
            int sourceLength = 0;
            if (!TextUtils.isEmpty(dest)) {
                destLength = dest.toString().getBytes().length;
                destReplaceLength = dest.subSequence(dstart, dend).toString().getBytes().length;
            }
            if (!TextUtils.isEmpty(source)) {
                sourceLength = source.subSequence(start, end).toString().getBytes().length;
            }
            int keepBytesLength = length - (destLength - destReplaceLength);
            if (keepBytesLength <= 0) {
                if (textExceedListener != null) {
                    textExceedListener.onTextExceedMax();
                }
                return "";
            } else if (keepBytesLength >= sourceLength) {
                return null;
            } else {
                if (textExceedListener != null) {
                    textExceedListener.onTextExceedMax();
                }
                return getSource(source, start, keepBytesLength);
            }
        }

        private CharSequence getSource(CharSequence sequence, int start, int keepLength) {
            int sequenceLength = sequence.length();
            int end = 0;
            for (int i = 1; i <= sequenceLength; i++) {
                if (sequence.subSequence(0, i).toString().getBytes().length <= keepLength) {
                    end = i;
                } else {
                    break;
                }
            }
            if (end > 0 && Character.isHighSurrogate(sequence.charAt(end - 1))) {
                --end;
                if (end == start) {
                    return "";
                }
            }
            return sequence.subSequence(start, end);
        }
    }

    @FunctionalInterface
    public interface OnClickListener {
        void onClick(String result);
    }

    public interface OnTextExceedListener {
        void onTextExceedMax();
    }
}
