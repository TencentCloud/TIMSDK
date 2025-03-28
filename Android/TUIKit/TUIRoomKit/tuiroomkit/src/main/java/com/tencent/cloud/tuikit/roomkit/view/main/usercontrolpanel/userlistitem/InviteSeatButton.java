package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import android.content.Context;
import android.util.AttributeSet;

import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.HashMap;
import java.util.Map;

public class InviteSeatButton extends androidx.appcompat.widget.AppCompatButton {
    private String mUserId = "";

    private final InviteSeatButtonStateHolder       mStateHolder = new InviteSeatButtonStateHolder();
    private final Observer<InviteSeatButtonUiState> mObserver    = this::updateView;

    public InviteSeatButton(Context context) {
        this(context, null);
    }

    public InviteSeatButton(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public InviteSeatButton(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setOnClickListener(v -> {
            Map<String, Object> params = new HashMap<>();
            params.put("userId", mUserId);
            ConferenceEventCenter.getInstance()
                    .notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, params);
        });
    }

    public void setUserId(String userId) {
        mUserId = userId;
        mStateHolder.setUserId(userId);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
    }

    private void updateView(InviteSeatButtonUiState uiState) {
        setVisibility(uiState.isShow ? VISIBLE : INVISIBLE);
    }
}
