package com.tencent.cloud.tuikit.roomkit.view.page.widget.TopNavigationBar;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

public class ConferenceNameView extends androidx.appcompat.widget.AppCompatTextView {
    private final Observer<String> mObserver = this::setText;

    public ConferenceNameView(Context context) {
        super(context);
    }

    public ConferenceNameView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getRoomState().roomName.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getRoomState().roomName.removeObserver(mObserver);
    }
}
