package com.tencent.qcloud.tuikit.tuicontact.presenter;

import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.model.ContactProvider;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;
import com.tencent.qcloud.tuikit.tuicontact.util.TUIContactLog;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.LinkedBlockingDeque;

/**
 * A get user status task queue which has a limit frequency mechanism
 * 具有接口调用限频机制的获取用户状态的任务队列
 */
public class GetUserStatusHelper {
    private static final String TAG = "GetUserStatusHelper";
    private static final GetUserStatusHelper instance = new GetUserStatusHelper();

    private static final int MAX_USER_LIMIT = 500;
    private static final int INTERFACE_CALL_PERIOD = 1000; // 1s

    private final ContactProvider provider;
    private final LinkedBlockingDeque<GetUserStatusTask> taskQueue;
    private Thread getUserStatusThread;

    private GetUserStatusHelper() {
        provider = new ContactProvider();
        taskQueue = new LinkedBlockingDeque<>();
    }

    public static void enqueue(GetUserStatusTask task) {
        TUIContactLog.i(TAG, "GetUserStatusTask enqueue " + task);
        instance.taskQueue.offerFirst(task);
        instance.execute();
    }

    private synchronized void execute() {
        if (getUserStatusThread == null) {
            getUserStatusThread = new Thread("GetUserStatusThread") {
                @Override
                public void run() {
                    while (true) {
                        GetUserStatusTask task = taskQueue.poll();
                        if (task == null) {
                            getUserStatusThread = null;
                            return;
                        }
                        if (!task.isNeedRequest()) {
                            continue;
                        }

                        List<ContactItemBean> dataList;
                        if (task.data == null || task.data.size() <= MAX_USER_LIMIT) {
                            dataList = task.data;
                        } else {
                            dataList = task.data.subList(0, MAX_USER_LIMIT);
                            task.data = task.data.subList(MAX_USER_LIMIT, task.data.size());
                            taskQueue.offerFirst(task);
                        }
                        provider.loadContactUserStatus(dataList, new IUIKitCallback<Void>() {
                            // callback run on ui thread
                            @Override
                            public void onSuccess(Void data) {
                                task.callbackSuccess();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                task.callbackError(errCode, errMsg);
                            }
                        });

                        try {
                            Thread.sleep(INTERFACE_CALL_PERIOD);
                        } catch (InterruptedException e) {
                            return;
                        }
                    }
                }
            };
            ThreadUtils.execute(getUserStatusThread);
        }
    }

    public static class GetUserStatusTask {
        private List<ContactItemBean> data;
        // Avoid memory leaks
        private WeakReference<IUIKitCallback<Void>> callbackWeakReference;

        // if callback exists
        private boolean isNeedRequest() {
            return callbackWeakReference != null && callbackWeakReference.get() != null;
        }

        // run on ui thread
        private void callbackSuccess() {
            if (callbackWeakReference != null) {
                IUIKitCallback<Void> callback = callbackWeakReference.get();
                ContactUtils.callbackOnSuccess(callback, null);
            }
        }

        // run on ui thread
        private void callbackError(int errCode, String errMsg) {
            if (callbackWeakReference != null) {
                IUIKitCallback<Void> callback = callbackWeakReference.get();
                ContactUtils.callbackOnError(callback, errCode, errMsg);
            }
        }

        public void setLoadedData(List<ContactItemBean> loadedData) {
            this.data = new ArrayList<>(loadedData);
        }

        public void setCallback(IUIKitCallback<Void> callback) {
            this.callbackWeakReference = new WeakReference<>(callback);
        }
    }
}
