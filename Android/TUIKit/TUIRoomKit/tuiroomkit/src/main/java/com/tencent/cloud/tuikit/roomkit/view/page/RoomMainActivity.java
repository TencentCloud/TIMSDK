package com.tencent.cloud.tuikit.roomkit.view.page;

import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_DESTROY_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_EXIT_ROOM;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_GENERAL_TO_MANAGER;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_MANAGER_TO_GENERAL;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.LOCAL_USER_TO_OWNER;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.REQUEST_RECEIVED;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.ENTER_FLOAT_WINDOW;

import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.BaseDialogFragment;
import com.tencent.cloud.tuikit.roomkit.view.component.TipToast;

import java.util.Map;

public class RoomMainActivity extends AppCompatActivity
        implements RoomEventCenter.RoomKitUIEventResponder, RoomEventCenter.RoomEngineEventResponder {
    private static final String TAG = "RoomMainAy";

    private ViewGroup mRootView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate : " + this);
        setContentView(R.layout.tuiroomkit_activity_meeting);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        initStatusBar();
        RoomMainView meetingView = new RoomMainView(this);
        mRootView = findViewById(R.id.root_view);
        mRootView.addView(meetingView);

        subscribeEvent();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (Configuration.ORIENTATION_PORTRAIT == newConfig.orientation) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        } else {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
    }

    @Override
    public void onBackPressed() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, null);
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.d(TAG, "onStart");
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.d(TAG, "onResume");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG, "onStop");
    }

    @Override
    public void finish() {
        super.finish();
        Log.d(TAG, "finish");
        release();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy : " + this);
        release();
    }

    private void release() {
        if (mRootView == null) {
            return;
        }
        Log.d(TAG, "release");
        mRootView.removeAllViews();
        mRootView = null;
        unSubscribeEvent();
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        Log.d(TAG, "onNotifyUIEvent key=" + key);
        switch (key) {
            case ENTER_FLOAT_WINDOW:
                finish();
                break;
            default:
                Log.w(TAG, "onNotifyUIEvent not handle event : " + key);
                break;
        }
    }

    private void subscribeEvent() {
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_USER_EXIT_ROOM, this);
        RoomEventCenter.getInstance().subscribeEngine(REQUEST_RECEIVED, this);
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_USER_GENERAL_TO_MANAGER, this);
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_USER_MANAGER_TO_GENERAL, this);
        RoomEventCenter.getInstance().subscribeEngine(LOCAL_USER_TO_OWNER, this);

        RoomEventCenter.getInstance().subscribeUIEvent(ENTER_FLOAT_WINDOW, this);
    }

    private void unSubscribeEvent() {
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_DESTROY_ROOM, this);
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_EXIT_ROOM, this);
        RoomEventCenter.getInstance().unsubscribeEngine(REQUEST_RECEIVED, this);
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_GENERAL_TO_MANAGER, this);
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_MANAGER_TO_GENERAL, this);
        RoomEventCenter.getInstance().unsubscribeEngine(LOCAL_USER_TO_OWNER, this);

        RoomEventCenter.getInstance().unsubscribeUIEvent(ENTER_FLOAT_WINDOW, this);
    }

    private void initStatusBar() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView()
                    .setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        Log.d(TAG, "onEngineEvent event=" + event);
        switch (event) {
            case LOCAL_USER_DESTROY_ROOM:
            case LOCAL_USER_EXIT_ROOM:
                finish();
                break;

            case LOCAL_USER_GENERAL_TO_MANAGER:
                toastForGeneralToManager();
                break;

            case LOCAL_USER_MANAGER_TO_GENERAL:
                toastForManagerToGeneral();
                break;

            case LOCAL_USER_TO_OWNER:
                toastForToOwner();
                break;

            case REQUEST_RECEIVED:
                showRequestDialog(params);
                break;

            default:
                Log.w(TAG, "onEngineEvent not handle event : " + event);
                break;
        }
    }

    private void toastForGeneralToManager() {
        TipToast.build()
                .setDuration(Toast.LENGTH_LONG)
                .setMessage(getString(R.string.tuiroomkit_have_become_manager))
                .show(this);
    }

    private void toastForManagerToGeneral() {
        TipToast.build()
                .setDuration(Toast.LENGTH_LONG)
                .setMessage(getString(R.string.tuiroomkit_have_been_cancel_manager))
                .show(this);
    }

    private void toastForToOwner() {
        TipToast.build()
                .setDuration(Toast.LENGTH_LONG)
                .setMessage(getString(R.string.tuiroomkit_toast_become_to_owner))
                .show(this);
    }

    private void showRequestDialog(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        TUIRoomDefine.Request request = (TUIRoomDefine.Request) params.get(RoomEventConstant.KEY_REQUEST);
        TUIRoomDefine.Role role = (TUIRoomDefine.Role) params.get(RoomEventConstant.KEY_ROLE);
        String userRole = getString(role == TUIRoomDefine.Role.ROOM_OWNER ? R.string.tuiroomkit_role_owner :
                R.string.tuiroomkit_role_manager);
        switch (request.requestAction) {
            case REQUEST_TO_OPEN_REMOTE_CAMERA:
                showInvitedOpenCamera(request, userRole);
                break;

            case REQUEST_TO_OPEN_REMOTE_MICROPHONE:
                showInvitedOpenMic(request, userRole);
                break;

            case REQUEST_REMOTE_USER_ON_SEAT:
                showInvitedTakeSeatDialog(request, userRole);
                break;

            default:
                Log.e(TAG, "showRequestDialog un handle action : " + request.requestAction);
                break;
        }
    }

    private void showInvitedOpenCamera(TUIRoomDefine.Request request, String userRole) {
        BaseDialogFragment.build()
                .setTitle(getString(R.string.tuiroomkit_request_open_camera, userRole))
                .setNegativeName(getString(R.string.tuiroomkit_refuse))
                .setPositiveName(getString(R.string.tuiroomkit_agree))
                .setNegativeListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        RoomEngineManager.sharedInstance().responseRemoteRequest(request.requestAction, request.requestId, false, null);
                    }
                })
                .setPositiveListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        RoomEngineManager.sharedInstance().responseRemoteRequest(request.requestAction, request.requestId, true, null);
                    }
                })
                .showDialog(getSupportFragmentManager(), "REQUEST_TO_OPEN_REMOTE_CAMERA");
    }

    private void showInvitedOpenMic(TUIRoomDefine.Request request, String userRole) {
        BaseDialogFragment.build()
                .setTitle(getString(R.string.tuiroomkit_request_open_microphone, userRole))
                .setNegativeName(getString(R.string.tuiroomkit_refuse))
                .setPositiveName(getString(R.string.tuiroomkit_agree))
                .setNegativeListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        RoomEngineManager.sharedInstance()
                                .responseRemoteRequest(request.requestAction, request.requestId, false, null);
                    }
                })
                .setPositiveListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        RoomEngineManager.sharedInstance()
                                .responseRemoteRequest(request.requestAction, request.requestId, true, null);
                    }
                })
                .showDialog(getSupportFragmentManager(), "REQUEST_TO_OPEN_REMOTE_MICROPHONE");
    }

    private void showInvitedTakeSeatDialog(TUIRoomDefine.Request request, String userRole) {
        BaseDialogFragment.build()
                .setTitle(getString(R.string.tuiroomkit_receive_invitation_title, userRole))
                .setContent(getString(R.string.tuiroomkit_receive_invitation_content))
                .setNegativeName(getString(R.string.tuiroomkit_refuse))
                .setPositiveName(getString(R.string.tuiroomkit_agree_on_stage))
                .setNegativeListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        RoomEngineManager.sharedInstance()
                                .responseRemoteRequest(request.requestAction, request.requestId, false, null);
                    }
                })
                .setPositiveListener(new BaseDialogFragment.ClickListener() {
                    @Override
                    public void onClick() {
                        RoomEngineManager.sharedInstance()
                                .responseRemoteRequest(request.requestAction, request.requestId, true, null);
                    }
                })
                .showDialog(getSupportFragmentManager(), "REQUEST_REMOTE_USER_ON_SEAT");
    }
}
