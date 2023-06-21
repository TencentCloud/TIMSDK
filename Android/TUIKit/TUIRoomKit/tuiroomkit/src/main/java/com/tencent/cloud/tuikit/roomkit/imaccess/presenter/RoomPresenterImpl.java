package com.tencent.cloud.tuikit.roomkit.imaccess.presenter;

import static com.tencent.cloud.tuikit.engine.room.TUIRoomDefine.SpeechMode.FREE_TO_SPEAK;
import static com.tencent.cloud.tuikit.roomkit.TUIRoomKit.RoomScene.MEETING;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.ROOM_SP_FILE_NAME;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.SP_ROOM_ID;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.SelfRoomStatus.JOINED_ROOM;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.SelfRoomStatus.JOINING_ROOM;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.SelfRoomStatus.LEAVING_ROOM;
import static com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants.SelfRoomStatus.NO_IN_ROOM;
import android.text.TextUtils;
import android.util.Log;
import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.imaccess.AccessRoomConstants;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.IRoomCallback;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.IRoomManager;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.manager.RoomManagerImpl;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.observer.RoomMsgData;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.observer.RoomMsgUserEntity;
import com.tencent.cloud.tuikit.roomkit.imaccess.model.observer.RoomObserver;
import com.tencent.cloud.tuikit.roomkit.imaccess.utils.BusinessSceneUtil;
import com.tencent.cloud.tuikit.roomkit.imaccess.view.RoomFloatViewService;
import com.tencent.cloud.tuikit.roomkit.model.entity.RoomInfo;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.SPUtils;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

public class RoomPresenterImpl extends RoomPresenter implements IRoomCallback {
    private static final String TAG = "RoomPresenterImpl";

    private static RoomPresenterImpl sRoomPresenter;

    private static final long         WAIT_TIME_S = 10L;
    private              IRoomManager mRoomManager;
    private              RoomObserver mRoomObserver;

    private       RoomTaskStoreHouse                 mRoomTaskStoreHouse;
    private       AccessRoomConstants.SelfRoomStatus mSelfRoomStatus = NO_IN_ROOM;
    private final TUIRoomDefine.LoginUserInfo        mSelfInfo;

    private CountDownLatch mLoginLatch = new CountDownLatch(1);
    private CountDownLatch mLeaveRoomLatch;
    private CountDownLatch mJoinRoomLatch;
    private CountDownLatch mGiveUpRoomManagerLatch;
    private AtomicBoolean  mIsProcess  = new AtomicBoolean(false);

