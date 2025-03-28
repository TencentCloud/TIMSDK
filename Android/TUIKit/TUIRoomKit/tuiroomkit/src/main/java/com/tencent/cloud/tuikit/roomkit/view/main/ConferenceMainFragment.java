package com.tencent.cloud.tuikit.roomkit.view.main;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.SUCCESS;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.ENTER_PIP_MODE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_ERROR;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_INFO;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_JOINED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_MESSAGE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_CONFERENCE_STARTED;

import android.app.Activity;
import android.app.AppOpsManager;
import android.app.PictureInPictureParams;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.util.Rational;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.main.floatwindow.videoplaying.RoomVideoFloatView;
import com.tencent.cloud.tuikit.roomkit.view.schedule.scheduleinfo.EnterConferencePasswordView;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.trtc.tuikit.common.system.ContextProvider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class ConferenceMainFragment extends Fragment implements ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "ConferenceMainFm";

    private       FragmentActivity            mActivity;
    private       OnBackPressedCallback       mBackPressedCallback;
    private final ConferenceMainViewModel     mViewModel = new ConferenceMainViewModel(this);
    private       EnterConferencePasswordView mPasswordPopView;

    private ViewGroup                      mRootViewGroup;
    private RoomVideoFloatView             mPipFloatView;
    private ConferenceMainView             mConferenceMainView;
    private PictureInPictureParams.Builder mPictureInPictureParamsBuilder;

    public void startConference(ConferenceDefine.StartConferenceParams startConferenceParams) {
        if (ConferenceController.sharedInstance().getRoomController().isInRoom()) {
            Log.d(TAG, "startConference already in room");
            RoomToast.toastLongMessage(ServiceInitializer.getAppContext().getString(R.string.tuiroomkit_room_msg_joined));
            return;
        }
        mViewModel.startConference(startConferenceParams, new ConferenceMainViewModel.GetConferenceInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                Map<String, Object> param = new HashMap<>(3);
                param.put(KEY_CONFERENCE_INFO, roomInfo);
                param.put(KEY_CONFERENCE_ERROR, SUCCESS);
                param.put(KEY_CONFERENCE_MESSAGE, "");
                TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_STARTED, param);
            }

            @Override
            public void onError(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message) {
                onDismiss();
                Map<String, Object> param = new HashMap<>(3);
                param.put(KEY_CONFERENCE_INFO, roomInfo);
                param.put(KEY_CONFERENCE_ERROR, error);
                param.put(KEY_CONFERENCE_MESSAGE, transErrorMessage(error, message));
                TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_STARTED, param);
                showErrorToast(error);
            }
        });
    }

    public void joinConference(ConferenceDefine.JoinConferenceParams joinConferenceParams) {
        if (ConferenceController.sharedInstance().getRoomController().isInRoom()) {
            Log.d(TAG, "joinConference already in room");
            RoomToast.toastLongMessage(ServiceInitializer.getAppContext().getString(R.string.tuiroomkit_room_msg_joined));
            return;
        }
        mViewModel.joinConference(joinConferenceParams, new ConferenceMainViewModel.GetConferenceInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                Map<String, Object> param = new HashMap<>(3);
                param.put(KEY_CONFERENCE_INFO, roomInfo);
                param.put(KEY_CONFERENCE_ERROR, SUCCESS);
                param.put(KEY_CONFERENCE_MESSAGE, "");
                TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_JOINED, param);
            }

            @Override
            public void onError(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message) {
                if (error == TUICommonDefine.Error.NEED_PASSWORD) {
                    popEnterPasswordView(joinConferenceParams);
                } else {
                    Map<String, Object> param = new HashMap<>(3);
                    param.put(KEY_CONFERENCE_INFO, roomInfo);
                    param.put(KEY_CONFERENCE_ERROR, error);
                    param.put(KEY_CONFERENCE_MESSAGE, transErrorMessage(error, message));
                    TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_JOINED, param);
                    showErrorToast(error);
                    onDismiss();
                }
            }
        });
    }

    public void popEnterPasswordView(ConferenceDefine.JoinConferenceParams joinConferenceParams) {
        mPasswordPopView = new EnterConferencePasswordView();
        mPasswordPopView.showDialog(mActivity, null);
        mPasswordPopView.setCallback(new EnterConferencePasswordView.PasswordPopViewCallback() {
            @Override
            public void onCancel() {
                mActivity.finish();
            }

            @Override
            public void onConfirm(String password) {
                if (TextUtils.isEmpty(password)) {
                    RoomToast.toastShortMessageCenter(getContext().getString(R.string.tuiroomkit_password_is_empty));
                    return;
                }
                mPasswordPopView.enableJoinRoomButton(false);
                enterEncryptRoom(joinConferenceParams, password);
            }
        });
    }

    public void enterEncryptRoom(ConferenceDefine.JoinConferenceParams joinConferenceParams, String password) {
        mViewModel.joinEncryptRoom(joinConferenceParams, password, new ConferenceMainViewModel.GetConferenceInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                Map<String, Object> param = new HashMap<>(3);
                param.put(KEY_CONFERENCE_INFO, roomInfo);
                param.put(KEY_CONFERENCE_ERROR, SUCCESS);
                param.put(KEY_CONFERENCE_MESSAGE, "");
                TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_JOINED, param);
                mPasswordPopView.dismiss();
            }

            @Override
            public void onError(TUIRoomDefine.RoomInfo roomInfo, TUICommonDefine.Error error, String message) {
                if (error == TUICommonDefine.Error.WRONG_PASSWORD) {
                    mPasswordPopView.enableJoinRoomButton(true);
                    RoomToast.toastShortMessageCenter(getContext().getString(R.string.tuiroomkit_room_password_error));
                } else {
                    Map<String, Object> param = new HashMap<>(3);
                    param.put(KEY_CONFERENCE_INFO, roomInfo);
                    param.put(KEY_CONFERENCE_ERROR, error);
                    param.put(KEY_CONFERENCE_MESSAGE, transErrorMessage(error, message));
                    TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_JOINED, param);
                    showErrorToast(error);
                    onDismiss();
                }
            }
        });
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        Log.d(TAG, "onCreateView : " + this);
        View view = inflater.inflate(R.layout.tuiroomkit_fragment_main_conference, container, false);

        Activity activity = getActivity();
        if (!(activity instanceof FragmentActivity)) {
            Log.e(TAG, "A FragmentActivity or its subclass should be used to add the ConferenceMainFragment");
            return view;
        }
        mActivity = (FragmentActivity) activity;
        cacheCurrentActivity();

        interceptBackPressed();
        keepScreenOn(true);
        ConferenceEventCenter.getInstance().subscribeUIEvent(ENTER_PIP_MODE, this);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mViewModel.init();
        mRootViewGroup = (ViewGroup) view;
        mConferenceMainView = new ConferenceMainView(getContext());
        mRootViewGroup.addView(mConferenceMainView);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        Log.d(TAG, "onDestroyView : " + this);
        release();
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Window window = requireActivity().getWindow();
        if (Configuration.ORIENTATION_PORTRAIT == newConfig.orientation) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    void enterPipMode() {
        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.O) {
            return;
        }

        AppOpsManager appOps = (AppOpsManager) getContext().getSystemService(Context.APP_OPS_SERVICE);
        if (AppOpsManager.MODE_ALLOWED != appOps.checkOpNoThrow(AppOpsManager.OPSTR_PICTURE_IN_PICTURE, getContext().getApplicationInfo().uid, getContext().getPackageName())) {
            getContext().startActivity(new Intent("android.settings.PICTURE_IN_PICTURE_SETTINGS", Uri.parse("package:" + getContext().getPackageName())));
            return;
        }

        if (mPictureInPictureParamsBuilder == null) {
            mPictureInPictureParamsBuilder = new PictureInPictureParams.Builder();
        }

        int floatViewWidth =
                getResources().getDimensionPixelSize(R.dimen.tuiroomkit_room_video_float_view_width);
        int floatViewHeight =
                getResources().getDimensionPixelSize(R.dimen.tuiroomkit_room_video_float_view_height);

        Rational aspectRatio = new Rational(floatViewWidth, floatViewHeight);
        mPictureInPictureParamsBuilder.setActions(new ArrayList<>());
        mPictureInPictureParamsBuilder.setAspectRatio(aspectRatio).build();

        mActivity.enterPictureInPictureMode(mPictureInPictureParamsBuilder.build());
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        if (ENTER_PIP_MODE.equals(key)) {
            enterPipMode();
        }
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode);
        ConferenceController.sharedInstance().getViewState().isInPictureInPictureMode.set(isInPictureInPictureMode);
        if (isInPictureInPictureMode) {
            mConferenceMainView.setVisibility(View.GONE);
            mPipFloatView = new RoomVideoFloatView(ContextProvider.getApplicationContext());
            mRootViewGroup.addView(mPipFloatView);
            mPipFloatView.setVisibility(View.VISIBLE);
        } else {
            mRootViewGroup.removeView(mPipFloatView);
            mConferenceMainView.setVisibility(View.VISIBLE);
        }
    }

    public void onDismiss() {
        mActivity.finish();
        release();
    }

    private void keepScreenOn(boolean keep) {
        Window window = getActivity().getWindow();
        if (keep) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
    }

    private void cacheCurrentActivity() {
        Activity activity = getActivity();
        if (activity == null) {
            Log.e(TAG, "cacheCurrentActivity activity is null");
            return;
        }
        mViewModel.cacheCurrentActivity(activity);
    }

    private void interceptBackPressed() {
        mBackPressedCallback = new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                Log.e(TAG, "handleOnBackPressed");
                ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, null);
            }
        };
        requireActivity().getOnBackPressedDispatcher().addCallback(mBackPressedCallback);
    }

    private void release() {
        if (mBackPressedCallback == null) {
            return;
        }
        Log.d(TAG, "release");
        mViewModel.release();
        mBackPressedCallback.remove();
        mBackPressedCallback = null;
        mActivity = null;
        mRootViewGroup.removeView(mPipFloatView);
        keepScreenOn(false);
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(ENTER_PIP_MODE, this);
    }

    private String transErrorMessage(TUICommonDefine.Error error, String message) {
        String errorMessage = "";
        switch (error) {
            case ROOM_ID_NOT_EXIST:
                errorMessage = getString(R.string.tuiroomkit_room_not_exit);
                break;
            case ROOM_ID_OCCUPIED:
                errorMessage = getString(R.string.tuiroomkit_room_id_is_occupied);
                break;
            case ROOM_USER_FULL:
                errorMessage = getString(R.string.tuiroomkit_room_is_full);
                break;
            case ROOM_NAME_INVALID:
                errorMessage = getString(R.string.tuiroomkit_room_name_is_invalid);
                break;
            case OPERATION_INVALID_BEFORE_ENTER_ROOM:
                errorMessage = getString(R.string.tuiroomkit_use_function_need_enter_room);
                break;
            case OPERATION_NOT_SUPPORTED_IN_CURRENT_ROOM_TYPE:
                errorMessage = getString(R.string.tuiroomkit_is_not_supported_in_room_type);
                break;
            case ALREADY_IN_OTHER_ROOM:
                errorMessage = getString(R.string.tuiroomkit_already_in_another_room);
                break;
            default:
                break;
        }
        if (!TextUtils.isEmpty(errorMessage)) {
            Log.e(TAG, errorMessage);
            return errorMessage;
        }
        return message;
    }

    private void showErrorToast(TUICommonDefine.Error error) {
        String errorMessage = "";
        switch (error) {
            case ROOM_ID_NOT_EXIST:
                errorMessage = getString(R.string.tuiroomkit_room_not_exit);
                break;
            case ROOM_ID_OCCUPIED:
                errorMessage = getString(R.string.tuiroomkit_room_id_is_occupied);
                break;
            case ROOM_USER_FULL:
                errorMessage = getString(R.string.tuiroomkit_room_is_full);
                break;
            default:
                break;
        }
        if (!TextUtils.isEmpty(errorMessage)) {
            RoomToast.toastLongMessageCenter(errorMessage);
        }
    }
}
