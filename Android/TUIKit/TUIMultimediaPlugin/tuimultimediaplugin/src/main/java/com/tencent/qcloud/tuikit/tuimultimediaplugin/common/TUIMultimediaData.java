package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class TUIMultimediaData<T> {

    private static final Object DEFAULT_OBJECT = new Object();
    private final List<TUIMultimediaDataObserver<? super T>> mObservers = new ArrayList<>();
    private volatile Object mData;

    public TUIMultimediaData(T value) {
        mData = value;
    }

    public void observe(TUIMultimediaDataObserver<? super T> observer) {
        if (observer == null || mObservers.contains(observer)) {
            return;
        }
        mObservers.add(observer);
    }

    public void removeObserver(final TUIMultimediaDataObserver<? super T> observer) {
        mObservers.remove(observer);
    }

    public void set(T value) {
        mData = value;
        dispatchingValue();
    }

    public void add(Object item) {
        if (mData != null) {
            if (mData instanceof List) {
                ((List) mData).add(item);
                dispatchingValue();
            } else if (mData instanceof Set) {
                ((Set) mData).add(item);
                dispatchingValue();
            }
        }
    }

    public T get() {
        Object data = mData;
        if (data != DEFAULT_OBJECT) {
            return (T) data;
        }
        return null;
    }

    private void dispatchingValue() {
        for (int i = 0; i < mObservers.size(); i++) {
            mObservers.get(i).onChanged((T) mData);
        }
    }

    public interface TUIMultimediaDataObserver<T> {

        void onChanged(T t);
    }
}
