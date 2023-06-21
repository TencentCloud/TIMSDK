package com.tencent.qcloud.tuikit.tuicommunity.component.bottompopupcard;

import android.animation.ValueAnimator;
import android.app.Activity;
import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.LinearInterpolator;
import android.widget.PopupWindow;

import com.tencent.qcloud.tuikit.tuicommunity.R;

public class BottomPopupCard implements IPopupCard {
    private PopupWindow popupWindow;

    public BottomPopupCard(Activity activity, View contentView) {
        if (!(contentView instanceof IPopupView)) {
            return;
        }
        ((IPopupView) contentView).setPopupCard(this);
        popupWindow = new PopupWindow(contentView, WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT, true) {
            @Override
            public void showAtLocation(View anchor, int gravity, int x, int y) {
                if (activity != null && !activity.isFinishing()) {
                    Window window = activity.getWindow();
                    startAnimation(window, true);
                }
                super.showAtLocation(anchor, gravity, x, y);
            }

            @Override
            public void dismiss() {
                if (activity != null && !activity.isFinishing()) {
                    Window window = activity.getWindow();
                    startAnimation(window, false);
                }
                super.dismiss();
            }
        };
        popupWindow.setBackgroundDrawable(new ColorDrawable());
        popupWindow.setTouchable(true);
        popupWindow.setOutsideTouchable(false);
        popupWindow.setAnimationStyle(R.style.BottomPopupAnimation);
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

    public void show(View rootView) {
        if (popupWindow != null) {
            popupWindow.showAtLocation(rootView, Gravity.BOTTOM, 0, 0);
        }
    }

    @Override
    public void dismiss() {
        if (popupWindow != null && popupWindow.isShowing()) {
            popupWindow.dismiss();
        }
    }
}
