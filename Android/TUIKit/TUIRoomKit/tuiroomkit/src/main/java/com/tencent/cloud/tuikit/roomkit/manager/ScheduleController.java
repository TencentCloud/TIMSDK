package com.tencent.cloud.tuikit.roomkit.manager;

import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.FAILED;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.Error.PERMISSION_DENIED;
import static com.tencent.cloud.tuikit.engine.common.TUICommonDefine.ExtensionType.CONFERENCE_LIST_MANAGER;
import static com.tencent.cloud.tuikit.roomkit.state.ConferenceListState.FETCH_CURSOR_OF_END;
import static com.tencent.cloud.tuikit.roomkit.state.ConferenceListState.FETCH_CURSOR_OF_INIT;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.cloud.tuikit.engine.common.TUICommonDefine;
import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.engine.room.TUIRoomEngine;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceListState;
import com.tencent.cloud.tuikit.roomkit.state.UserState;
import com.tencent.qcloud.tuicore.TUILogin;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;

public class ScheduleController {
    private static final String TAG = "ScheduleController";

    private static final int SINGLE_FETCH_COUNT = 10;

    private static ScheduleController sInstance;

    private final TUIConferenceListManager mConferenceListManager;
    private final ConferenceListObserver   mConferenceListObserver;

    private final ConferenceListState           mConferenceListState;
    private final ScheduledConferenceComparator mScheduledConferenceComparator = new ScheduledConferenceComparator();

    private ScheduleController() {
        mConferenceListManager = (TUIConferenceListManager) TUIRoomEngine.sharedInstance().getExtension(CONFERENCE_LIST_MANAGER);
        mConferenceListObserver = new ConferenceListObserver();
        mConferenceListState = new ConferenceListState();
    }

    public static ScheduleController sharedInstance() {
        if (sInstance == null) {
            synchronized (ScheduleController.class) {
                if (sInstance == null) {
                    sInstance = new ScheduleController();
                }
            }
        }
        return sInstance;
    }

    public ConferenceListState getConferenceListState() {
        return mConferenceListState;
    }

