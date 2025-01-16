package com.tencent.qcloud.tuikit.tuichat.component.progress;

import android.text.TextUtils;
import android.util.Log;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import java.lang.ref.WeakReference;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

public class ProgressPresenter {
    private static final String TAG = "ProgressPresenter";

    public static final int MAX_PROGRESS = 100;
    public static final int MIN_PROGRESS = 0;

    private static final class ProgressPresenterHolder {
        private static final ProgressPresenter instance = new ProgressPresenter();
    }

    private final Map<String, List<WeakReference<ProgressListener>>> progressListenerMap = new ConcurrentHashMap<>();
    private final Map<String, Integer> progressMap = new ConcurrentHashMap<>();

    public static ProgressPresenter getInstance() {
        return ProgressPresenterHolder.instance;
    }

    private ProgressPresenter() {}

    public static void registerProgressListener(String progressId, ProgressListener listener) {
        Log.i(TAG, "registerProgressListener id : " + progressId + ", listener : " + listener);
        if (TextUtils.isEmpty(progressId) || listener == null) {
            return;
        }
        ProgressPresenter presenter = ProgressPresenter.getInstance();
        List<WeakReference<ProgressListener>> list = presenter.progressListenerMap.get(progressId);
        if (list == null) {
            list = new CopyOnWriteArrayList<>();
            presenter.progressListenerMap.put(progressId, list);
        }
        WeakReference<ProgressListener> weakReference = new WeakReference<>(listener);
        list.add(weakReference);
        Integer progress = presenter.progressMap.get(progressId);
        if (progress != null) {
            ThreadUtils.runOnUiThread(() -> listener.onProgress(progress));
        }
    }

    public static void updateProgress(String progressId, int progress) {
        ProgressPresenter presenter = ProgressPresenter.getInstance();
        presenter.progressMap.put(progressId, progress);
        List<WeakReference<ProgressListener>> referenceList = presenter.progressListenerMap.get(progressId);
        if (referenceList != null && !referenceList.isEmpty()) {
            Iterator<WeakReference<ProgressListener>> iterator = referenceList.listIterator();
            while (iterator.hasNext()) {
                WeakReference<ProgressListener> weakReference = iterator.next();
                ProgressListener listener = weakReference.get();
                if (listener != null) {
                    ThreadUtils.runOnUiThread(() -> listener.onProgress(progress));
                }
            }
        } else {
            presenter.progressListenerMap.remove(progressId);
        }
        if (progress == MAX_PROGRESS) {
            presenter.progressMap.remove(progressId);
        }
    }

    public static void unregisterProgressListener(String progressId, ProgressListener listener) {
        Log.i(TAG, "unregisterProgressListener id : " + progressId + ", listener : " + listener);
        ProgressPresenter presenter = ProgressPresenter.getInstance();
        presenter.progressMap.remove(progressId);
        if (TextUtils.isEmpty(progressId) || listener == null) {
            return;
        }

        List<WeakReference<ProgressListener>> list = presenter.progressListenerMap.get(progressId);
        if (list == null) {
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

    public static int getProgress(String progressId) {
        ProgressPresenter presenter = ProgressPresenter.getInstance();
        Integer progress = presenter.progressMap.get(progressId);
        if (progress != null) {
            return progress;
        }
        return MIN_PROGRESS;
    }

    public interface ProgressListener {
        void onProgress(int progress);
    }
}
