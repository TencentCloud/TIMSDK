package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.component;

import android.animation.ValueAnimator;
import android.app.Activity;
import android.text.TextUtils;
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
import com.tencent.qcloud.tuikit.timcommon.util.SoftKeyBoardUtil;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;

public class ProductInfoPopupCard {
    private PopupWindow popupWindow;
    private TextView titleTv;
    private EditText editNameText, editDescriptionText, editPictureText, editJumpText;
    private Button positiveBtn;
    private View tvClose;
    private OnClickListener positiveOnClickListener;
    public ProductInfoPopupCard(Activity activity) {
        View popupView = LayoutInflater.from(activity).inflate(R.layout.popup_card_product_info, null);
        titleTv = popupView.findViewById(R.id.popup_card_title);
        editNameText = popupView.findViewById(R.id.product_name_edit);
        editDescriptionText = popupView.findViewById(R.id.product_description_edit);
        editPictureText = popupView.findViewById(R.id.product_picture_edit);
        editJumpText = popupView.findViewById(R.id.product_jump_edit);
        positiveBtn = popupView.findViewById(R.id.product_popup_card_positive_btn);
        tvClose = popupView.findViewById(R.id.tv_close);

        popupWindow = new PopupWindow(popupView, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT, true) {
            @Override
            public void showAtLocation(View anchor, int gravity, int x, int y) {
                if (activity != null && !activity.isFinishing()) {
                    Window dialogWindow = activity.getWindow();
                    startAnimation(dialogWindow, true);
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
        popupWindow.setBackgroundDrawable(null);
        popupWindow.setTouchable(true);
        popupWindow.setOutsideTouchable(true);
        popupWindow.setAnimationStyle(com.tencent.qcloud.tuikit.timcommon.R.style.PopupInputCardAnim);
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
                String name = editNameText.getText().toString();
                String description = editDescriptionText.getText().toString();
                String pictureUrl = editPictureText.getText().toString();
                String jumpUrl = editJumpText.getText().toString();

                if (TextUtils.isEmpty(name) || TextUtils.isEmpty(description) || TextUtils.isEmpty(pictureUrl) || TextUtils.isEmpty(jumpUrl)) {
                    ToastUtil.toastShortMessage(activity.getString(R.string.product_info_input_empty));
                    return;
                }

                if (positiveOnClickListener != null) {
                    positiveOnClickListener.onClick();
                }
                popupWindow.dismiss();
            }
        });

        tvClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                popupWindow.dismiss();
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

    public void setName(String name) {
        editNameText.setText(name);
    }

    public String getName() {
        return editNameText.getText().toString();
    }

    public void setDescription(String description) {
        editDescriptionText.setText(description);
    }

    public String getDescription() {
        return editDescriptionText.getText().toString();
    }

    public void setPictureUrl(String url) {
        editPictureText.setText(url);
    }

    public String getPictureUrl() {
        return editPictureText.getText().toString();
    }

    public void setJumpUrl(String url) {
        editJumpText.setText(url);
    }

    public String getJumpUrl() {
        return editJumpText.getText().toString();
    }

    public void setOnPositive(OnClickListener clickListener) {
        positiveOnClickListener = clickListener;
    }

    @FunctionalInterface
    public interface OnClickListener {
        void onClick();
    }
}