    public void loginEngine(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "TUIRoomEngine.login");
        TUIRoomEngine.login(TUILogin.getAppContext(), TUILogin.getSdkAppId(), TUILogin.getUserId(), TUILogin.getUserSig(), new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "login onSuccess");
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "login onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void scheduleConference(ConferenceListState.ConferenceInfo conferenceInfo, TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "scheduleConference conferenceId=" + conferenceInfo.basicRoomInfo.roomId);
        mConferenceListManager.scheduleConference(conferenceInfo.transferToEngineData(), new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "scheduleConference onSuccess conferenceId=" + conferenceInfo.basicRoomInfo.roomId);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "scheduleConference onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void cancelConference(String conferenceId, TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "cancelConference conferenceId=" + conferenceId);
        ConferenceListState.ConferenceInfo conferenceInfo = mConferenceListState.scheduledConferences.find(new ConferenceListState.ConferenceInfo(conferenceId));
        if (conferenceInfo.status == TUIConferenceListManager.ConferenceStatus.RUNNING) {
            Log.e(TAG, "cancelConference onError error=" + FAILED + " message=Ongoing meetings cannot be cancelled.");
            callback.onError(FAILED, null);
            return;
        }
        mConferenceListManager.cancelConference(conferenceId, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "cancelConference onSuccess conferenceId=" + conferenceId);
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "cancelConference onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void updateConferenceInfo(ConferenceListState.ConferenceInfo newInfo, TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "updateConferenceInfo conferenceId=" + newInfo.basicRoomInfo.roomId);
        ConferenceListState.ConferenceInfo oldInfo = mConferenceListState.scheduledConferences.find(newInfo);
        if (oldInfo == null) {
            Log.e(TAG, "updateConferenceInfo conference not found : " + newInfo.basicRoomInfo.roomId);
            callback.onError(FAILED, null);
            return;
        }
        if (oldInfo.status == TUIConferenceListManager.ConferenceStatus.RUNNING) {
            Log.e(TAG, "updateConferenceInfo onError error=" + PERMISSION_DENIED + " message=Ongoing meetings cannot be modified.");
            callback.onError(PERMISSION_DENIED, null);
            return;
        }
        updateConferenceInfoInternal(newInfo, oldInfo, callback);
    }

    public void refreshRequiredConferences(TUIRoomDefine.ActionCallback callback) {
        Log.d(TAG, "refreshRequiredConferences");
        clearRequiredConferences();
        fetchRequiredConferences(callback);
    }

    public void fetchRequiredConferences(TUIRoomDefine.ActionCallback callback) {
        String cursor = mConferenceListState.fetchScheduledConferencesCursor;
        if (TextUtils.equals(FETCH_CURSOR_OF_END, cursor)) {
            return;
        }
        if (TextUtils.equals(FETCH_CURSOR_OF_INIT, cursor)) {
            mConferenceListManager.addObserver(mConferenceListObserver);
            cursor = "";
        }
        List<TUIConferenceListManager.ConferenceStatus> statusFilter = new ArrayList<>(2);
        statusFilter.add(TUIConferenceListManager.ConferenceStatus.RUNNING);
        statusFilter.add(TUIConferenceListManager.ConferenceStatus.NOT_STARTED);
        Log.d(TAG, "fetchRequiredConferences cursor=" + cursor);
        mConferenceListManager.fetchScheduledConferenceList(statusFilter, cursor, SINGLE_FETCH_COUNT, new TUIConferenceListManager.FetchScheduledConferenceListCallback() {
            @Override
            public void onSuccess(TUIConferenceListManager.ScheduledConferenceListResult result) {
                Log.d(TAG, "fetchRequiredConferences onSuccess");
                mConferenceListState.fetchScheduledConferencesCursor = TextUtils.isEmpty(result.cursor) ? FETCH_CURSOR_OF_END : result.cursor;
                for (TUIConferenceListManager.ConferenceInfo item : result.conferenceInfoList) {
                    mConferenceListState.scheduledConferences.insert(new ConferenceListState.ConferenceInfo(item), mScheduledConferenceComparator);
                }
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "fetchRequiredConferences onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void clearRequiredConferences() {
        Log.d(TAG, "clearRequiredConferences");
        mConferenceListState.fetchScheduledConferencesCursor = FETCH_CURSOR_OF_INIT;
        mConferenceListState.scheduledConferences.clear();
        mConferenceListManager.removeObserver(mConferenceListObserver);
    }

    public void fetchAttendeeList(String conferenceId, TUIRoomDefine.ActionCallback callback) {
        ConferenceListState.ConferenceInfo conferenceInfo = mConferenceListState.scheduledConferences.find(new ConferenceListState.ConferenceInfo(conferenceId));
        String cursor = conferenceInfo.fetchScheduledAttendeesCursor;
        Log.d(TAG, "fetchAttendeeList conferenceId=" + conferenceId + " fetchScheduledAttendeesCursor=" + conferenceInfo.fetchScheduledAttendeesCursor);
        if (TextUtils.equals(FETCH_CURSOR_OF_END, cursor)) {
            return;
        }
        cursor = TextUtils.equals(cursor, FETCH_CURSOR_OF_INIT) ? "" : cursor;
        mConferenceListManager.fetchAttendeeList(conferenceId, cursor, SINGLE_FETCH_COUNT, new TUIConferenceListManager.FetchScheduledAttendeesCallback() {
            @Override
            public void onSuccess(TUIConferenceListManager.ScheduledAttendeesResult result) {
                conferenceInfo.fetchScheduledAttendeesCursor = TextUtils.isEmpty(result.cursor) ? FETCH_CURSOR_OF_END : result.cursor;
                if (conferenceInfo.hadScheduledAttendeeCount.get() != result.totalAttendeeCount) {
                    conferenceInfo.hadScheduledAttendeeCount.set(result.totalAttendeeCount);
                }
                Log.d(TAG, "fetchAttendeeList onSuccess mFetchAttendeeCursor=" + result.cursor);
                List<UserState.UserInfo> attendees = conferenceInfo.hadScheduledAttendees.getList();
                for (TUIRoomDefine.UserInfo item : result.scheduleAttendees) {
                    UserState.UserInfo userInfo = new UserState.UserInfo(item);
                    attendees.add(userInfo);
                }
                conferenceInfo.hadScheduledAttendees.redirect(attendees);
                if (TextUtils.equals(FETCH_CURSOR_OF_END, conferenceInfo.fetchScheduledAttendeesCursor)) {
                    if (callback != null) {
                        callback.onSuccess();
                    }
                } else {
                    fetchAttendeeList(conferenceId, callback);
                }
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "fetchAttendeeList onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
            }
        });
    }

    public void clearAttendeeList(String conferenceId) {
        ConferenceListState.ConferenceInfo conferenceInfo = mConferenceListState.scheduledConferences.find(new ConferenceListState.ConferenceInfo(conferenceId));
        conferenceInfo.fetchScheduledAttendeesCursor = FETCH_CURSOR_OF_INIT;
        conferenceInfo.hadScheduledAttendees.clear();
        conferenceInfo.hadScheduledAttendeeCount.set(0);
    }

    public void fetchRoomInfo(String roomId, TUIRoomDefine.GetRoomInfoCallback callback) {
        TUIRoomEngine.sharedInstance().fetchRoomInfo(roomId, TUIRoomDefine.RoomType.CONFERENCE, new TUIRoomDefine.GetRoomInfoCallback() {
            @Override
            public void onSuccess(TUIRoomDefine.RoomInfo roomInfo) {
                callback.onSuccess(roomInfo);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "fetchRoomInfo onError error=" + error + " message=" + message);
                callback.onError(error, message);
            }
        });
    }

    private class ConferenceListObserver extends TUIConferenceListManager.Observer {
        @Override
        public void onConferenceScheduled(TUIConferenceListManager.ConferenceInfo conferenceInfo) {
            Log.d(TAG, "onConferenceScheduled conferenceId=" + conferenceInfo.basicRoomInfo.roomId);
            mConferenceListState.scheduledConferences.insert(new ConferenceListState.ConferenceInfo(conferenceInfo), mScheduledConferenceComparator);
        }

        @Override
        public void onConferenceWillStart(TUIConferenceListManager.ConferenceInfo conferenceInfo) {
            Log.d(TAG, "onConferenceWillStart conferenceId=" + conferenceInfo.basicRoomInfo.roomId);
        }

        @Override
        public void onConferenceCancelled(String conferenceId, TUIConferenceListManager.ConferenceCancelReason reason, TUIRoomDefine.UserInfo operateUser) {
            Log.d(TAG, "onConferenceCancelled conferenceId=" + conferenceId);
            mConferenceListState.scheduledConferences.remove(new ConferenceListState.ConferenceInfo(conferenceId));
        }

        @Override
        public void onConferenceInfoChanged(TUIConferenceListManager.ConferenceInfo conferenceInfo, List<TUIConferenceListManager.ConferenceModifyFlag> modifyFlagList) {
            Log.d(TAG, "onConferenceInfoChanged conferenceId=" + conferenceInfo.basicRoomInfo.roomId);
            ConferenceListState.ConferenceInfo newInfo = new ConferenceListState.ConferenceInfo(conferenceInfo);
            ConferenceListState.ConferenceInfo oldInfo = mConferenceListState.scheduledConferences.find(newInfo);
            if (oldInfo == null) {
                mConferenceListState.scheduledConferences.insert(newInfo, mScheduledConferenceComparator);
                return;
            }
            oldInfo.update(conferenceInfo);
            mConferenceListState.scheduledConferences.change(oldInfo);
            mConferenceListState.scheduledConferences.move(oldInfo, mScheduledConferenceComparator);
        }

        @Override
        public void onScheduleAttendeesChanged(String roomId, List<TUIRoomDefine.UserInfo> leftUsers, List<TUIRoomDefine.UserInfo> joinedUsers) {
            ConferenceListState.ConferenceInfo conferenceInfo = mConferenceListState.scheduledConferences.find(new ConferenceListState.ConferenceInfo(roomId));
            if (conferenceInfo == null) {
                return;
            }
            for (TUIRoomDefine.UserInfo item : leftUsers) {
                conferenceInfo.hadScheduledAttendees.remove(new UserState.UserInfo(item.userId));
            }
            for (TUIRoomDefine.UserInfo item : joinedUsers) {
                conferenceInfo.hadScheduledAttendees.add(new UserState.UserInfo(item));
            }
        }

        @Override
        public void onConferenceStatusChanged(String roomId, TUIConferenceListManager.ConferenceStatus status) {
            ConferenceListState.ConferenceInfo conferenceInfo = mConferenceListState.scheduledConferences.find(new ConferenceListState.ConferenceInfo(roomId));
            if (conferenceInfo == null) {
                return;
            }
            conferenceInfo.status = status;
            mConferenceListState.scheduledConferences.change(conferenceInfo);
        }
    }

    private void updateConferenceInfoInternal(ConferenceListState.ConferenceInfo newInfo, ConferenceListState.ConferenceInfo oldInfo, TUIRoomDefine.ActionCallback callback) {
        List<TUIConferenceListManager.ConferenceModifyFlag> modifyFlagList = new LinkedList<>();
        if (!TextUtils.equals(newInfo.basicRoomInfo.name, oldInfo.basicRoomInfo.name)) {
            modifyFlagList.add(TUIConferenceListManager.ConferenceModifyFlag.ROOM_NAME);
        }
        if (newInfo.scheduleStartTime != oldInfo.scheduleStartTime) {
            modifyFlagList.add(TUIConferenceListManager.ConferenceModifyFlag.SCHEDULE_START_TIME);
        }
        if (newInfo.scheduleEndTime != oldInfo.scheduleEndTime) {
            modifyFlagList.add(TUIConferenceListManager.ConferenceModifyFlag.SCHEDULE_END_TIME);
        }
        Log.d(TAG, "updateConferenceInfo conferenceId=" + newInfo.basicRoomInfo.roomId);
        mConferenceListManager.updateConferenceInfo(newInfo.transferToEngineData(), modifyFlagList, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "updateConferenceInfo onSuccess");
                if (callback != null) {
                    callback.onSuccess();
                }
                addAttendeesByAdmin(newInfo, oldInfo);
                removeAttendeesByAdmin(newInfo, oldInfo);
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "updateConferenceInfo onError error=" + error + " message=" + message);
                if (callback != null) {
                    callback.onError(error, message);
                }
                addAttendeesByAdmin(newInfo, oldInfo);
                removeAttendeesByAdmin(newInfo, oldInfo);
            }
        });
    }

    private void addAttendeesByAdmin(ConferenceListState.ConferenceInfo newInfo, ConferenceListState.ConferenceInfo oldInfo) {
        List<UserState.UserInfo> newList = newInfo.hadScheduledAttendees.getList();
        List<UserState.UserInfo> oldList = oldInfo.hadScheduledAttendees.getList();
        List<String> userIdList = new LinkedList<>();
        for (UserState.UserInfo item : newList) {
            if (oldList.contains(item)) {
                continue;
            }
            userIdList.add(item.userId);
        }
        if (userIdList.isEmpty()) {
            return;
        }
        Log.d(TAG, "addAttendeesByAdmin conferenceId=" + newInfo.basicRoomInfo.roomId);
        mConferenceListManager.addAttendeesByAdmin(newInfo.basicRoomInfo.roomId, userIdList, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "addAttendeesByAdmin onSuccess");
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "addAttendeesByAdmin onError error=" + error + " message=" + message);
            }
        });
    }

    private void removeAttendeesByAdmin(ConferenceListState.ConferenceInfo newInfo, ConferenceListState.ConferenceInfo oldInfo) {
        List<UserState.UserInfo> newList = newInfo.hadScheduledAttendees.getList();
        List<UserState.UserInfo> oldList = oldInfo.hadScheduledAttendees.getList();
        List<String> userIdList = new LinkedList<>();
        for (UserState.UserInfo item : oldList) {
            if (newList.contains(item)) {
                continue;
            }
            userIdList.add(item.userId);
        }
        if (userIdList.isEmpty()) {
            return;
        }
        Log.d(TAG, "removeAttendeesByAdmin conferenceId=" + newInfo.basicRoomInfo.roomId);
        mConferenceListManager.removeAttendeesByAdmin(newInfo.basicRoomInfo.roomId, userIdList, new TUIRoomDefine.ActionCallback() {
            @Override
            public void onSuccess() {
                Log.d(TAG, "removeAttendeesByAdmin onSuccess");
            }

            @Override
            public void onError(TUICommonDefine.Error error, String message) {
                Log.d(TAG, "removeAttendeesByAdmin onError error=" + error + " message=" + message);
            }
        });
    }

    private static class ScheduledConferenceComparator implements Comparator<ConferenceListState.ConferenceInfo> {
        @Override
        public int compare(ConferenceListState.ConferenceInfo o1, ConferenceListState.ConferenceInfo o2) {
            if (o1 == null || o2 == null) {
                return -1;
            }
            int scheduleDiff = (int) (o1.scheduleStartTime - o2.scheduleStartTime);
            if (scheduleDiff != 0) {
                return scheduleDiff;
            }
            return (int) (o1.basicRoomInfo.createTime - o2.basicRoomInfo.createTime);
        }
    }
}
