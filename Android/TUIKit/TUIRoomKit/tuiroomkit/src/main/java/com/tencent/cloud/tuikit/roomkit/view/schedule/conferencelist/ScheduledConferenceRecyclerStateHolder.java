package com.tencent.cloud.tuikit.roomkit.view.schedule.conferencelist;

import android.content.Context;
import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.extension.TUIConferenceListManager;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.manager.ScheduleController;
import com.tencent.cloud.tuikit.roomkit.state.ConferenceListState;
import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.livedata.LiveListData;
import com.trtc.tuikit.common.livedata.LiveListObserver;

import java.util.Calendar;
import java.util.List;
import java.util.Locale;

public class ScheduledConferenceRecyclerStateHolder {
    private final static String                                FORMAT_DATE              = "%d%s%d%s%d%s";
    public final         LiveListData<ScheduledConferenceItem> mScheduledConferenceData = new LiveListData<>();

    private final LiveListObserver<ConferenceListState.ConferenceInfo> mConferencesObserver = new LiveListObserver<ConferenceListState.ConferenceInfo>() {
        @Override
        public void onDataChanged(List<ConferenceListState.ConferenceInfo> list) {
            mScheduledConferenceData.clear();
            int size = list.size();
            for (int i = 0; i < size; i++) {
                handleItemInserted(list.get(i));
            }
        }

        @Override
        public void onItemChanged(int position, ConferenceListState.ConferenceInfo item) {
            ScheduledConferenceItem scheduledConferenceItem = transferToDataItem(item);
            mScheduledConferenceData.change(scheduledConferenceItem);
        }

        @Override
        public void onItemInserted(int position, ConferenceListState.ConferenceInfo item) {
            handleItemInserted(item);
        }

        @Override
        public void onItemRemoved(int position, ConferenceListState.ConferenceInfo item) {
            handleItemRemoved(item);
        }

        @Override
        public void onItemMoved(int fromPosition, int toPosition, ConferenceListState.ConferenceInfo item) {
            handleItemRemoved(item);
            handleItemInserted(item);
        }

        private void handleItemInserted(ConferenceListState.ConferenceInfo item) {
            String expectedHeader = transferToHeader(item.scheduleStartTime);
            List<ScheduledConferenceItem> list = mScheduledConferenceData.getList();
            boolean isHeaderMatched = false;
            int size = list.size();
            int index = 0;
            for (; index < size; index++) {
                ScheduledConferenceItem scheduledConferenceItem = list.get(index);
                if (scheduledConferenceItem.getType() == ScheduledConferenceItem.TYPE_CONFERENCE_HEADER) {
                    if (TextUtils.equals(expectedHeader, (String) scheduledConferenceItem.getData())) {
                        isHeaderMatched = true;
                    }
                    continue;
                }
                ScheduledConferenceItemInfo info = (ScheduledConferenceItemInfo) scheduledConferenceItem.getData();
                if (item.scheduleStartTime >= info.scheduleStartTime) {
                    continue;
                }
                String insertedItemHeader = transferToHeader(info.scheduleStartTime);
                if (!TextUtils.equals(expectedHeader, insertedItemHeader)) {
                    index--;
                }
                break;
            }

            mScheduledConferenceData.insert(index, transferToDataItem(item));
            if (!isHeaderMatched) {
                mScheduledConferenceData.insert(index, transferToHeaderItem(item));
            }
        }

        private void handleItemRemoved(ConferenceListState.ConferenceInfo item) {
            int index = mScheduledConferenceData.indexOf(transferToDataItem(item));
            if (index == -1) {
                return;
            }
            mScheduledConferenceData.remove(index);
            int preItemIndex = index - 1;
            ScheduledConferenceItem preItem = mScheduledConferenceData.get(preItemIndex);
            if (preItem.getType() == ScheduledConferenceItem.TYPE_CONFERENCE_INFO) {
                return;
            }
            if (index >= mScheduledConferenceData.size()) {
                mScheduledConferenceData.remove(preItemIndex);
                return;
            }
            ScheduledConferenceItem nextItem = mScheduledConferenceData.get(index);
            if (nextItem.getType() == ScheduledConferenceItem.TYPE_CONFERENCE_HEADER) {
                mScheduledConferenceData.remove(preItemIndex);
                return;
            }
            ScheduledConferenceItemInfo nextInfo = (ScheduledConferenceItemInfo) nextItem.getData();
            String nextItemExpectedHeader = transferToHeader(nextInfo.scheduleStartTime);
            String preHeader = (String) preItem.getData();
            if (TextUtils.equals(nextItemExpectedHeader, preHeader)) {
                return;
            }
            mScheduledConferenceData.remove(preItemIndex);
        }
    };

    public void observer(LiveListObserver<ScheduledConferenceItem> observer) {
        mScheduledConferenceData.observe(observer);
        ScheduleController.sharedInstance().getConferenceListState().scheduledConferences.observe(mConferencesObserver);
    }

    public void removeObserver(LiveListObserver<ScheduledConferenceItem> observer) {
        mScheduledConferenceData.removeObserver(observer);
        ScheduleController.sharedInstance().getConferenceListState().scheduledConferences.removeObserver(mConferencesObserver);
    }

    private ScheduledConferenceItem transferToHeaderItem(ConferenceListState.ConferenceInfo conferenceInfo) {
        String dateTitle = transferToHeader(conferenceInfo.scheduleStartTime);
        return new ScheduledConferenceItem(ScheduledConferenceItem.TYPE_CONFERENCE_HEADER, dateTitle);
    }

    private ScheduledConferenceItem transferToDataItem(ConferenceListState.ConferenceInfo conferenceInfo) {
        ScheduledConferenceItemInfo info = new ScheduledConferenceItemInfo();
        info.conferenceName = conferenceInfo.basicRoomInfo.name;
        info.id = conferenceInfo.basicRoomInfo.roomId;
        info.scheduleStartTime = conferenceInfo.scheduleStartTime;
        info.scheduledEndTime = conferenceInfo.scheduleEndTime;
        info.status = transConferenceStatusToString(conferenceInfo.status);
        return new ScheduledConferenceItem(ScheduledConferenceItem.TYPE_CONFERENCE_INFO, info);
    }

    private String transConferenceStatusToString(TUIConferenceListManager.ConferenceStatus status) {
        Context context = TUILogin.getAppContext();
        switch (status) {
            case RUNNING:
                return context.getString(R.string.tuiroomkit_conference_status_running);
            default:
                return "";
        }
    }

    private String transferToHeader(long startTime) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(startTime);
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int day = calendar.get(Calendar.DAY_OF_MONTH);
        Context context = TUILogin.getAppContext();
        return String.format(Locale.getDefault(), FORMAT_DATE, year, context.getString(R.string.tuiroomkit_year_text), month, context.getString(R.string.tuiroomkit_month_text), day, context.getString(R.string.tuiroomkit_day_text));
    }

}
