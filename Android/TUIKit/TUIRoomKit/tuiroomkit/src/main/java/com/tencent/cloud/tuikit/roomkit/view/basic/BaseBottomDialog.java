package com.tencent.cloud.tuikit.roomkit.view.basic;


import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MAIN_ACTIVITY;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.util.Map;

public abstract class BaseBottomDialog extends BottomSheetDialog implements ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "BaseBottomDialog";

    private View                      bottomSheetView;
    private BottomSheetBehavior<View> mBehavior;

    private Context mContext;

    public BaseBottomDialog(@NonNull Context context) {
        super(context);
        mContext = context;
        ConferenceEventCenter.getInstance().subscribeUIEvent(DISMISS_MAIN_ACTIVITY, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(DISMISS_MAIN_ACTIVITY, this);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        initRootView();
    }

    public void setPortraitHeightPercentOfScreen(View view, float percentOfScreen) {
        Configuration configuration = mContext.getResources().getConfiguration();
        if (configuration.orientation != Configuration.ORIENTATION_PORTRAIT) {
            return;
        }
        ViewGroup.LayoutParams layoutParams = view.getLayoutParams();
        if (layoutParams == null) {
            return;
        }
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
        int screenHeight = ScreenUtil.getScreenHeight(mContext);
        layoutParams.height = (int) (screenHeight * percentOfScreen);
        view.setLayoutParams(layoutParams);
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

    protected abstract int getLayoutId();

    protected abstract void initView();

    public void changeConfiguration(Configuration configuration) {
        initRootView();
    }

    private void handleScreenOrientationChanged(Configuration configuration) {
        if (mContext != null && mContext instanceof Activity) {
            Activity activity = (Activity) mContext;
            if (activity.isFinishing()) {
                Log.e(TAG, "handleScreenOrientationChanged activity is finishing");
                return;
            }
        }
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

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (key != DISMISS_MAIN_ACTIVITY) {
            return;
        }
        dismiss();
    }
}
