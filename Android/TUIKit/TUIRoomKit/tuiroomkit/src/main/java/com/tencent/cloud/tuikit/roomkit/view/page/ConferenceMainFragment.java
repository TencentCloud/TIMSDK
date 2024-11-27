package com.tencent.cloud.tuikit.roomkit.view.page;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.ROOM_ID_NOT_EXIST;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.SUCCESS;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_ERROR;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_INFO;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_JOINED;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_MESSAGE;
import static com.tencent.cloud.tuikit.roomkit.model.ConferenceEventConstant.KEY_CONFERENCE_STARTED;

import android.app.Activity;
import android.content.res.Configuration;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomToast;
import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.view.EnterConferencePasswordView;
import com.tencent.cloud.tuikit.roomkit.viewmodel.ConferenceMainViewModel;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUICore;

import java.util.HashMap;
import java.util.Map;

public class ConferenceMainFragment extends Fragment {
    private static final String TAG = "ConferenceMainFm";

    private       FragmentActivity            mActivity;
    private       OnBackPressedCallback       mBackPressedCallback;
    private final ConferenceMainViewModel     mViewModel = new ConferenceMainViewModel(this);
    private       EnterConferencePasswordView mPasswordPopView;

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
                param.put(KEY_CONFERENCE_MESSAGE, message);
                TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_STARTED, param);
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
                    param.put(KEY_CONFERENCE_MESSAGE, message);
                    TUICore.notifyEvent(KEY_CONFERENCE, KEY_CONFERENCE_JOINED, param);
                    RoomToast.toastLongMessageCenter(error == ROOM_ID_NOT_EXIST ? getString(R.string.tuiroomkit_room_not_exit) : message);
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
                    RoomToast.toastLongMessageCenter(message);
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
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mViewModel.init();
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
        keepScreenOn(false);
    }
}
