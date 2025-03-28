package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view.util;

import static android.content.res.Configuration.ORIENTATION_LANDSCAPE;

import android.content.Context;
import android.graphics.Point;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.WindowManager;

import com.tencent.qcloud.tuicore.util.ScreenUtil;

public final class OnDecorViewListener implements ViewTreeObserver.OnGlobalLayoutListener {
    private final View               mDecorView;
    private final OnKeyboardCallback mListener;
    private       int                mCurrentKeyboardHeight = 0;
    private final Size               mAbsoluteScreenSize    = new Size();
    private final Size               mRealScreenSize        = new Size();

    private final int mMaxNaviHeight;

    public OnDecorViewListener(View decorView, OnKeyboardCallback listener) {
        this.mDecorView = decorView;
        this.mListener = listener;
        mMaxNaviHeight = ScreenUtil.dip2px(60);
        if (mDecorView != null) {
            WindowManager wm = (WindowManager) mDecorView.getContext().getSystemService(Context.WINDOW_SERVICE);
            Point point = new Point();
            wm.getDefaultDisplay().getRealSize(point);
            mAbsoluteScreenSize.width = Math.min(point.x, point.y);
            mAbsoluteScreenSize.height = Math.max(point.x, point.y);
        }
    }

    @Override
    public void onGlobalLayout() {
        if (mDecorView == null) {
            return;
        }
        Rect r = new Rect();
        mDecorView.getWindowVisibleDisplayFrame(r);
        boolean isLandscape = isLandscape(mDecorView.getContext());
        int screenHeight = isLandscape ? mAbsoluteScreenSize.width : mAbsoluteScreenSize.height;
        if (isLandscape) {
            mRealScreenSize.height = screenHeight;
        } else {
            if (mAbsoluteScreenSize.height - mMaxNaviHeight <= r.bottom) {
                mRealScreenSize.height = r.bottom;
            }
            if (mRealScreenSize.height == 0) {
                mRealScreenSize.height = screenHeight;
            }
        }
        int nowHeight = mRealScreenSize.height - r.bottom;
        if (mCurrentKeyboardHeight != -1 && mCurrentKeyboardHeight != nowHeight) {
            if (mListener != null) {
                mListener.onKeyboardHeightUpdated(nowHeight);
            }
        }
        mCurrentKeyboardHeight = nowHeight;
    }

    private boolean isLandscape(Context context) {
        return ORIENTATION_LANDSCAPE == context.getResources().getConfiguration().orientation;
    }

    public void clear() {
        mCurrentKeyboardHeight = -1;
    }

    public interface OnKeyboardCallback {
        void onKeyboardHeightUpdated(int height);
    }

    private static final class Size {
        public int width;
        public int height;

        public Size() {
        }

        @Override
        public String toString() {
            return "Size{" +
                    "width=" + width +
                    ", height=" + height +
                    '}';
        }
    }
}