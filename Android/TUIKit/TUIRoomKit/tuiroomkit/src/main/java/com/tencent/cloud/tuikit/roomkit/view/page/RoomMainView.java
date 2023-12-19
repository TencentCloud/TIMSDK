package com.tencent.cloud.tuikit.roomkit.view.page;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.videoseat.ui.TUIVideoSeatView;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.BottomNavigationBar.BottomLayout;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.LocalAudioIndicator.LocalAudioToggleView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.MediaSettings.MediaSettingPanel;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.RaiseHandControlPanel.RaiseHandApplicationListPanel;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.TopNavigationBar.TopView;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.TransferOwnerControlPanel.TransferMasterPanel;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.UserControlPanel.UserListPanel;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.Dialog.ExitRoomDialog;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.Dialog.InviteUserDialog;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.Dialog.RoomInfoDialog;
import com.tencent.cloud.tuikit.roomkit.view.component.ConfirmDialog;
import com.tencent.cloud.tuikit.roomkit.view.component.QRCodeView;
import com.tencent.cloud.tuikit.roomkit.viewmodel.RoomMainViewModel;
import com.tencent.qcloud.tuicore.util.ToastUtil;

import java.lang.reflect.Method;

public class RoomMainView extends RelativeLayout {
    private static final String TAG = "RoomMainView";

    private static final int ROOM_BARS_DISMISS_DELAY_MS   = 3 * 1000;
    private static final int ROOM_BARS_FIRST_SHOW_TIME_MS = 6 * 1000;

    private Context                      mContext;
    private View                         mFloatingWindow;
    private TUIVideoSeatView             mVideoSeatView;
    private Button                       mBtnStopScreenShare;
    private FrameLayout                  mLayoutTopView;
    private FrameLayout                  mLayoutVideoSeat;
    private FrameLayout                  mLayoutLocalAudio;
    private View                         mLayoutScreenCaptureGroup;
    private FrameLayout       mLayoutBottomView;
    private BottomLayout      mBottomLayout;
    private RoomMainViewModel mViewModel;

    private Handler mMainHandler = new Handler(Looper.getMainLooper());

    private boolean mIsBarsFirstShow      = true;
    private boolean mIsBarsShowed         = true;
    private boolean mIsBottomViewExpanded = false;

    public RoomMainView(Context context) {
        super(context);
        mContext = context;
        mViewModel = new RoomMainViewModel(mContext, this);
        mVideoSeatView = new TUIVideoSeatView(mContext);
        mVideoSeatView.setViewClickListener(this::onClick);
        initView();
    }

