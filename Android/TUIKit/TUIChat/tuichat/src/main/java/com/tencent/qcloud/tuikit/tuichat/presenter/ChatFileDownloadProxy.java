package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IDownloadProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ChatFileDownloadProxy {
    private static final String TAG = "ChatFileDownloadProxy";
    private static final int MAX_RUNNING_TASKS_NUM = 2;
    private static final String TEMP_FILE_SUFFIX = "_temp";

    private static final ChatFileDownloadProxy instance = new ChatFileDownloadProxy();

    private final ExecutorService executorService;
    private final Map<Integer, List<WeakReference<TUIValueCallback>>> callbackMap;

    private ChatFileDownloadProxy() {
        callbackMap = Collections.synchronizedMap(new HashMap<>());
        BlockingQueue<Runnable> taskQueue = new LinkedBlockingQueue<>();
        executorService = new ThreadPoolExecutor(MAX_RUNNING_TASKS_NUM, MAX_RUNNING_TASKS_NUM, 0L, TimeUnit.MILLISECONDS, taskQueue);
    }

    private static ChatFileDownloadProxy getProxy() {
        return instance;
    }

    private static class DownloadTask extends Thread {

        public int taskID;
        public Object target;
        public Method method;
        private String path;

        @Override
        public void run() {
            try {
                String tempPath = path + TEMP_FILE_SUFFIX;
                File tempFile = new File(tempPath);
                if (tempFile.exists() && tempFile.isFile()) {
                    boolean success = tempFile.delete();
                    if (!success) {
                        TUIChatLog.e(TAG, String.format(Locale.US, "start download, delete temp file %s failed.", tempPath));
                    }
                }
                File tempFileParent = tempFile.getParentFile();
                if (tempFileParent != null && (!tempFileParent.exists() || !tempFileParent.isDirectory())) {
                    boolean success = tempFileParent.mkdirs();
                    if (!success) {
                        TUIChatLog.e(TAG, String.format(Locale.US, "mkdirs %s failed.", tempFileParent.getPath()));
                    }
                }
                TUIChatLog.i(TAG, String.format(Locale.US, "start download taskID %d, file %s ", taskID, tempFile));
                method.invoke(target, tempPath, new TUIValueCallback<String>() {
                    @Override
                    public void onSuccess(String object) {
                        File tempFile = new File(tempPath);
                        File originFile = new File(path);
                        if (originFile.exists() && originFile.isFile()) {
                            TUIChatLog.w(TAG, String.format(Locale.US, "file %s is exists.", path));
                            boolean success = originFile.delete();
                            if (!success) {
                                TUIChatLog.e(TAG, String.format(Locale.US, "delete origin file %s failed.", tempPath));
                            }
                        }
                        boolean success = tempFile.renameTo(originFile);
                        if (success) {
                            TUIChatLog.i(TAG, String.format(Locale.US, "download file %s success.", path));
                            callbackOnSuccess(taskID, path);
                        } else {
                            TUIChatLog.e(TAG, String.format(Locale.US, "download file %s failed, rename failed.", path));
                            callbackOnError(taskID, -1, "rename temp file failed.");
                        }
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                        TUIChatLog.e(TAG, String.format(Locale.US, "download file %s error %d, %s.", path, errorCode, errorMessage));
                        callbackOnError(taskID, errorCode, errorMessage);
                    }

                    @Override
                    public void onProgress(long current, long total) {
                        if (total <= 0) {
                            current = 0;
                            total = 1;
                        }
                        callbackOnProgress(taskID, current, total);
                    }
                });
            } catch (Exception e) {
                callbackOnError(taskID, -1, e.getMessage());
                TUIChatLog.e(TAG, String.format(Locale.US, "download file %s failed : " + e.getMessage(), path));
            }
        }
    }

    private static <T> void callbackOnSuccess(int taskID, T value) {
        ThreadUtils.runOnUiThread(() -> {
            List<WeakReference<TUIValueCallback>> callbackList = getProxy().callbackMap.get(taskID);
            removeTaskList(taskID);
            if (callbackList != null) {
                for (WeakReference<TUIValueCallback> callback : callbackList) {
                    if (callback != null && callback.get() != null) {
                        TUIValueCallback.onSuccess(callback.get(), value);
                    }
                }
            }
        });
    }

    private static void callbackOnError(int taskID, int errorCode, String errorMessage) {
        ThreadUtils.runOnUiThread(() -> {
            List<WeakReference<TUIValueCallback>> callbackList = getProxy().callbackMap.get(taskID);
            removeTaskList(taskID);
            if (callbackList != null) {
                for (WeakReference<TUIValueCallback> callback : callbackList) {
                    if (callback != null && callback.get() != null) {
                        TUIValueCallback.onError(callback.get(), errorCode, errorMessage);
                    }
                }
            }
        });
    }

    private static void callbackOnProgress(int taskID, long current, long total) {
        ThreadUtils.runOnUiThread(() -> {
            List<WeakReference<TUIValueCallback>> callbackList = getProxy().callbackMap.get(taskID);
            if (callbackList != null) {
                for (WeakReference<TUIValueCallback> callback : callbackList) {
                    if (callback != null && callback.get() != null) {
                        TUIValueCallback.onProgress(callback.get(), current, total);
                    }
                }
            }
        });
    }

    private static void addCallback(int taskID, TUIValueCallback callback) {
        if (callback == null) {
            return;
        }
        List<WeakReference<TUIValueCallback>> callbackList = getProxy().callbackMap.get(taskID);
        if (callbackList == null) {
            callbackList = new CopyOnWriteArrayList<>();
            getProxy().callbackMap.put(taskID, callbackList);
        }
        callbackList.add(new WeakReference<>(callback));
    }

    private static void removeTaskList(int taskID) {
        getProxy().callbackMap.remove(taskID);
    }

    private static boolean isDownloading(int taskID) {
        return getProxy().callbackMap.containsKey(taskID);
    }

    public static boolean isDownloading(String path) {
        if (TextUtils.isEmpty(path)) {
            return false;
        }
        return isDownloading(path.hashCode());
    }

    public static IDownloadProvider proxy(IDownloadProvider downloadBean) {
        try {
            if (downloadBean == null) {
                return null;
            }
            Class<? extends IDownloadProvider> clazz = downloadBean.getClass();
            return (IDownloadProvider) Proxy.newProxyInstance(clazz.getClassLoader(), clazz.getInterfaces(), new ChatDownloadInvocationHandler(downloadBean));
        } catch (Exception e) {
            TUIChatLog.e(TAG, "generate proxy failed " + e.getMessage());
            return downloadBean;
        }
    }

    private static class ChatDownloadInvocationHandler implements InvocationHandler {
        private final Object target;

        public ChatDownloadInvocationHandler(Object target) {
            this.target = target;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            if (target == null) {
                return null;
            }

            Class<?>[] paramsTypes = method.getParameterTypes();
            if (paramsTypes.length == 2) {
                if (!paramsTypes[0].isAssignableFrom(String.class) || !paramsTypes[1].isAssignableFrom(TUIValueCallback.class)) {
                    return method.invoke(target, args);
                }
            } else {
                return method.invoke(target, args);
            }
            String path = (String) args[0];
            if (TextUtils.isEmpty(path)) {
                TUIChatLog.e(TAG, "download failed, path is empty.");
                return null;
            }
            int taskID = path.hashCode();
            TUIValueCallback<String> callback = (TUIValueCallback) args[1];
            if (isDownloading(taskID)) {
                addCallback(taskID, callback);
                TUIChatLog.i(TAG, String.format(Locale.US, "download task %d is running.", taskID));
                return null;
            }
            DownloadTask downloadTask = new DownloadTask();
            downloadTask.target = target;
            downloadTask.method = method;
            downloadTask.taskID = taskID;
            downloadTask.path = path;
            addCallback(taskID, callback);
            getProxy().executorService.submit(downloadTask);
            return null;
        }
    }
}