    private RoomPresenterImpl() {
        addObserver();
        mRoomManager = new RoomManagerImpl();
        mRoomTaskStoreHouse = new RoomTaskStoreHouse();
        mSelfInfo = new TUIRoomDefine.LoginUserInfo();
        mSelfInfo.userId = TUILogin.getUserId();
        mSelfInfo.userName = TUILogin.getNickName();
        mSelfInfo.avatarUrl = TUILogin.getFaceUrl();
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

    private void waitUntilLoginComplete() {
        try {
            mLoginLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void createRoom() {
        Log.d(TAG, "createRoom mSelfRoomStatus=" + mSelfRoomStatus);
        mRoomTaskStoreHouse.postTask(new Runnable() {
            @Override
            public void run() {
                waitUntilLoginComplete();
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
                mGiveUpRoomManagerLatch.countDown();
                RoomEngineManager.sharedInstance(TUILogin.getAppContext()).getRoomStore().userModel.role =
                        TUIRoomDefine.Role.GENERAL_USER;
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
        addObserver();
        RoomInfo roomInfo = new RoomInfo();
        roomInfo.roomId = getUniqueRoomId();
        roomInfo.owner = TUILogin.getUserId();
        roomInfo.name = TUILogin.getNickName() + TUILogin.getAppContext().getResources()
                .getString(R.string.tuiroomkit_room_msg_display_suffix);
        roomInfo.isOpenCamera = true;
        roomInfo.isOpenMicrophone = true;
        roomInfo.isUseSpeaker = false;
        roomInfo.isMicrophoneDisableForAllUser = false;
        roomInfo.isCameraDisableForAllUser = false;
        roomInfo.isMessageDisableForAllUser = false;
        roomInfo.speechMode = FREE_TO_SPEAK;
        Log.d(TAG, roomInfo.toString());
        mRoomObserver.initMsgData(roomInfo.roomId);
        mSelfRoomStatus = JOINING_ROOM;
        mJoinRoomLatch = new CountDownLatch(1);
        Log.d(TAG, "waitUntilCreateRoom start roomId=" + roomInfo.roomId);
        mRoomManager.createRoom(roomInfo, MEETING);
        try {
            mJoinRoomLatch.await(WAIT_TIME_S, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Log.d(TAG, "waitUntilCreateRoom end");
        mSelfRoomStatus = JOINED_ROOM;
        RoomFloatViewService.showFloatView(mRoomObserver.getRoomMsgData());
    }

    private String getUniqueRoomId() {
        SPUtils sp = SPUtils.getInstance(ROOM_SP_FILE_NAME);
        String roomId = sp.getString(SP_ROOM_ID);
        if (TextUtils.isEmpty(roomId) || roomId.length() < 4) {
            roomId = "100" + TUILogin.getUserId();
            sp.put(SP_ROOM_ID, roomId);
            return roomId;
        }
        String str = roomId.substring(0, 3);
        int count = 100;
        try {
            count = Integer.parseInt(str) + 1;
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        count = count < 1000 ? count : 100;
        roomId = count + TUILogin.getUserId();
        sp.put(SP_ROOM_ID, roomId);
        return roomId;
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
        mRoomTaskStoreHouse.postTask(new Runnable() {
            @Override
            public void run() {
                waitUntilLoginComplete();
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
        RoomFloatViewService.dismissFloatView();
        if (isInRoom(roomMsgData)) {
            Log.d(TAG, "processEnterRoom raiseActivity");
            mRoomManager.raiseUi();
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
        RoomInfo roomInfo = new RoomInfo();
        roomInfo.roomId = roomMsgData.getRoomId();
        roomInfo.isOpenCamera = false;
        roomInfo.isOpenMicrophone = false;
        roomInfo.isUseSpeaker = false;
        roomInfo.isMicrophoneDisableForAllUser = false;
        roomInfo.isCameraDisableForAllUser = false;
        roomInfo.isMessageDisableForAllUser = false;
        roomInfo.speechMode = FREE_TO_SPEAK;
        Log.d(TAG, roomInfo.toString());
        mRoomObserver.setMsgData(roomMsgData);
        mJoinRoomLatch = new CountDownLatch(1);
        mSelfRoomStatus = JOINING_ROOM;
        Log.d(TAG, "waitUntilEnterRoom start");
        mRoomManager.enterRoom(roomInfo);
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
                waitUntilLoginComplete();
                mRoomManager.inviteOtherMembersToJoin(roomMsgData, mSelfInfo);
            }
        });
    }

    @Override
    public void onLoginSuccess() {
        Log.d(TAG, "onLoginSuccess");
        mLoginLatch.countDown();
    }

    @Override
    public void onCreateRoom(String roomId, AccessRoomConstants.RoomResult result) {
        Log.d(TAG, "onCreateRoom");
        if (result == AccessRoomConstants.RoomResult.FAILED) {
            mJoinRoomLatch.countDown();
            destroyInstance();
        }
    }

    @Override
    public void onEnterRoom(String roomId, AccessRoomConstants.RoomResult result) {
        Log.d(TAG, "onEnterRoom");
        BusinessSceneUtil.setChatAccessRoom(true);
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
        BusinessSceneUtil.clearJoinRoomFlag();
        BusinessSceneUtil.setChatAccessRoom(false);
    }

    /**
     * 场景：用户已经创建房间，此时用户再进入另一个房间，须要在旧房间中转让房主，然后退出房间，再进去新房间。
     */
    private void makeUserRoomOwner(String userId, TUIRoomDefine.ActionCallback callback) {
        mRoomManager.changeUserRole(userId, TUIRoomDefine.Role.ROOM_OWNER, callback);
    }
}
