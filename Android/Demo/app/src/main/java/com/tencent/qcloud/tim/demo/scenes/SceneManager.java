package com.tencent.qcloud.tim.demo.scenes;

import android.content.Intent;
import android.text.TextUtils;

import androidx.fragment.app.Fragment;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSignalingInfo;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.TUIKitLiveListenerManager;
import com.tencent.qcloud.tim.demo.bean.CallModel;
import com.tencent.qcloud.tim.demo.bean.OfflineMessageBean;
import com.tencent.qcloud.tim.demo.component.interfaces.IBaseLiveListener;
import com.tencent.qcloud.tim.demo.main.MainActivity;
import com.tencent.qcloud.tim.demo.scenes.net.RoomManager;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.live.TUILiveService;
import com.tencent.qcloud.tim.uikit.live.base.LiveMessageInfo;
import com.tencent.qcloud.tim.uikit.live.livemsg.LiveGroupMessageClickListener;
import com.tencent.qcloud.tim.uikit.live.livemsg.TUILiveOnClickListenerManager;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.rtmp.TXLiveBase;

public class SceneManager {
    private static final String TAG = SceneManager.class.getSimpleName();

    public static void init(DemoApplication application, String licenseUrl, String licenseKey) {
        if (application != null && licenseUrl != null && licenseKey != null) {
            TXLiveBase.getInstance().setLicence(application, licenseUrl, licenseKey);
        }

        TUIKitLiveListenerManager.getInstance().registerCallListener(new SceneLiveController());
        TUILiveOnClickListenerManager.setGroupLiveHandler(new TUILiveOnClickListenerManager.GroupLiveHandler() {
            @Override
            public boolean startGroupLive(String groupId) {
                LiveRoomAnchorActivity.start(DemoApplication.instance(), groupId);
                // demo层对消息进行处理，不走默认的逻辑
                return true;
            }
        });

        // 设置自定义的消息渲染时的回调
        TUILiveOnClickListenerManager.setLiveGroupMessageClickListener(new LiveGroupMessageClickListener() {

            @Override
            public boolean handleLiveMessage(LiveMessageInfo info, String groupId) {
                String selfUserId = V2TIMManager.getInstance().getLoginUser();
                if (String.valueOf(info.anchorId).equals(selfUserId)) {
                    createRoom(groupId);
                } else {
                    checkRoomExist(info);
                }
                return true;
            }
        });
    }

    static class SceneLiveController implements IBaseLiveListener {

        @Override
        public void handleOfflinePushCall(Intent intent) {
            if (intent == null) {
                return;
            }
            final CallModel model = (CallModel) intent.getSerializableExtra(Constants.CALL_MODEL);
            if (model != null) {
                if (TextUtils.isEmpty(model.groupId)) {
                    DemoLog.e(TAG, "AVCall groupId is empty");
                } else {
                    TUIKit.startCall(model.sender, model.data);
                }
            }
        }

        @Override
        public void handleOfflinePushCall(OfflineMessageBean bean) {
            if (bean == null || bean.content == null) {
                return;
            }
            final CallModel model = new Gson().fromJson(bean.content, CallModel.class);
            DemoLog.i(TAG, "bean: " + bean + " model: " + model);
            if (model != null) {
                long timeout = V2TIMManager.getInstance().getServerTime() - bean.sendTime;
                if (timeout >= model.timeout) {
                    ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.call_time_out));
                } else {
                    TUIKit.startCall(bean.sender, bean.content);
                }
            }
        }

        @Override
        public void redirectCall(OfflineMessageBean bean) {
            if (bean == null || bean.content == null) {
                return;
            }
            final CallModel model = new Gson().fromJson(bean.content, CallModel.class);
            DemoLog.i(TAG, "bean: " + bean + " model: " + model);
            if (model != null) {
                model.sender = bean.sender;
                model.data = bean.content;
                long timeout = V2TIMManager.getInstance().getServerTime() - bean.sendTime;
                if (timeout >= model.timeout) {
                    ToastUtil.toastLongMessage(DemoApplication.instance().getString(R.string.call_time_out));
                } else {
                    if (TextUtils.isEmpty(model.groupId)) {
                        Intent mainIntent = new Intent(DemoApplication.instance(), MainActivity.class);
                        mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        DemoApplication.instance().startActivity(mainIntent);
                    } else {
                        V2TIMSignalingInfo info = new V2TIMSignalingInfo();
                        info.setInviteID(model.callId);
                        info.setInviteeList(model.invitedList);
                        info.setGroupID(model.groupId);
                        info.setInviter(bean.sender);
                        V2TIMManager.getSignalingManager().addInvitedSignaling(info, new V2TIMCallback() {

                            @Override
                            public void onError(int code, String desc) {
                                DemoLog.e(TAG, "addInvitedSignaling code: " + code + " desc: " + desc);
                            }

                            @Override
                            public void onSuccess() {
                                Intent mainIntent = new Intent(DemoApplication.instance(), MainActivity.class);
                                mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                DemoApplication.instance().startActivity(mainIntent);
                                TUIKit.startCall(bean.sender, model.data);
                            }
                        });
                    }
                }
            }
        }

        @Override
        public Fragment getSceneFragment() {
            return new ScenesFragment();
        }

        @Override
        public void refreshUserInfo() {
            TUILiveService.refreshLoginUserInfo(null);
        }

    }


    private static void checkRoomExist(final LiveMessageInfo info) {
        RoomManager.getInstance().checkRoomExist(RoomManager.TYPE_GROUP_LIVE, info.roomId, new RoomManager.ActionCallback() {
            @Override
            public void onSuccess() {
                enterRoom(info);
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtil.toastShortMessage(TUILiveService.getAppContext().getString(R.string.live_is_over));
            }
        });
    }

    private static void createRoom(String groupId) {
        LiveRoomAnchorActivity.start(DemoApplication.instance(), groupId);
    }

    private static void enterRoom(LiveMessageInfo info) {
        Intent intent = new Intent(DemoApplication.instance(), LiveRoomAudienceActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(RoomManager.ROOM_TITLE, info.roomName);
        intent.putExtra(RoomManager.ROOM_ID, info.roomId);
        intent.putExtra(RoomManager.USE_CDN_PLAY, false);
        intent.putExtra(RoomManager.ANCHOR_ID, info.anchorId);
        intent.putExtra(RoomManager.PUSHER_NAME, info.anchorName);
        intent.putExtra(RoomManager.COVER_PIC, info.roomCover);
        intent.putExtra(RoomManager.PUSHER_AVATAR, info.roomCover);
        DemoApplication.instance().startActivity(intent);
    }

}