    private void initView() {
        removeAllViews();
        addView(LayoutInflater.from(mContext)
                .inflate(R.layout.tuiroomkit_view_room_main,
                        this, false));

        mLayoutTopView = findViewById(R.id.tuiroomit_top_view_container);
        mLayoutTopView.addView(new TopView(mContext));

        mLayoutVideoSeat = findViewById(R.id.tuiroomkit_video_seat_container);
        ViewParent parent = mVideoSeatView.getParent();
        if (parent != null && parent instanceof ViewGroup) {
            ((ViewGroup) parent).removeView(mVideoSeatView);
        }
        mLayoutVideoSeat.addView(mVideoSeatView);

        mLayoutScreenCaptureGroup = findViewById(R.id.tuiroomkit_group_screen_capture);
        mLayoutScreenCaptureGroup.setOnClickListener(this::onClick);
        mBtnStopScreenShare = findViewById(R.id.tuiroomkit_btn_stop_screen_capture);
        mBtnStopScreenShare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mViewModel.stopScreenCapture();
            }
        });

        mBottomLayout = new BottomLayout(mContext);
        mBottomLayout.setExpandStateListener(this::onExpandStateChanged);
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
        );
        mBottomLayout.setLayoutParams(layoutParams);
        mLayoutBottomView = findViewById(R.id.tuiroomkit_bottom_view_container);
        mLayoutBottomView.addView(mBottomLayout);

        mLayoutLocalAudio = findViewById(R.id.tuiroomit_local_audio_container);
        mLayoutLocalAudio.addView(new LocalAudioToggleView(mContext));

        showAlertUserLiveTips();
        if (RoomEngineManager.sharedInstance().getRoomStore().videoModel.isScreenSharing()) {
            onScreenShareStarted();
        }
        showRoomBars();
        if (mIsBottomViewExpanded) {
            mBottomLayout.expandView();
        }
    }

    public void stopScreenShare() {
        mBottomLayout.stopScreenShare();
    }

    private void showAlertUserLiveTips() {
        try {
            Class clz = Class.forName("com.tencent.liteav.privacy.util.RTCubeAppLegalUtils");
            Method method = clz.getDeclaredMethod("showAlertUserLiveTips", Context.class);
            method.invoke(null, mContext);
        } catch (Exception e) {
            Log.i(TAG, "showAlertUserLiveTips fail");
        }
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        initView();
        mViewModel.notifyConfigChange(newConfig);
        mViewModel.setCameraResolutionMode(newConfig);
    }

    public void showMediaSettingsPanel() {
        MediaSettingPanel mediaSettingPanel = new MediaSettingPanel(mContext);
        mediaSettingPanel.show();
    }

    public void showRoomInfo() {
        RoomInfoDialog roomInfoView = new RoomInfoDialog(mContext);
        roomInfoView.show();
    }

    public void showUserList() {
        UserListPanel userListView = new UserListPanel(mContext);
        userListView.show();
    }

    public void showMemberInvitePanel() {
        InviteUserDialog memberInviteView = new InviteUserDialog(mContext);
        memberInviteView.show();
    }

    public void showApplyList() {
        RaiseHandApplicationListPanel raiseHandApplicationListView = new RaiseHandApplicationListPanel(mContext);
        raiseHandApplicationListView.show();
    }

    public void showQRCodeView(String url) {
        QRCodeView qrCodeView = new QRCodeView(mContext, url);
        qrCodeView.show();
    }

    public void showExitRoomDialog() {
        ExitRoomDialog exitRoomDialog = new ExitRoomDialog(mContext);
        exitRoomDialog.show();
    }

    public void showTransferMasterView() {
        TransferMasterPanel transferMasterView = new TransferMasterPanel(mContext);
        transferMasterView.show();
    }

    public void recountBarShowTime() {
        showRoomBars();
    }

    public void showExitRoomConfirmDialog(String message) {
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
                RoomEngineManager.sharedInstance().exitRoom(null);
                confirmDialog.dismiss();
            }
        });
        confirmDialog.show();
    }

    public void showKickedOffLineDialog() {
        final ConfirmDialog confirmDialog = new ConfirmDialog(mContext);
        confirmDialog.setCancelable(true);
        confirmDialog.setMessage(mContext.getString(R.string.tuiroomkit_kiecked_off_line));
        confirmDialog.setPositiveText(mContext.getString(R.string.tuiroomkit_dialog_ok));
        confirmDialog.setPositiveClickListener(new ConfirmDialog.PositiveClickListener() {
            @Override
            public void onClick() {
                RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.KICKED_OFF_LINE, null);
                confirmDialog.dismiss();
            }
        });
        confirmDialog.show();
    }

    public void showSingleConfirmDialog(String message) {
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
        if (mVideoSeatView != null) {
            mVideoSeatView.destroy();
        }
    }

    public void onScreenShareStarted() {
        mLayoutScreenCaptureGroup.setVisibility(View.VISIBLE);

        if (mFloatingWindow == null) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            mFloatingWindow = inflater.inflate(R.layout.tuiroomkit_screen_capture_floating_window, null, false);
            showFloatingWindow();
        }
    }

    public void onScreenShareStopped() {
        hideFloatingWindow();
        mLayoutScreenCaptureGroup.setVisibility(View.GONE);
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
            ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_mute_video_by_master));
        } else {
            ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_un_mute_video_by_master));
        }
    }

    public void onMicrophoneMuted(boolean muted) {
        if (muted) {
            ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_mute_audio_by_master));
        } else {
            ToastUtil.toastShortMessageCenter(mContext.getString(R.string.tuiroomkit_un_mute_audio_by_master));
        }
    }

    public void onExpandStateChanged(boolean isExpanded) {
        mIsBottomViewExpanded = isExpanded;
        showRoomBars();
    }

    public void onClick(View v) {
        if (mIsBottomViewExpanded) {
            return;
        }
        if (mIsBarsShowed) {
            hideRoomBars();
        } else {
            showRoomBars();
        }
    }

    private void showRoomBars() {
        mIsBarsShowed = true;
        mLayoutLocalAudio.setVisibility(INVISIBLE);
        mLayoutTopView.setVisibility(VISIBLE);
        mLayoutBottomView.setVisibility(VISIBLE);
        mMainHandler.removeCallbacksAndMessages(null);
        if (mIsBottomViewExpanded) {
            return;
        }
        int showTime = ROOM_BARS_DISMISS_DELAY_MS;
        if (mIsBarsFirstShow) {
            mIsBarsFirstShow = false;
            showTime = ROOM_BARS_FIRST_SHOW_TIME_MS;
        }
        mMainHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                hideRoomBars();
            }
        }, showTime);
    }

    private void hideRoomBars() {
        mIsBarsShowed = false;
        mLayoutTopView.setVisibility(INVISIBLE);
        mLayoutBottomView.setVisibility(INVISIBLE);
        mLayoutLocalAudio.setVisibility(VISIBLE);
        mMainHandler.removeCallbacksAndMessages(null);
    }
}
