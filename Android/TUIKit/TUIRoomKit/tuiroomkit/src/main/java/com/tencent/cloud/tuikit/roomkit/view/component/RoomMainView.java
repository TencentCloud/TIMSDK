package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.PixelFormat;
import android.os.Build;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.viewmodel.RoomMainViewModel;

import java.lang.reflect.Method;

public class RoomMainView extends RelativeLayout {
    private static final String TAG = "MeetingView";

    private Context                      mContext;
    private View                         mScreenCaptureGroup;
    private View                         mFloatingWindow;
    private View                         mDividingLine;
    private TextView                     mTextStopScreenShare;
    private TopView                      mTopView;
    private BottomView                   mBottomView;
    private QRCodeView                   mQRCodeView;
    private UserListView                 mUserListView;
    private RoomInfoView                 mRoomInfoView;
    private MoreFunctionView             mMoreFunctionView;
    private TransferMasterView           mTransferMasterView;
    private RaiseHandApplicationListView mRaiseHandApplicationListView;
    private LinearLayout                 mLayoutRaiseHandTip;
    private RelativeLayout               mLayoutVideoSeat;
    private RoomMainViewModel            mViewModel;

    public RoomMainView(Context context) {
        super(context);
        mContext = context;
        initView();
    }

    private void initView() {
        View.inflate(mContext, R.layout.tuiroomkit_view_meeting, this);
        mViewModel = new RoomMainViewModel(mContext, this);

        mLayoutVideoSeat = findViewById(R.id.rl_video_seat_container);
        mLayoutRaiseHandTip = findViewById(R.id.ll_raise_hand_tip);
        mScreenCaptureGroup = findViewById(R.id.group_screen_capture);
        mTextStopScreenShare = findViewById(R.id.tv_stop_screen_capture);
        mDividingLine = findViewById(R.id.top_view_dividing_line);

        mTextStopScreenShare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                stopScreenShare();
            }
        });

        if (TUIRoomDefine.SpeechMode.SPEAK_AFTER_TAKING_SEAT.equals(mViewModel.getRoomInfo().speechMode)
                && !mViewModel.isOwner()) {
            mLayoutRaiseHandTip.setVisibility(VISIBLE);
        }
        mLayoutRaiseHandTip.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                mLayoutRaiseHandTip.setVisibility(GONE);
            }
        });

        mUserListView = new UserListView(mContext);

        mRaiseHandApplicationListView = new RaiseHandApplicationListView(mContext);

        mBottomView = new BottomView(mContext);
        mViewModel.initCameraAndMicrophone();
        ViewGroup bottomLayout = findViewById(R.id.bottom_view);
        bottomLayout.addView(mBottomView);

        mTopView = new TopView(mContext);
        ViewGroup topLayout = findViewById(R.id.top_view);
        topLayout.addView(mTopView);

        setVideoSeatView(mViewModel.getVideoSeatView());
        setMoreFunctionView();
        showAlertUserLiveTips();
    }

    private void showAlertUserLiveTips() {
        try {
            Class clz = Class.forName("com.tencent.liteav.privacy.util.RTCubeAppLegalUtils");
            Method method = clz.getDeclaredMethod("showAlertUserLiveTips", Context.class);
            method.invoke(null, mContext);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    //TODO 横屏模式下要隐藏bottomView和TopView
    private void changeViewVisibility(View view) {
        if (view == null) {
            return;
        }

        if (view.getVisibility() == VISIBLE) {
            view.setVisibility(GONE);
        } else {
            view.setVisibility(VISIBLE);
        }
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        RelativeLayout.LayoutParams params = new RelativeLayout
                .LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        if (Configuration.ORIENTATION_PORTRAIT == newConfig.orientation) {
            params.addRule(RelativeLayout.BELOW, R.id.top_view);
            params.addRule(RelativeLayout.ABOVE, R.id.bottom_view);
            params.bottomMargin = getResources()
                    .getDimensionPixelSize(R.dimen.tuiroomkit_video_seat_bottom_margin);
        }
        mLayoutVideoSeat.setLayoutParams(params);
        mViewModel.notifyConfigChange(newConfig);
    }

    private void setMoreFunctionView() {
        mMoreFunctionView = new MoreFunctionView(mContext);
    }

    private void setVideoSeatView(View view) {
        if (view == null) {
            return;
        }
        RelativeLayout.LayoutParams params = new RelativeLayout
                .LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        mLayoutVideoSeat.addView(view, params);
    }

    public void showRoomInfo() {
        if (mRoomInfoView == null) {
            mRoomInfoView = new RoomInfoView(mContext);
        }
        mRoomInfoView.show();
    }

    public void showUserList() {
        if (mUserListView == null) {
            mUserListView = new UserListView(mContext);
        }
        mUserListView.show();
    }

    public void showApplyList() {
        if (mRaiseHandApplicationListView == null) {
            mRaiseHandApplicationListView = new RaiseHandApplicationListView(mContext);
        }
        mRaiseHandApplicationListView.show();
    }

    public void showExtensionView() {
        if (mMoreFunctionView == null) {
            mMoreFunctionView = new MoreFunctionView(mContext);
        }
        mMoreFunctionView.show();
    }

    public void showQRCodeView(String url) {
        if (mQRCodeView == null) {
            mQRCodeView = new QRCodeView(mContext, url);
        }
        mQRCodeView.show();
    }

    public void showExitRoomDialog() {
        ExitRoomDialog exitRoomDialog = new ExitRoomDialog(mContext);
        exitRoomDialog.show();
    }

    public void showTransferMasterView() {
        if (mTransferMasterView == null) {
            mTransferMasterView = new TransferMasterView(mContext);
        }
        mTransferMasterView.show();
    }

    public void showInvitationDialog(final String inviteId, final TUIRoomDefine.RequestAction requestAction) {
        String message = "";
        String positiveText = "";
        String negativeText = "";
        switch (requestAction) {
            case REQUEST_TO_OPEN_REMOTE_CAMERA:
                message = mContext.getString(R.string.tuiroomkit_request_open_camera);
                positiveText = mContext.getString(R.string.tuiroomkit_agree);
                negativeText = mContext.getString(R.string.tuiroomkit_refuse);
                break;
            case REQUEST_TO_OPEN_REMOTE_MICROPHONE:
                message = mContext.getString(R.string.tuiroomkit_request_open_microphone);
                positiveText = mContext.getString(R.string.tuiroomkit_agree);
                negativeText = mContext.getString(R.string.tuiroomkit_refuse);
                break;
            case REQUEST_REMOTE_USER_ON_SEAT:
                message = mContext.getString(R.string.tuiroomkit_receive_invitation);
                positiveText = mContext.getString(R.string.tuiroomkit_agree_on_stage);
                negativeText = mContext.getString(R.string.tuiroomkit_refuse);
                break;
            default:
                break;
        }
        final ConfirmDialog confirmDialog = new ConfirmDialog(mContext);
        confirmDialog.setCancelable(true);
        confirmDialog.setMessage(message);
        if (confirmDialog.isShowing()) {
            confirmDialog.dismiss();
            return;
        }
        confirmDialog.setPositiveText(positiveText);
        confirmDialog.setNegativeText(negativeText);
        confirmDialog.setPositiveClickListener(new ConfirmDialog.PositiveClickListener() {
            @Override
            public void onClick() {
                mViewModel.responseRequest(inviteId, true);
                confirmDialog.dismiss();
            }
        });
        confirmDialog.setNegativeClickListener(new ConfirmDialog.NegativeClickListener() {
            @Override
            public void onClick() {
                mViewModel.responseRequest(inviteId, false);
                confirmDialog.dismiss();
            }
        });
        confirmDialog.show();
    }

    public void showSingleConfirmDialog(String message, boolean isExitRoom) {
        final ConfirmDialog confirmDialog = new ConfirmDialog(mContext);
        confirmDialog.setCancelable(true);
        confirmDialog.setMessage(message);
        if (confirmDialog.isShowing()) {
            confirmDialog.dismiss();
            return;
        }
        confirmDialog.setPositiveText(mContext.getString(R.string.tuiroomkit_dialog_ok));
        confirmDialog.setPositiveClickListener(new ConfirmDialog.PositiveClickListener() {
            @Override
            public void onClick() {
                if (isExitRoom) {
                    mViewModel.notifyExitRoom();
                }
                confirmDialog.dismiss();
            }
        });
        confirmDialog.show();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        hideFloatingWindow();
        mViewModel.destroy();
        if (mUserListView != null) {
            mUserListView.destroy();
        }
        if (mTransferMasterView != null) {
            mTransferMasterView.destroy();
        }
        if (mRaiseHandApplicationListView != null) {
            mRaiseHandApplicationListView.destroy();
        }
    }

    public void startScreenShare() {
        mLayoutVideoSeat.setVisibility(View.GONE);
        mScreenCaptureGroup.setVisibility(View.VISIBLE);
        mBottomView.setVisibility(GONE);
        mTopView.setVisibility(GONE);
        mViewModel.startScreenShare();

        if (mFloatingWindow == null) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            mFloatingWindow = inflater.inflate(R.layout.tuiroomkit_screen_capture_floating_window, null, false);
            mFloatingWindow.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG, "onClick: 悬浮窗");
                }
            });
        }
        showFloatingWindow();
    }

    private void stopScreenShare() {
        hideFloatingWindow();
        mViewModel.stopScreenShare();
        mLayoutVideoSeat.setVisibility(View.VISIBLE);
        mScreenCaptureGroup.setVisibility(View.GONE);
        mBottomView.setVisibility(View.VISIBLE);
        mTopView.setVisibility(View.VISIBLE);
    }

    private void showFloatingWindow() {
        if (mFloatingWindow == null) {
            return;
        }
        WindowManager windowManager =
                (WindowManager) mFloatingWindow.getContext().getSystemService(Context.WINDOW_SERVICE);
        if (windowManager == null) {
            return;
        }
        int type = WindowManager.LayoutParams.TYPE_TOAST;
        if (Build.VERSION.SDK_INT >= 26) {
            type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N) {
            type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams(type);
        layoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        layoutParams.flags |= WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH;
        layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.format = PixelFormat.TRANSLUCENT;
        layoutParams.gravity = Gravity.END;
        windowManager.addView(mFloatingWindow, layoutParams);
    }

    private void hideFloatingWindow() {
        if (mFloatingWindow == null) {
            return;
        }
        WindowManager windowManager =
                (WindowManager) mFloatingWindow.getContext().getSystemService(Context.WINDOW_SERVICE);
        if (windowManager != null) {
            windowManager.removeViewImmediate(mFloatingWindow);
        }
        mFloatingWindow = null;
    }

    public void onCameraMuted(boolean muted) {
        if (muted) {
            ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_mute_video_by_master));
        } else {
            ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_un_mute_video_by_master));
        }
    }

    public void onMicrophoneMuted(boolean muted) {
        if (muted) {
            ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_mute_audio_by_master));
        } else {
            ToastUtil.toastShortMessage(mContext.getString(R.string.tuiroomkit_un_mute_audio_by_master));
        }
    }
}
