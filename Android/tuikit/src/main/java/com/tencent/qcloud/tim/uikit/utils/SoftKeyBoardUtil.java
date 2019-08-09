package com.tencent.qcloud.tim.uikit.utils;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Rect;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.tencent.qcloud.tim.uikit.TUIKit;


public class SoftKeyBoardUtil {

    private static int softKeyBoardHeight;
    private static int rootViewVisibleHeight;//纪录根视图的显示高度
    private static View rootView;//activity的根视图
    private static SharedPreferences preferences = TUIKit.getAppContext().getSharedPreferences(TUIKitConstants.UI_PARAMS, Context.MODE_PRIVATE);
    private static InputMethodManager imm = (InputMethodManager) TUIKit.getAppContext().getSystemService(Context.INPUT_METHOD_SERVICE);

    public static void calculateHeight(Activity activity) {

        ViewTreeObserver.OnGlobalLayoutListener listener = new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                if (softKeyBoardHeight != 0)
                    return;
                //获取当前根视图在屏幕上显示的大小
                Rect r = new Rect();
                rootView.getWindowVisibleDisplayFrame(r);
                int visibleHeight = r.height();
                if (rootViewVisibleHeight == 0) {
                    rootViewVisibleHeight = visibleHeight;
                    return;
                }

                //根视图显示高度没有变化，可以看作软键盘显示／隐藏状态没有改变
                if (rootViewVisibleHeight == visibleHeight) {
                    return;
                }

                //根视图显示高度变小超过200，可以看作软键盘显示了
                if (rootViewVisibleHeight - visibleHeight > 200) {
                    softKeyBoardHeight = rootViewVisibleHeight - visibleHeight - ScreenUtil.getNavigationBarHeight();
                    preferences.edit().putInt(TUIKitConstants.SOFT_KEY_BOARD_HEIGHT, softKeyBoardHeight).apply();
                    return;
                }


            }
        };
        //获取activity的根视图
        rootView = activity.getWindow().getDecorView();
        //监听视图树中全局布局发生改变或者视图树中的某个视图的可视状态发生改变
        rootView.getViewTreeObserver().addOnGlobalLayoutListener(listener);
    }


    public static int getSoftKeyBoardHeight() {
        if (softKeyBoardHeight != 0)
            return softKeyBoardHeight;
        softKeyBoardHeight = preferences.getInt(TUIKitConstants.SOFT_KEY_BOARD_HEIGHT, 0);
        if (softKeyBoardHeight == 0) {
            int height = getScreenSize()[1];
            return height * 2 / 5;
        }
        return softKeyBoardHeight;
    }

    public static int[] getScreenSize() {
        int size[] = new int[2];
        DisplayMetrics dm = TUIKit.getAppContext().getResources().getDisplayMetrics();
        size[0] = dm.widthPixels;
        size[1] = dm.heightPixels;
        return size;
    }


    public static void SoftKeyboardStateHelper(final View activityRootView, final SoftKeyboardStateListener listener) {
        activityRootView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                final Rect r = new Rect();
                activityRootView.getWindowVisibleDisplayFrame(r);
                final int screenHeight = activityRootView.getRootView().getHeight();
                final int heightDifference = screenHeight - r.bottom;
                boolean visible = heightDifference > screenHeight / 3;
                if (visible) {
                    listener.onSoftKeyboardOpened(heightDifference);
                } else {
                    listener.onSoftKeyboardClosed();
                }
            }
        });
    }


    public interface SoftKeyboardStateListener {
        void onSoftKeyboardOpened(int keyboardHeightInPx);

        void onSoftKeyboardClosed();
    }


    public static void hideKeyBoard(EditText editor) {

        imm.hideSoftInputFromWindow(editor.getWindowToken(), 0);
    }

    public static void hideKeyBoard(IBinder token) {

        imm.hideSoftInputFromWindow(token, 0);
    }


}

