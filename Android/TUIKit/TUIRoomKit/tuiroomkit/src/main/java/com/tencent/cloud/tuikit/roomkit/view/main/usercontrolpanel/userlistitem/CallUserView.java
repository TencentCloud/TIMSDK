package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel.userlistitem;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatButton;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.ArrayList;
import java.util.List;

public class CallUserView extends FrameLayout {
    private TextView        mTextNotEnteredForNow;
    private AppCompatButton mBtnCall;

    private Observer<Boolean> mIsShow                 = this::updateCallUserViewVisibility;
    private Observer<Boolean> mIsCalling              = this::updateCallingButton;
    private Observer<Boolean> mIsNotEnteredForNowShow = this::updateNotEnteredForNowViewVisibility;

    private CallUserViewStateHolder mStateHolder = new CallUserViewStateHolder();

    public CallUserView(@NonNull Context context) {
        this(context, null);
    }

    public CallUserView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CallUserView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        View.inflate(context, R.layout.tuiroomkit_view_call_user_item, this);
        mTextNotEnteredForNow = findViewById(R.id.tv_not_enter_for_now);
        mBtnCall = findViewById(R.id.btn_call_user);

        mBtnCall.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mBtnCall.isSelected()) {
                    return;
                }
                List<UserState.UserInfo> userInfoList = new ArrayList<>();
                userInfoList.add(new UserState.UserInfo(mStateHolder.getUserId()));
                ConferenceController.sharedInstance().getInvitationController().inviteUsers(userInfoList, null);
            }
        });
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeIsShow(mIsShow);
        mStateHolder.observeIsCalling(mIsCalling);
        mStateHolder.observeIsNotEnteredForNowShow(mIsNotEnteredForNowShow);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeIsShowObserver(mIsShow);
        mStateHolder.removeIsCallingObserver(mIsCalling);
        mStateHolder.removeIsNotEnteredForNowShowObserver(mIsNotEnteredForNowShow);
    }

    public void setUserId(String userId) {
        mStateHolder.setUserId(userId);
        mBtnCall.setText(mStateHolder.getDefaultCallingState() ? R.string.tuiroomkit_calling : R.string.tuiroomkit_call);
        mBtnCall.setSelected(mStateHolder.getDefaultCallingState());
    }

    private void updateCallUserViewVisibility(boolean isShow) {
        setVisibility(isShow ? VISIBLE : GONE);
    }

    private void updateNotEnteredForNowViewVisibility(boolean isShow) {
        mTextNotEnteredForNow.setVisibility(isShow ? VISIBLE : INVISIBLE);
    }

    private void updateCallingButton(boolean isCalling) {
        mBtnCall.setSelected(isCalling);
        mBtnCall.setText(isCalling ? R.string.tuiroomkit_calling : R.string.tuiroomkit_call);
    }
}
