package com.tencent.liteav.trtccalling.ui.base;

public class Status {

    //悬浮窗是否开启
    public static boolean mIsShowFloatWindow = false;

    //悬浮窗当前显示的userId
    //未接通前等于自己,接通后等于对方
    public static String mCurFloatUserId = "";

    //悬浮窗需要显示的通话开始时间
    public static int mBeginTime;

    //悬浮窗通话状态
    public static CALL_STATUS mCallStatus = CALL_STATUS.NONE;

    public enum CALL_STATUS {
        NONE,         // 无状态
        WAITING,      // 正在等待接听
        ACCEPT        // 已接听
    }
}
