package com.tencent.qcloud.tuikit.tuicallkit.extensions.recents;

import android.app.Application;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.MutableLiveData;

import com.tencent.qcloud.tuikit.TUICommonDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallDefine.CallRecords;
import com.tencent.qcloud.tuikit.tuicallengine.TUICallEngine;

import java.util.ArrayList;
import java.util.List;

public class RecentCallsViewModel extends AndroidViewModel {
    private static final String TAG = "RecentCallsViewModel";

    private final MutableLiveData<List<CallRecords>> mCallHistoryLiveData = new MutableLiveData<>();
    private final MutableLiveData<List<CallRecords>> mCallMissedLiveData  = new MutableLiveData<>();

    public RecentCallsViewModel(@NonNull Application application) {
        super(application);
        mCallHistoryLiveData.setValue(new ArrayList<>());
        mCallMissedLiveData.setValue(new ArrayList<>());
    }

    public MutableLiveData<List<CallRecords>> getCallHistoryList() {
        return mCallHistoryLiveData;
    }

    public MutableLiveData<List<CallRecords>> getCallMissedList() {
        return mCallMissedLiveData;
    }

    public void queryRecentCalls(TUICallDefine.RecentCallsFilter filter) {
        TUICallEngine.createInstance(getApplication()).queryRecentCalls(filter, new TUICommonDefine.ValueCallback() {
            @Override
            public void onSuccess(Object data) {
                if (data == null || !(data instanceof List)) {
                    return;
                }
                List<CallRecords> queryList = (List<CallRecords>) data;
                if (filter != null && CallRecords.Result.Missed.equals(filter.result)) {
                    List<CallRecords> missList = mCallMissedLiveData.getValue();
                    if (missList != null) {
                        missList.removeAll(queryList);
                        missList.addAll(queryList);
                    }
                    mCallMissedLiveData.setValue(missList);
                } else {
                    List<CallRecords> historyList = mCallHistoryLiveData.getValue();
                    if (historyList != null) {
                        historyList.removeAll(queryList);
                        historyList.addAll(queryList);
                    }
                    mCallHistoryLiveData.setValue(historyList);
                }
            }

            @Override
            public void onError(int errCode, String errMsg) {
            }
        });
    }

    public void deleteRecordCalls(List<CallRecords> list) {
        if (list == null || list.isEmpty()) {
            return;
        }

        ArrayList<CallRecords> missList = new ArrayList<>(mCallMissedLiveData.getValue());
        missList.removeAll(list);
        mCallMissedLiveData.setValue(missList);

        List<CallRecords> allList = new ArrayList<>(mCallHistoryLiveData.getValue());
        allList.removeAll(list);
        mCallHistoryLiveData.setValue(allList);

        List<String> callIdList = new ArrayList<>();
        for (CallRecords record : list) {
            if (record != null && !TextUtils.isEmpty(record.callId)) {
                callIdList.add(record.callId);
            }
        }
        TUICallEngine.createInstance(getApplication()).deleteRecordCalls(callIdList,
                new TUICommonDefine.ValueCallback() {
                    @Override
                    public void onSuccess(Object data) {
                    }

                    @Override
                    public void onError(int errCode, String errMsg) {
                    }
                });
    }
}