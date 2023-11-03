package com.tencent.cloud.tuikit.roomkit.viewmodel;

import static com.tencent.cloud.tuikit.roomkit.model.RoomConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_ADD;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_REMOVE;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.AGREE_TAKE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter.RoomKitUIEvent.DISAGREE_TAKE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant.KEY_USER_POSITION;

import android.content.res.Configuration;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventCenter;
import com.tencent.cloud.tuikit.roomkit.model.RoomEventConstant;
import com.tencent.cloud.tuikit.roomkit.model.entity.TakeSeatRequestEntity;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.page.widget.raisehandcontrolpanel.RaiseHandApplicationListPanel;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RaiseHandApplicationListViewModel
        implements RoomEventCenter.RoomEngineEventResponder, RoomEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "ApplyListViewModel";

    private final RaiseHandApplicationListPanel mApplyView;

    private List<TakeSeatRequestEntity> mTakeSeatRequestList;

    public RaiseHandApplicationListViewModel(RaiseHandApplicationListPanel view) {
        mApplyView = view;

        mTakeSeatRequestList = RoomEngineManager.sharedInstance().getRoomStore().takeSeatRequestList;

        subscribeEvent();
    }

    private void subscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(USER_TAKE_SEAT_REQUEST_ADD, this);
        eventCenter.subscribeEngine(USER_TAKE_SEAT_REQUEST_REMOVE, this);

        eventCenter.subscribeUIEvent(AGREE_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(DISAGREE_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        RoomEventCenter eventCenter = RoomEventCenter.getInstance();
        eventCenter.subscribeEngine(USER_TAKE_SEAT_REQUEST_ADD, this);
        eventCenter.subscribeEngine(USER_TAKE_SEAT_REQUEST_REMOVE, this);

        eventCenter.unsubscribeUIEvent(AGREE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(DISAGREE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    public List<TakeSeatRequestEntity> getApplyList() {
        return mTakeSeatRequestList;
    }

    public List<TakeSeatRequestEntity> searchUserByKeyWords(String keyWords) {
        if (TextUtils.isEmpty(keyWords)) {
            return new ArrayList<>();
        }

        List<TakeSeatRequestEntity> searchList = new ArrayList<>();
        for (TakeSeatRequestEntity item : mTakeSeatRequestList) {
            if (item.getUserName().contains(keyWords) || item.getUserId().contains(keyWords)) {
                searchList.add(item);
            }
        }
        return searchList;
    }

    public void agreeAllUserOnStage() {
        for (TakeSeatRequestEntity item : mTakeSeatRequestList) {
            TUIRoomDefine.Request request = item.getRequest();
            if (request == null) {
                continue;
            }
            RoomEngineManager.sharedInstance()
                    .responseRemoteRequest(request.requestAction, request.requestId, true, null);
        }
    }

    public void inviteMemberOnstage() {
        RoomEventCenter.getInstance().notifyUIEvent(RoomEventCenter.RoomKitUIEvent.SHOW_USER_LIST, null);
    }

    @Override
    public void onEngineEvent(RoomEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case USER_TAKE_SEAT_REQUEST_ADD:
                onAddTakeSeatRequest(params);
                break;

            case USER_TAKE_SEAT_REQUEST_REMOVE:
                onRemoveTakeSeatRequest(params);
                break;

            default:
                break;
        }
    }

    private void onAddTakeSeatRequest(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mApplyView.notifyItemInserted(position);
    }

    private void onRemoveTakeSeatRequest(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        mApplyView.notifyItemRemoved(position);
    }

    @Override
    public void onNotifyUIEvent(String key, Map<String, Object> params) {
        switch (key) {
            case AGREE_TAKE_SEAT:
                responseUserOnStage(params, true);
                break;
            case DISAGREE_TAKE_SEAT:
                responseUserOnStage(params, false);
                break;
            case CONFIGURATION_CHANGE:
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
        TakeSeatRequestEntity request =
                RoomEngineManager.sharedInstance().getRoomStore().getTakeSeatRequestEntity(userId);
        if (request == null) {
            return;
        }

        RoomEngineManager.sharedInstance()
                .responseRemoteRequest(request.getRequest().requestAction, request.getRequest().requestId, agree, null);
    }
}
