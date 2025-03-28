package com.tencent.cloud.tuikit.roomkit.view.bridge.chat.presenter;

import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.SelfRoomStatus.JOINED_ROOM;
import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.SelfRoomStatus.JOINING_ROOM;
import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.SelfRoomStatus.LEAVING_ROOM;
import static com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants.SelfRoomStatus.NO_IN_ROOM;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.SEND_IM_MSG_COMPLETE;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.manager.RoomManagerImpl;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.AccessRoomConstants;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.IRoomCallback;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.IRoomManager;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomMsgUserEntity;
import com.tencent.cloud.tuikit.roomkit.view.bridge.chat.model.observer.RoomObserver;
import com.tencent.cloud.tuikit.roomkit.common.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.common.utils.RoomSpUtil;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;
import com.tencent.cloud.tuikit.roomkit.common.utils.FetchRoomId;
import com.tencent.cloud.tuikit.roomkit.view.main.RoomMainActivity;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

public class RoomPresenterImpl extends RoomPresenter implements IRoomCallback, ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "RoomPresenterImpl";

    private static RoomPresenterImpl sRoomPresenter;

    private static final long         WAIT_TIME_S = 30L;
    private              IRoomManager mRoomManager;
    private              RoomObserver mRoomObserver;

    private       RoomTaskStoreHouse                 mRoomTaskStoreHouse;
    private       AccessRoomConstants.SelfRoomStatus mSelfRoomStatus = NO_IN_ROOM;
    private final TUIRoomDefine.LoginUserInfo        mSelfInfo;

    private CountDownLatch mLeaveRoomLatch;
    private CountDownLatch mJoinRoomLatch;
    private CountDownLatch mSendMsgLatch;
    private CountDownLatch mGiveUpRoomManagerLatch;
    private AtomicBoolean  mIsProcess = new AtomicBoolean(false);

    private RoomPresenterImpl() {
        addObserver();
        mRoomManager = new RoomManagerImpl();
        mRoomTaskStoreHouse = new RoomTaskStoreHouse();
        mSelfInfo = new TUIRoomDefine.LoginUserInfo();
        mSelfInfo.userId = TUILogin.getUserId();
        mSelfInfo.userName = TUILogin.getNickName();
        mSelfInfo.avatarUrl = TUILogin.getFaceUrl();
        ConferenceEventCenter.getInstance().subscribeUIEvent(SEND_IM_MSG_COMPLETE, this);
    }

    public static final RoomPresenterImpl getInstance() {
        if (sRoomPresenter != null) {
            return sRoomPresenter;
        }
        synchronized (RoomPresenterImpl.class) {
            if (sRoomPresenter != null) {
                return sRoomPresenter;
            }
            Log.d(TAG, "RoomPresenterImpl new");
            sRoomPresenter = new RoomPresenterImpl();
            return sRoomPresenter;
        }
    }

    @Override
    public void createRoom() {
        Log.d(TAG, "createRoom mSelfRoomStatus=" + mSelfRoomStatus);
        BusinessSceneUtil.setChatAccessRoom(true);
        mRoomTaskStoreHouse.postTask(new Runnable() {
            @Override
            public void run() {
                processCreateRoom();
            }
        });
    }

    private void processCreateRoom() {
        if (mSelfRoomStatus == JOINING_ROOM || mSelfRoomStatus == LEAVING_ROOM) {
            Log.w(TAG, "processCreateRoom in mSelfRoomStatus=" + mSelfRoomStatus);
            return;
        }
        if (mSelfRoomStatus == NO_IN_ROOM) {
            waitUntilCreateRoom();
            return;
        }
        mIsProcess.set(true);
        waitUntilExitPreRoom();
        waitUntilCreateRoom();
        mIsProcess.set(false);
    }

    private void waitUntilExitPreRoom() {
        waitUntilGiveUpRoomOwner();
        Log.d(TAG, "waitUntilExitPreRoom");
        if (mRoomObserver.isRoomOwner()) {
            waitUntilDestroyRoom();
        } else {
            waitUntilExitRoom();
        }
    }

    private void waitUntilExitRoom() {
        if (mRoomObserver.isRoomOwner()) {
            return;
        }
        Log.d(TAG, "waitUntilExitRoom thread=" + Thread.currentThread().getName());
        mLeaveRoomLatch = new CountDownLatch(1);
        mRoomManager.exitRoom();
        try {
            mLeaveRoomLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Log.d(TAG, "waitUntilExitRoom end");
    }

    private void waitUntilDestroyRoom() {
        if (!mRoomObserver.isRoomOwner()) {
            return;
        }
        Log.d(TAG, "waitUntilDestroyRoom thread=" + Thread.currentThread().getName());
        mLeaveRoomLatch = new CountDownLatch(1);
        mRoomManager.destroyRoom();
        try {
            mLeaveRoomLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Log.d(TAG, "waitUntilDestroyRoom end");
    }

    private void waitUntilGiveUpRoomOwner() {
        if (!mRoomObserver.isRoomOwner()) {
            return;
        }
        RoomMsgUserEntity roomManagerVolunteer = mRoomObserver.getRoomOwnerVolunteer();
        if (roomManagerVolunteer == null) {
            return;
        }
        Log.d(TAG, "waitUntilGiveUpRoomOwner thread name=" + Thread.currentThread().getName());
        mGiveUpRoomManagerLatch = new CountDownLatch(1);
        makeUserRoomOwner(roomManagerVolunteer.getUserId(), new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "waitUntilGiveUpRoomOwner onSuccess thread name=" + Thread.currentThread().getName());
                mRoomObserver.getRoomMsgData().setRoomManagerId(roomManagerVolunteer.getUserId());
                mGiveUpRoomManagerLatch.countDown();
                ConferenceController.sharedInstance(TUILogin.getAppContext()).getConferenceState().userModel.changeRole(
                        TUIRoomDefine.Role.GENERAL_USER);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.e(TAG, "waitUntilGiveUpRoomOwner onError error=" + error + " message=" + message);
                mGiveUpRoomManagerLatch.countDown();
            }
        });
        try {
            mGiveUpRoomManagerLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private void waitUntilCreateRoom() {
        mSelfRoomStatus = JOINING_ROOM;
        FetchRoomId.fetch(new FetchRoomId.GetRoomIdCallback() {
            @Override
            public void onGetRoomId(String roomId) {
                mRoomTaskStoreHouse.postTask(new Runnable() {
                    @Override
                    public void run() {
                        addObserver();
                        mSendMsgLatch = new CountDownLatch(1);
                        mRoomObserver.initMsgData(roomId);
                        try {
                            mSendMsgLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        mJoinRoomLatch = new CountDownLatch(1);
                        Log.d(TAG, "waitUntilCreateRoom start roomId=" + roomId);
                        ConferenceController.sharedInstance().getConferenceState().setMainActivityClass(RoomMainActivity.class);
                        mRoomManager.enableAutoShowRoomMainUi(false);
                        boolean isOpenVideo = RoomSpUtil.getVideoSwitchFromSp();
                        boolean isOpenAudio = RoomSpUtil.getAudioSwitchFromSp();
                        boolean isUseSpeaker = true;
                        mRoomManager.createRoom(roomId, isOpenAudio, isOpenVideo, isUseSpeaker);
                        try {
                            mJoinRoomLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
                        } catch (InterruptedException e) {
                            e.printStackTrace();
                        }
                        mRoomManager.enableAutoShowRoomMainUi(true);
                        Log.d(TAG, "waitUntilCreateRoom end");
                        mSelfRoomStatus = JOINED_ROOM;
                    }
                });
            }
        });
    }

    private void addObserver() {
        if (mRoomObserver == null) {
            Log.d(TAG, "addObserver");
            mRoomObserver = new RoomObserver(this);
            mRoomObserver.registerObserver();
        }
    }

    private void removeObserver() {
        if (mRoomObserver != null) {
            Log.d(TAG, "removeObserver");
            mRoomObserver.unregisterObserver();
            mRoomObserver.destroyRoomObserver();
            mRoomObserver = null;
        }
    }

    @Override
    public void enterRoom(RoomMsgData roomMsgData) {
        Log.d(TAG, "enterRoom roomId=" + roomMsgData.getRoomId() + " messageId=" + roomMsgData.getMessageId());
        BusinessSceneUtil.setChatAccessRoom(true);
        mRoomTaskStoreHouse.postTask(new Runnable() {
            @Override
            public void run() {
                processEnterRoom(roomMsgData);
            }
        });
    }

    private void processEnterRoom(RoomMsgData roomMsgData) {
        Log.d(TAG, "processEnterRoom");
        if (mSelfRoomStatus == JOINING_ROOM || mSelfRoomStatus == LEAVING_ROOM) {
            Log.w(TAG, "processEnterRoom in mSelfRoomStatus=" + mSelfRoomStatus);
            return;
        }
        if (mSelfRoomStatus == NO_IN_ROOM) {
            waitUntilEnterRoom(roomMsgData);
            return;
        }
        if (isInRoom(roomMsgData)) {
            Log.d(TAG, "processEnterRoom raiseActivity");
            ConferenceController.sharedInstance(TUILogin.getAppContext()).exitFloatWindow();
            return;
        }
        mIsProcess.set(true);
        waitUntilExitPreRoom();
        waitUntilEnterRoom(roomMsgData);
        mIsProcess.set(false);
    }

    private void waitUntilEnterRoom(RoomMsgData roomMsgData) {
        Log.d(TAG, "waitUntilEnterRoom");
        addObserver();
        mRoomObserver.setMsgData(roomMsgData);
        mJoinRoomLatch = new CountDownLatch(1);
        mSelfRoomStatus = JOINING_ROOM;
        Log.d(TAG, "waitUntilEnterRoom start");
        String roomId = roomMsgData.getRoomId();
        boolean isOpenVideo = RoomSpUtil.getVideoSwitchFromSp();
        boolean isOpenAudio = RoomSpUtil.getAudioSwitchFromSp();
        boolean isUseSpeaker = true;
        mRoomManager.enterRoom(roomId, isOpenAudio, isOpenVideo, isUseSpeaker);
        try {
            mJoinRoomLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Log.d(TAG, "waitUntilEnterRoom end");
        mSelfRoomStatus = JOINED_ROOM;
    }

    private boolean isInRoom(RoomMsgData roomMsgData) {
        if (mSelfInfo.userId.equals(roomMsgData.getRoomManagerId())) {
            return true;
        }
        for (RoomMsgUserEntity item : roomMsgData.getUserList()) {
            if (mSelfInfo.userId.equals(item.getUserId())) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void inviteOtherMembersToJoin(RoomMsgData roomMsgData) {
        mRoomTaskStoreHouse.postTask(new Runnable() {
            @Override
            public void run() {
                mRoomManager.inviteOtherMembersToJoin(roomMsgData, mSelfInfo);
            }
        });
    }

    @Override
    public void onCreateRoom(String roomId, AccessRoomConstants.RoomResult result) {
        Log.d(TAG, "onCreateRoom");
        if (result == AccessRoomConstants.RoomResult.FAILED) {
            mJoinRoomLatch.countDown();
            destroyInstance();
            return;
        }
        ConferenceController.sharedInstance(TUILogin.getAppContext()).enterFloatWindow();
    }

    @Override
    public void onEnterRoom(String roomId, AccessRoomConstants.RoomResult result) {
        Log.d(TAG, "onEnterRoom");
        BusinessSceneUtil.setCurRoomId(roomId);
        if (result == AccessRoomConstants.RoomResult.FAILED) {
            mJoinRoomLatch.countDown();
            destroyInstance();
        }
    }

    @Override
    public void onFetchUserListComplete(String roomId) {
        Log.d(TAG, "onFetchUserListComplete");
        mJoinRoomLatch.countDown();
    }

    @Override
    public void onExitRoom(String roomId) {
        Log.d(TAG, "onExitRoom mIsProcess=" + mIsProcess.get());
        BusinessSceneUtil.setCurRoomId(null);
        if (mIsProcess.get()) {
            mLeaveRoomLatch.countDown();
            return;
        }
        destroyInstance();
    }

    @Override
    public void onDestroyRoom(String roomId) {
        Log.d(TAG, "onDestroyRoom mIsProcess=" + mIsProcess.get());
        BusinessSceneUtil.setCurRoomId(null);
        if (mIsProcess.get()) {
            mLeaveRoomLatch.countDown();
            return;
        }
        destroyInstance();
    }

    private void destroyInstance() {
        Log.d(TAG, "destroyInstance");
        mSelfRoomStatus = NO_IN_ROOM;
        removeObserver();
        sRoomPresenter = null;
        mRoomTaskStoreHouse.destroyRoomTaskStoreHouse();
        BusinessSceneUtil.setChatAccessRoom(false);
        ConferenceEventCenter.getInstance().unsubscribeUIEvent(SEND_IM_MSG_COMPLETE, this);
    }

    private void makeUserRoomOwner(String userId, TUIRoomDefine.ActionCallback callback) {
        mRoomManager.changeUserRole(userId, TUIRoomDefine.Role.ROOM_OWNER, callback);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        Log.d(TAG, "onNotifyUIEvent key=" + key);
        if (TextUtils.equals(key, SEND_IM_MSG_COMPLETE) && mSendMsgLatch != null) {
            mSendMsgLatch.countDown();
        }
    }
}
