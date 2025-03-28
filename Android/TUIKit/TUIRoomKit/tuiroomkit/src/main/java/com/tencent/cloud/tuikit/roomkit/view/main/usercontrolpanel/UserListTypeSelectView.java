package com.tencent.cloud.tuikit.roomkit.view.main.usercontrolpanel;

import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.IN_ROOM;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.OFF_SEAT;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.ON_SEAT;
import static com.tencent.cloud.tuikit.roomkit.state.ViewState.UserListType.OUT_ROOM;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.state.ViewState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.trtc.tuikit.common.livedata.Observer;

public class UserListTypeSelectView extends FrameLayout {
    private Context mContext;

    private RadioButton mBtnOnSeatTab;
    private RadioButton mBtnOffSeatTab;
    private RadioButton mBtnEnteredTab;
    private RadioButton mBtnNotEnteredTab;
    private RadioGroup  mRadioGroupUserListType;

    private Observer<Boolean> mIsSeatEnabledObserver          = this::updateUserListTypeTab;
    private Observer<Integer> mOnSeatUserCountObserver        = this::updateOnSeatUserCount;
    private Observer<Integer> mOffSeatUserCountObserver       = this::updateOffSeatUserCount;
    private Observer<Integer> mAllEnteredUserCountObserver    = this::updateEnteredUserCount;
    private Observer<Integer> mAllNotEnteredUserCountObserver = this::updateNotEnterUserCount;

    private UserListTypeSelectViewStateHolder mStateHolder = new UserListTypeSelectViewStateHolder();

    public UserListTypeSelectView(@NonNull Context context) {
        this(context, null);
    }

    public UserListTypeSelectView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public UserListTypeSelectView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.tuiroomkit_view_user_list_type_select, this);
        initView(context);
    }

    private void initView(Context context) {
        mContext = context;
        mRadioGroupUserListType = findViewById(R.id.tuiroomkit_user_list_type_tab);
        mBtnOnSeatTab = findViewById(R.id.tuiroomkit_btn_user_on_seat);
        mBtnOffSeatTab = findViewById(R.id.tuiroomkit_btn_user_off_seat);
        mBtnEnteredTab = findViewById(R.id.tuiroomkit_btn_user_entered);
        mBtnNotEnteredTab = findViewById(R.id.tuiroomkit_btn_user_not_entered);

        mRadioGroupUserListType.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == mBtnOnSeatTab.getId()) {
                ConferenceController.sharedInstance().getViewController().updateUserTypeSelected(ON_SEAT);
            } else if (checkedId == mBtnOffSeatTab.getId()) {
                ConferenceController.sharedInstance().getViewController().updateUserTypeSelected(OFF_SEAT);
            } else if (checkedId == mBtnEnteredTab.getId()) {
                ConferenceController.sharedInstance().getViewController().updateUserTypeSelected(IN_ROOM);
            } else if (checkedId == mBtnNotEnteredTab.getId()) {
                ConferenceController.sharedInstance().getViewController().updateUserTypeSelected(OUT_ROOM);
            }
        });
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mStateHolder.observeSeatEnabled(mIsSeatEnabledObserver);
        mStateHolder.observeAllEnteredSeatUserCount(mAllEnteredUserCountObserver);
        mStateHolder.observeOnSeatUserCount(mOnSeatUserCountObserver);
        mStateHolder.observeOffSeatUserCount(mOffSeatUserCountObserver);
        mStateHolder.observeAllNotEnteredUserCount(mAllNotEnteredUserCountObserver);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mStateHolder.removeSeatEnabledObserver(mIsSeatEnabledObserver);
        mStateHolder.removeAllEnteredSeatUserCountObserver(mAllEnteredUserCountObserver);
        mStateHolder.removeOnSeatUserCountObserver(mOnSeatUserCountObserver);
        mStateHolder.removeOffSeatUserCountObserver(mOffSeatUserCountObserver);
        mStateHolder.removeAllNotEnteredUserCountObserver(mAllNotEnteredUserCountObserver);
        mStateHolder.destroy();
    }

    private void updateNotEnterUserCount(int userCount) {
        mBtnNotEnteredTab.setText(
                mContext.getString(R.string.tuiroomkit_not_entered, String.valueOf(userCount)));
    }

    private void updateEnteredUserCount(int userCount) {
        mBtnEnteredTab.setText(
                mContext.getString(R.string.tuiroomkit_already_entered_room, String.valueOf(userCount)));
    }

    private void updateOnSeatUserCount(int userCount) {
        mBtnOnSeatTab.setText(
                mContext.getString(R.string.tuiroomkit_user_list_on_seat, String.valueOf(userCount)));
    }

    private void updateOffSeatUserCount(int userCount) {
        mBtnOffSeatTab.setText(
                mContext.getString(R.string.tuiroomkit_user_list_off_seat, String.valueOf(userCount)));
    }

    private void updateUserListTypeTab(boolean isSeatEnabled) {
        mBtnEnteredTab.setVisibility(isSeatEnabled ? GONE : VISIBLE);
        mBtnOnSeatTab.setVisibility(isSeatEnabled ? VISIBLE : GONE);
        mBtnOffSeatTab.setVisibility(isSeatEnabled ? VISIBLE : GONE);
        if (isSeatEnabled) {
            mBtnOnSeatTab.setChecked(true);
            ConferenceController.sharedInstance().getViewController().updateUserTypeSelected(ON_SEAT);
        } else {
            mBtnEnteredTab.setChecked(true);
            ConferenceController.sharedInstance().getViewController().updateUserTypeSelected(IN_ROOM);
        }
    }
}
