package com.tencent.cloud.tuikit.roomkit.common.livedata;

import androidx.annotation.NonNull;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class LiveListData<T> {
    private List<T>                   mList;
    private List<LiveListObserver<T>> mObservers = new CopyOnWriteArrayList<>();

    public LiveListData() {
        mList = new LinkedList<>();
    }

    public LiveListData(@NonNull List<T> list) {
        mList = list;
    }

    public List<T> getList() {
        return mList;
    }

    public void observe(LiveListObserver<T> observer) {
        if (observer == null || mObservers.contains(observer)) {
            return;
        }
        mObservers.add(observer);
        observer.onDataChanged(mList);
    }

    public void removeObserver(final LiveListObserver<T> observer) {
        mObservers.remove(observer);
    }

    public void add(T item) {
        insert(mList.size(), item);
    }

    public void insert(int position, T item) {
        if (mList.contains(item)) {
            return;
        }
        mList.add(position, item);
        for (int i = 0; i < mObservers.size(); i++) {
            mObservers.get(i).onItemInserted(position, item);
        }
    }

    public T remove(T item) {
        int position = mList.indexOf(item);
        if (position == -1) {
            return null;
        }
        return remove(position);
    }

    public T remove(int position) {
        T item = mList.remove(position);
        for (int i = 0; i < mObservers.size(); i++) {
            mObservers.get(i).onItemRemoved(position, item);
        }
        return item;
    }

    public void clear() {
        mList.clear();
        for (int i = 0; i < mObservers.size(); i++) {
            mObservers.get(i).onDataChanged(mList);
        }
    }

    public void replace(List<T> list) {
        mList.clear();
        mList.addAll(list);
        for (int i = 0; i < mObservers.size(); i++) {
            mObservers.get(i).onDataChanged(mList);
        }
    }

    public void change(T item) {
        int index = mList.indexOf(item);
        if (index == -1) {
            return;
        }
        mList.set(index, item);
        for (int i = 0; i < mObservers.size(); i++) {
            mObservers.get(i).onItemChanged(index, item);
        }
    }

    public void move(int fromPosition, int toPosition) {
        if (fromPosition == toPosition) {
            return;
        }
        T item = mList.remove(fromPosition);
        mList.add(toPosition, item);

        for (int i = 0; i < mObservers.size(); i++) {
            mObservers.get(i).onItemMoved(fromPosition, toPosition, item);
        }
    }

    public boolean contains(T item) {
        return mList.contains(item);
    }

    public int indexOf(T item) {
        return mList.indexOf(item);
    }

    public T find(T item) {
        int index = mList.indexOf(item);
        if (index == -1) {
            return null;
        }
        return mList.get(index);
    }

    public T get(int position) {
        return mList.get(position);
    }

    public int size() {
        return mList.size();
    }
}
