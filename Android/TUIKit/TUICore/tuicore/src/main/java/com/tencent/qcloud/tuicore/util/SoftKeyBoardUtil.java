package com.tencent.qcloud.tuicore.util;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.util.DisplayMetrics;
import android.view.inputmethod.InputMethodManager;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUIConstants;

public class SoftKeyBoardUtil {

    private static int softKeyBoardHeight;
    private static SharedPreferences preferences = TUIConfig.getAppContext().getSharedPreferences(TUIConstants.TUIChat.UI_PARAMS, Context.MODE_PRIVATE);

    public static int getSoftKeyBoardHeight() {
        if (softKeyBoardHeight != 0)
            return softKeyBoardHeight;
        softKeyBoardHeight = preferences.getInt(TUIConstants.TUIChat.SOFT_KEY_BOARD_HEIGHT, 0);
        if (softKeyBoardHeight == 0) {
            int height = getScreenSize()[1];
            return height * 2 / 5;
        }
        return softKeyBoardHeight;
    }

    public static int[] getScreenSize() {
        int size[] = new int[2];
        DisplayMetrics dm = TUIConfig.getAppContext().getResources().getDisplayMetrics();
        size[0] = dm.widthPixels;
        size[1] = dm.heightPixels;
        return size;
    }

    public static void hideKeyBoard(IBinder token) {
        InputMethodManager imm = (InputMethodManager) TUIConfig.getAppContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.hideSoftInputFromWindow(token, 0);
        }
    }

}

