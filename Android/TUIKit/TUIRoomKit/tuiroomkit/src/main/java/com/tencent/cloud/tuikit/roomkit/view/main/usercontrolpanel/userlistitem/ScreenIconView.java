package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageButton;

import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

public class ScreenIconView extends AppCompatImageButton {
    private       String           mUserId;
    private final Observer<String> mScreenObserver = this::updateView;

    public ScreenIconView(@NonNull Context context) {
        this(context, null);
    }

    public ScreenIconView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ScreenIconView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setUserId(String userId) {
        mUserId = userId;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ConferenceController.sharedInstance().getUserState().screenStreamUser.observe(mScreenObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ConferenceController.sharedInstance().getUserState().screenStreamUser.removeObserver(mScreenObserver);
    }

    private void updateView(String screenUserId) {
        if (TextUtils.isEmpty(mUserId)) {
            setVisibility(GONE);
            return;
        }
        setVisibility(TextUtils.equals(mUserId, screenUserId) ? VISIBLE : GONE);
    }
}
