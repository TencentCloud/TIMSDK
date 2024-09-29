package com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.HashMap;
import java.util.Map;


public class InviteSeatButton extends androidx.appcompat.widget.AppCompatButton {
    private String mUserId = "";

    private InviteSeatButtonStateHolder       mStateHolder = new InviteSeatButtonStateHolder();
    private Observer<InviteSeatButtonUiState> mObserver    = new Observer<InviteSeatButtonUiState>() {
        @Override
        public void onChanged(InviteSeatButtonUiState inviteSeatButtonUiState) {
            updateView(inviteSeatButtonUiState);
        }
    };

    public InviteSeatButton(Context context) {
        this(context, null);
    }

    public InviteSeatButton(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public InviteSeatButton(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Map<String, Object> params = new HashMap<>();
                params.put("userId", mUserId);
                ConferenceEventCenter.getInstance()
                        .notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.INVITE_TAKE_SEAT, params);
            }
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
