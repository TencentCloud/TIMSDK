package com.tencent.qcloud.tuikit.tuichat.component.progress;

import android.text.TextUtils;
import android.util.Log;

import java.lang.ref.WeakReference;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

public class ProgressPresenter {
    private static final String TAG = ProgressPresenter.class.getSimpleName();

    private static final class ProgressPresenterHolder {
        private static final ProgressPresenter instance = new ProgressPresenter();
    }

    private final Map<String, List<WeakReference<ProgressListener>>> progressListenerMap = new ConcurrentHashMap<>();

    public static ProgressPresenter getInstance() {
        return ProgressPresenterHolder.instance;
    }

    private ProgressPresenter() {}

    public void registerProgressListener(String progressId, ProgressListener listener) {
        Log.i(TAG, "registerProgressListener id : " + progressId + ", listener : " + listener);
        if (TextUtils.isEmpty(progressId) || listener == null) {
            return;
        }

        List<WeakReference<ProgressListener>> list = progressListenerMap.get(progressId);
        if (list == null) {
            list = new CopyOnWriteArrayList<>();
            progressListenerMap.put(progressId, list);
        }
        WeakReference<ProgressListener> weakReference = new WeakReference<>(listener);
        list.add(weakReference);
    }

    public void updateProgress(String progressId, int progress) {

        List<WeakReference<ProgressListener>> referenceList = progressListenerMap.get(progressId);
        if (referenceList != null && !referenceList.isEmpty()) {
            Iterator<WeakReference<ProgressListener>> iterator = referenceList.listIterator();
            while (iterator.hasNext()) {
                WeakReference<ProgressListener> weakReference = iterator.next();
                ProgressListener listener = weakReference.get();
                if (listener != null) {
                    listener.onProgress(progress);
                }
            }
        } else {
            progressListenerMap.remove(progressId);
        }
    }

    public void unregisterProgressListener(String progressId, ProgressListener listener) {
        Log.i(TAG, "unregisterProgressListener id : " + progressId + ", listener : " + listener);
        if (TextUtils.isEmpty(progressId) || listener == null) {
            return;
        }

        List<WeakReference<ProgressListener>> list = progressListenerMap.get(progressId);
        if (list != null) {
            return;
        }
        WeakReference<ProgressListener> remove = null;
        for (WeakReference<ProgressListener> reference : list) {
            if (reference.get() == listener) {
                remove = reference;
                break;
            }
        }
        list.remove(remove);
    }

    public interface ProgressListener {
        void onProgress(int progress);
    }
}
