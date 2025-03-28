package com.tencent.cloud.tuikit.roomkit.view.main.raisehandcontrolpanel;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.NotificationView;
import com.trtc.tuikit.common.livedata.Observer;

public class RaiseHandNotificationView extends NotificationView {

    private RaiseHandNotificationStateHolder mStateHolder;

    private Observer<RaiseHandNotificationUiState> mObserver = new Observer<RaiseHandNotificationUiState>() {

        @Override
        public void onChanged(RaiseHandNotificationUiState raiseHandNotificationUiState) {
            if (!raiseHandNotificationUiState.isShow) {
                dismiss();
                return;
            }
            showNotification(raiseHandNotificationUiState);
        }
    };

    public RaiseHandNotificationView(Context context) {
        this(context, null);
    }

    public RaiseHandNotificationView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public RaiseHandNotificationView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mStateHolder = new RaiseHandNotificationStateHolder(getDuration());
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        initView();
        mStateHolder.observe(mObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeObserver(mObserver);
    }

    private void initView() {
        setClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ConferenceController.sharedInstance().getViewController().clearPendingTakeSeatRequests();
                new RaiseHandApplicationListPanel(mContext).show();
            }
        });
    }

    private void showNotification(RaiseHandNotificationUiState uiState) {
        String name = TextUtils.isEmpty(uiState.userName) ? uiState.userId : uiState.userName;
        String message = uiState.count > 1 ?
                mContext.getString(R.string.tuiroomkit_multi_raise_hand_notification, name, uiState.count) :
                mContext.getString(R.string.tuiroomkit_raise_hand_notification, name);
        setMessage(message).setDuration(uiState.duration).show();
    }
}
