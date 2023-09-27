package com.tencent.cloud.tuikit.roomkit.viewmodel;

import android.content.res.Configuration;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.RoomStore;
import com.tencent.cloud.tuikit.roomkit.model.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.RaiseHandApplicationListView;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RaiseHandApplicationListViewModel
        implements RoomEventCenter.RoomEngineEventResponder, RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "ApplyListViewModel";

    private final RoomStore                    mRoomStore;
    private final RaiseHandApplicationListView mApplyView;

    private List<UserEntity>                   mApplyUserList;
    private Map<String, TUIRoomDefine.Request> mApplyMap;

    public RaiseHandApplicationListViewModel(RaiseHandApplicationListView view) {
        mApplyView = view;
        mRoomStore = RoomEngineManager.sharedInstance().getRoomStore();

        mApplyUserList = new ArrayList<>();
        mApplyMap = new HashMap<>();

        subscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REQUEST_RECEIVED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REQUEST_CANCELLED, this);
        eventCenter.subscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.AGREE_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.DISAGREE_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REQUEST_RECEIVED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REQUEST_CANCELLED, this);
        eventCenter.unsubscribeEngine(RoomEventCenter.RoomEngineEvent.REMOTE_USER_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.AGREE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.DISAGREE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE, this);
    }

    private void addApplyUser(TUIRoomDefine.Request request) {
        if (mApplyMap.containsKey(request.userId)) {
            return;
        }
        mApplyMap.put(request.userId, request);
        UserEntity user = mRoomStore.findUserWithCameraStream(mRoomStore.allUserList, request.userId);
        mApplyUserList.add(user);
        mApplyView.notifyItemInserted(mApplyUserList.size() - 1);
    }

    public List<UserEntity> getApplyList() {
        return mApplyUserList;
    }

    public List<UserEntity> searchUserByKeyWords(String keyWords) {
        if (TextUtils.isEmpty(keyWords)) {
            return new ArrayList<>();
        }

        List<UserEntity> searchList = new ArrayList<>();
        for (UserEntity item : mApplyUserList) {
            if (item.getUserName().contains(keyWords) || item.getUserId().contains(keyWords)) {
                searchList.add(item);
            }
        }
        return searchList;
    }

    public void agreeAllUserOnStage() {
        for (UserEntity item : mApplyUserList) {
            TUIRoomDefine.Request request = mApplyMap.get(item.getUserId());
            if (request == null) {
                continue;
            }
            RoomEngineManager.sharedInstance()
                    .responseRemoteRequest(request.requestAction, request.requestId, true, null);
        }
        mApplyMap.clear();
        mApplyUserList.clear();
        mApplyView.notifyDataSetChanged();
    }

    public void inviteMemberOnstage() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_LIST, null);
    }

    private boolean isOwner() {
        return TUIRoomDefine.Role.ROOM_OWNER.equals(mRoomStore.userModel.role);
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case REQUEST_RECEIVED:
                onRequestReceived(params);
                break;
            case REQUEST_CANCELLED:
                onRequestCancelled(params);
                break;
            case REMOTE_USER_TAKE_SEAT:
                onRemoteUserTakeSeat(params);
                break;
            default:
                break;
        }
    }

    private void onRequestReceived(Map<String, Object> params) {
        TUIRoomDefine.Request request = (TUIRoomDefine.Request) params.get(RoomEventConstant.KEY_REQUEST);
        if (request == null) {
            return;
        }
        if (isOwner() && TextUtils.equals(request.userId, TUILogin.getUserId())) {
            RoomEngineManager.sharedInstance()
                    .responseRemoteRequest(request.requestAction, request.requestId, true, null);
        }
        if (TUIRoomDefine.RequestAction.REQUEST_TO_TAKE_SEAT == request.requestAction) {
            addApplyUser(request);
        }
    }

    private void onRequestCancelled(Map<String, Object> params) {
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        removeApplyUser(userId);
    }

    private void onRemoteUserTakeSeat(Map<String, Object> params) {
        int position = (int) params.get(RoomEventConstant.KEY_USER_POSITION);
        removeApplyUser(mRoomStore.seatUserList.get(position).getUserId());
    }

    private void removeApplyUser(String userId) {
        if (!mApplyMap.containsKey(userId)) {
            return;
        }
        mApplyMap.remove(userId);
        UserEntity user = findUser(userId);
        if (user == null) {
            return;
        }
        int index = mApplyUserList.indexOf(user);
        mApplyUserList.remove(index);
        mApplyView.notifyItemRemoved(index);
    }

    private UserEntity findUser(String userId) {
        for (UserEntity item : mApplyUserList) {
            if (TextUtils.equals(item.getUserId(), userId)) {
                return item;
            }
        }
        return null;
    }


    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        switch (key) {
            case RoomEventCenter.RoomKitUIEvent.AGREE_TAKE_SEAT:
                responseUserOnStage(params, true);
                break;
            case RoomEventCenter.RoomKitUIEvent.DISAGREE_TAKE_SEAT:
                responseUserOnStage(params, false);
                break;
            case RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE:
                if (!mApplyView.isShowing()) {
                    break;
                }
                Configuration configuration = (Configuration) params.get(RoomEventConstant.KEY_CONFIGURATION);
                mApplyView.changeConfiguration(configuration);
                break;
            default:
                break;
        }
    }

    private void responseUserOnStage(Map<String, Object> params, boolean agree) {
        if (params == null) {
            return;
        }
        String userId = (String) params.get(RoomEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        if (!mApplyMap.containsKey(userId)) {
            return;
        }
        if (mApplyMap.get(userId) == null) {
            return;
        }
        RoomEngineManager.sharedInstance()
                .responseRemoteRequest(mApplyMap.get(userId).requestAction, mApplyMap.get(userId).requestId, agree,
                        null);
        removeApplyUser(userId);
    }
}
