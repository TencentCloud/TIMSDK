package com.tencent.qcloud.uikit.common.component.datepicker.timer;

import android.os.Handler;
import android.os.Message;

import com.tencent.qcloud.uikit.common.component.datepicker.view.WheelView;

public final class PickerMsgHandler extends Handler {
    public static final int WHAT_INVALIDATE_LOOP_VIEW = 1000;
    public static final int WHAT_SMOOTH_SCROLL = 2000;
    public static final int WHAT_ITEM_SELECTED = 3000;

    private final WheelView wheelView;

    public PickerMsgHandler(WheelView wheelView) {
        this.wheelView = wheelView;
    }

    @Override
    public final void handleMessage(Message msg) {
        switch (msg.what) {
            case WHAT_INVALIDATE_LOOP_VIEW:
                wheelView.invalidate();
                break;

            case WHAT_SMOOTH_SCROLL:
                wheelView.smoothScroll(WheelView.ACTION.FLING);
                break;

            case WHAT_ITEM_SELECTED:
                wheelView.onItemSelected();
                break;
        }
    }

}
