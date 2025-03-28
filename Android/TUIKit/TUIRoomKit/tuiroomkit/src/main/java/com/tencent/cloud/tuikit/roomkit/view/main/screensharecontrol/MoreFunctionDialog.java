package com.tencent.cloud.tuikit.roomkit.view.main.screensharecontrol;

import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISMISS_MORE_FUNCTION_PANEL;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.view.basic.BaseDialogFragment;
import com.trtc.tuikit.common.livedata.Observer;

import java.util.Map;

public class MoreFunctionDialog extends BaseBottomDialog implements ConferenceEventCenter.RoomKitUIEventResponder {
    private Context        mContext;
    private RelativeLayout mLayoutDisableGeneralUserShare;
    private TextView       mTextDisableGeneralShare;
    private ImageView      mImageDisableGeneralShareIcon;
    private boolean        mIsDisableScreen;

    private final Observer<Boolean>            mRoomDisableScreenObserver = this::updateDisableScreenView;
    private final Observer<UserState.UserInfo> mSelfInfoObserver          = this::dismissDialog;

    public MoreFunctionDialog(@NonNull Context context) {
        super(context);
        mContext = context;
        ConferenceEventCenter.getInstance().subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
        ConferenceEventCenter.getInstance().notifyUIEvent(DISMISS_MORE_FUNCTION_PANEL, null);
        ConferenceController.sharedInstance().getRoomState().isDisableScreen.removeObserver(mRoomDisableScreenObserver);
        ConferenceController.sharedInstance().getUserState().selfInfo.removeObserver(mSelfInfoObserver);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_dialog_more_function;
    }

    @Override
    protected void initView() {
        mLayoutDisableGeneralUserShare = findViewById(R.id.rl_disable_general_share);
        mImageDisableGeneralShareIcon = findViewById(R.id.image_disable_general);
        mTextDisableGeneralShare = findViewById(R.id.tv_disable_general_share);
        ConferenceController.sharedInstance().getRoomState().isDisableScreen.observe(mRoomDisableScreenObserver);
        ConferenceController.sharedInstance().getUserState().selfInfo.observe(mSelfInfoObserver);
        mLayoutDisableGeneralUserShare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                disableGeneralShareScreen();
            }
        });
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (TextUtils.equals(key, CONFIGURATION_CHANGE)) {
            if (params == null || !isShowing()) {
                return;
            }
            Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
            changeConfiguration(configuration);
        }
    }

    private void disableGeneralShareScreen() {
        String sharingUserId = ConferenceController.sharedInstance().getUserState().screenStreamUser.get();
        if (TextUtils.isEmpty(sharingUserId)) {
            ConferenceController.sharedInstance().disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.SCREEN_SHARING, mIsDisableScreen, null);
            return;
        }
        UserState.UserInfo userInfo = new UserState.UserInfo(sharingUserId);
        UserState.UserInfo sharingUser = ConferenceController.sharedInstance().getUserState().allUsers.find(userInfo);
        if (sharingUser.role.get() == TUIRoomDefine.Role.GENERAL_USER) {
            BaseDialogFragment.build()
                    .setTitle(mContext.getString(R.string.tuiroomkit_disable_general_share_dialog_title))
                    .setContent(mContext.getString(R.string.tuiroomkit_disable_general_share_dialog_hint))
                    .setNegativeName(mContext.getString(R.string.tuiroomkit_cancel))
                    .setPositiveName(mContext.getString(R.string.tuiroomkit_title_enable))
                    .setPositiveListener(new BaseDialogFragment.ClickListener() {
                        @Override
                        public void onClick() {
                            ConferenceController.sharedInstance().closeRemoteDeviceByAdmin(sharingUser.userId, TUIRoomDefine.MediaDevice.SCREEN_SHARING, null);
                            ConferenceController.sharedInstance().disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.SCREEN_SHARING, mIsDisableScreen, null);
                        }
                    }).showDialog(mContext, null);
        } else {
            ConferenceController.sharedInstance().disableDeviceForAllUserByAdmin(TUIRoomDefine.MediaDevice.SCREEN_SHARING, mIsDisableScreen, null);
        }
    }

    private void updateDisableScreenView(boolean isDisable) {
        mIsDisableScreen = !isDisable;
        mTextDisableGeneralShare.setText(isDisable ? mContext.getString(R.string.tuiroomkit_all_users_enable_share) : mContext.getString(R.string.tuiroomkit_disable_general_share));
        mImageDisableGeneralShareIcon.setImageResource(isDisable ? R.drawable.tuiroomkit_icon_enable_all_users_share : R.drawable.tuiroomkit_icon_disable_all_users_share);
    }

    private void dismissDialog(UserState.UserInfo userInfo) {
        if (userInfo.role.get() == TUIRoomDefine.Role.GENERAL_USER) {
            dismiss();
        }
    }
}
