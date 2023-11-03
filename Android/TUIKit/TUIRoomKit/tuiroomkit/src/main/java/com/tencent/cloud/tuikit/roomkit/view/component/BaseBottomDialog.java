package com.tencent.cloud.tuikit.roomkit.view.component;


import android.content.Context;
import android.content.res.Configuration;

import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import androidx.coordinatorlayout.widget.CoordinatorLayout;


import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;

public abstract class BaseBottomDialog extends BottomSheetDialog {
    private View                      bottomSheetView;
    private BottomSheetBehavior<View> mBehavior;

    public BaseBottomDialog(@NonNull Context context) {
        super(context);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        initRootView();
    }

    private void initRootView() {
        setContentView(getLayoutId());
        bottomSheetView = findViewById(com.google.android.material.R.id.design_bottom_sheet);
        if (bottomSheetView != null) {
            mBehavior = BottomSheetBehavior.from(bottomSheetView);
        }
        initView();

        updateBackground();
        handleScreenOrientationChanged(getContext().getResources().getConfiguration());
        mBehavior.setSkipCollapsed(true);
        mBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
        mBehavior.setPeekHeight(getContext().getResources().getDisplayMetrics().heightPixels);
    }

    protected void updateHeightToMatchParent() {
        if (bottomSheetView != null) {
            CoordinatorLayout.LayoutParams params = (CoordinatorLayout.LayoutParams) bottomSheetView.getLayoutParams();
            params.height = ViewGroup.LayoutParams.MATCH_PARENT;
            bottomSheetView.setLayoutParams(params);
        }
    }

    protected abstract int getLayoutId();

    protected abstract void initView();

    public void changeConfiguration(Configuration configuration) {
        initRootView();
    }

    private void handleScreenOrientationChanged(Configuration configuration) {
        Window window = getWindow();
        if (window == null) {
            return;
        }

        window.setBackgroundDrawableResource(android.R.color.transparent);
        WindowManager.LayoutParams params = window.getAttributes();
        int resId;
        if (configuration.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            resId = R.style.TUIRoomBottomDialogHorizontalAnim;
            params.gravity = Gravity.END;
            params.width = getContext().getResources().getDisplayMetrics().widthPixels / 2;
        } else {
            resId = R.style.TUIRoomBottomDialogVerticalAnim;
            params.gravity = Gravity.BOTTOM;
            params.width = WindowManager.LayoutParams.MATCH_PARENT;
        }
        window.setWindowAnimations(resId);
        params.height = getContext().getResources().getDisplayMetrics().heightPixels;
        params.flags =
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN | WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS;
        window.setAttributes(params);

        ViewGroup.LayoutParams viewParams = bottomSheetView.getLayoutParams();
        viewParams.height =
                configuration.orientation == Configuration.ORIENTATION_LANDSCAPE ? ViewGroup.LayoutParams.MATCH_PARENT :
                        ViewGroup.LayoutParams.WRAP_CONTENT;
        bottomSheetView.setLayoutParams(viewParams);
    }

    private void updateBackground() {
        if (getWindow() == null) {
            return;
        }
        int resId = getContext().getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE
                ? R.drawable.tuiroomkit_bg_bottom_dialog_black_landscape
                : R.drawable.tuiroomkit_bg_bottom_dialog_black_portrait;
        getWindow().findViewById(com.google.android.material.R.id.design_bottom_sheet)
                .setBackgroundResource(resId);
    }
}
