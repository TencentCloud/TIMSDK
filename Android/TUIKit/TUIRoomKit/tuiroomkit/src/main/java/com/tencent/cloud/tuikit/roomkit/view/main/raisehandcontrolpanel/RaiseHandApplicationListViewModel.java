package com.tencent.cloud.tuikit.roomkit.view.main.raisehandcontrolpanel;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.ALL_SEAT_OCCUPIED;
import static com.tencent.cloud.tuikit.roomkit.manager.constant.ConferenceConstant.USER_NOT_FOUND;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_ROLE_CHANGED;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_ADD;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomEngineEvent.USER_TAKE_SEAT_REQUEST_REMOVE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.AGREE_TAKE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.CONFIGURATION_CHANGE;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter.RoomKitUIEvent.DISAGREE_TAKE_SEAT;
import static com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant.KEY_USER_POSITION;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.manager.eventcenter.ConferenceEventConstant;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceState;
import com.tencent.cloud.tuikit.roomkit.state.entity.TakeSeatRequestEntity;
import com.tencent.cloud.tuikit.roomkit.state.entity.UserEntity;
import com.tencent.cloud.tuikit.roomkit.manager.ConferenceController;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class RaiseHandApplicationListViewModel
        implements ConferenceEventCenter.RoomEngineEventResponder, ConferenceEventCenter.RoomKitUIEventResponder {
    private static final String TAG = "ApplyListViewModel";

    private final RaiseHandApplicationListPanel mApplyView;

    private List<TakeSeatRequestEntity> mTakeSeatRequestList;

    private Context mContext;

    public RaiseHandApplicationListViewModel(Context context, RaiseHandApplicationListPanel view) {
        mContext = context;
        mApplyView = view;

        mTakeSeatRequestList = ConferenceController.sharedInstance().getConferenceState().takeSeatRequestList;

        subscribeEvent();
    }

    private void subscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.subscribeEngine(USER_TAKE_SEAT_REQUEST_ADD, this);
        eventCenter.subscribeEngine(USER_TAKE_SEAT_REQUEST_REMOVE, this);
        eventCenter.subscribeEngine(USER_ROLE_CHANGED, this);

        eventCenter.subscribeUIEvent(AGREE_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(DISAGREE_TAKE_SEAT, this);
        eventCenter.subscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    public void destroy() {
        unSubscribeEvent();
    }

    private void unSubscribeEvent() {
        ConferenceEventCenter eventCenter = ConferenceEventCenter.getInstance();
        eventCenter.unsubscribeEngine(USER_TAKE_SEAT_REQUEST_ADD, this);
        eventCenter.unsubscribeEngine(USER_TAKE_SEAT_REQUEST_REMOVE, this);
        eventCenter.unsubscribeEngine(USER_ROLE_CHANGED, this);

        eventCenter.unsubscribeUIEvent(AGREE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(DISAGREE_TAKE_SEAT, this);
        eventCenter.unsubscribeUIEvent(CONFIGURATION_CHANGE, this);
    }

    public List<TakeSeatRequestEntity> getApplyList() {
        return mTakeSeatRequestList;
    }

    public void agreeAllUserOnStage() {
        final AtomicInteger counter = new AtomicInteger(0);
        for (TakeSeatRequestEntity item : mTakeSeatRequestList) {
            TUIRoomDefine.Request request = item.getRequest();
            ConferenceController.sharedInstance()
                    .responseRemoteRequest(request.requestAction, request.requestId, true, new TUIRoomDefine.ActionCallback() {
                        @Override
                        public void onSuccess() {
                        }

                        @Override
                        public void onError(TUICommonDefine.Error error, String message) {
                            if (error == ALL_SEAT_OCCUPIED && counter.get() == 0) {
                                counter.incrementAndGet();
                                RoomToast.toastShortMessageCenter(
                                        mContext.getString(R.string.tuiroomkit_stage_full_of_admin));
                            }
                        }
                    });
        }
    }

    public void rejectAllUserOnStage() {
        for (TakeSeatRequestEntity item : mTakeSeatRequestList) {
            TUIRoomDefine.Request request = item.getRequest();
            if (request == null) {
                continue;
            }
            ConferenceController.sharedInstance()
                    .responseRemoteRequest(request.requestAction, request.requestId, false, null);
        }
    }

    @Override
    public void onEngineEvent(ConferenceEventCenter.RoomEngineEvent event, Map<String, Object> params) {
        switch (event) {
            case USER_TAKE_SEAT_REQUEST_ADD:
                onAddTakeSeatRequest(params);
                break;

            case USER_TAKE_SEAT_REQUEST_REMOVE:
                onRemoveTakeSeatRequest(params);
                break;

            case USER_ROLE_CHANGED:
                onUserRoleChanged(params);
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

    private void onUserRoleChanged(Map<String, Object> params) {
        if (params == null) {
            return;
        }
        int position = (int) params.get(KEY_USER_POSITION);
        if (position == USER_NOT_FOUND) {
            return;
        }
        ConferenceState store = ConferenceController.sharedInstance().getConferenceState();
        UserEntity user = store.allUserList.get(position);
        if (TextUtils.equals(user.getUserId(), store.userModel.userId)
                && user.getRole() == TUIRoomDefine.Role.GENERAL_USER) {
            mApplyView.dismiss();
        }
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
                Configuration configuration = (Configuration) params.get(ConferenceEventConstant.KEY_CONFIGURATION);
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
        String userId = (String) params.get(ConferenceEventConstant.KEY_USER_ID);
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        TakeSeatRequestEntity request =
                ConferenceController.sharedInstance().getConferenceState().getTakeSeatRequestEntity(userId);
        if (request == null) {
            return;
        }

        ConferenceController.sharedInstance()
                .responseRemoteRequest(request.getRequest().requestAction, request.getRequest().requestId, agree,
                        new TUIRoomDefine.ActionCallback() {
                            @Override
                            public void onSuccess() {
                            }

                            @Override
                            public void onError(TUICommonDefine.Error error, String message) {
                                Log.e(TAG, "responseUserOnStage onError error=" + error + " message=" + message);
                                if (error == ALL_SEAT_OCCUPIED) {
                                    RoomToast.toastShortMessageCenter(
                                            mContext.getString(R.string.tuiroomkit_stage_full_of_admin));
                                }
                            }
                        });
    }
}
