package com.tencent.qcloud.tuikit.tuichat.util;

import androidx.datastore.preferences.core.MutablePreferences;
import androidx.datastore.preferences.core.Preferences;
import androidx.datastore.preferences.core.PreferencesKeys;
import androidx.datastore.rxjava3.RxDataStore;

import com.google.gson.Gson;

import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;
import io.reactivex.rxjava3.core.Flowable;
import io.reactivex.rxjava3.core.Single;
import io.reactivex.rxjava3.disposables.Disposable;
import io.reactivex.rxjava3.functions.Consumer;
import io.reactivex.rxjava3.schedulers.Schedulers;

public class DataStoreUtil {
    private static final String TAG = DataStoreUtil.class.getSimpleName();

    private static DataStoreUtil instance;
    private RxDataStore<Preferences> dataStore = null;

    public static DataStoreUtil getInstance() {
        if (instance == null) {
            instance = new DataStoreUtil();
        }

        return instance;
    }

    private DataStoreUtil() {

    }

    public void setDataStore (RxDataStore<Preferences> dataStore) {
        this.dataStore = dataStore;
    }

    public  <T> T getValue(String key, Class<T> cls){
        if (dataStore == null) {
            TUIChatLog.e(TAG, "dataStore is null");
            return null;
        }
        Preferences.Key<String> dstKey = PreferencesKeys.stringKey(key);
        Flowable<String> currentFlow = dataStore.data().map(prefs -> prefs.get(dstKey));
        String content = currentFlow.blockingFirst();
        Gson gson = new Gson();
        T result = gson.fromJson(content, cls);
        return result;
    }

    public  <T> void getValueAsync(String key, GetResult<T> callback, Class<T> cls){
        if (dataStore == null) {
            TUIChatLog.e(TAG, "dataStore is null");
            callback.onFail();
            return;
        }
        Preferences.Key<String> dstKey = PreferencesKeys.stringKey(key);
        Flowable<String> currentFlow = dataStore.data().map(prefs -> prefs.get(dstKey));
        final DisponseHandler disponseHandler = new DisponseHandler();
        disponseHandler.disposable = currentFlow
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Consumer<String>() {
                    @Override
                    public void accept(String data) throws Throwable {
                        String content = currentFlow.blockingFirst();
                        Gson gson = new Gson();
                        T result = gson.fromJson(content, cls);
                        callback.onSuccess(result);
                        if (disponseHandler.disposable != null && !disponseHandler.disposable.isDisposed()){
                            disponseHandler.disposable.dispose();
                        }
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Throwable {
                        TUIChatLog.e(TAG, "dataStore throwable = " + throwable);
                        callback.onFail();
                        if (disponseHandler.disposable != null && !disponseHandler.disposable.isDisposed()){
                            disponseHandler.disposable.dispose();
                        }
                    }
                });

    }

    public <T> void putValue(String key, T value) {
        if (dataStore == null) {
            TUIChatLog.e(TAG, "dataStore is null");
            return;
        }

        Preferences.Key<String> dstKey = PreferencesKeys.stringKey(key);
        Single<Preferences> updateResult = dataStore.updateDataAsync(prefsIn -> {
            MutablePreferences mutablePreferences = prefsIn.toMutablePreferences();
            Gson gson = new Gson();
            String content = gson.toJson(value);
            mutablePreferences.set(dstKey, content);
            return Single.just(mutablePreferences);
        });
        updateResult.subscribe();
    }

    class DisponseHandler{
        Disposable disposable;
    }

    public interface GetResult<T> {
        void onSuccess(T result);

        void onFail();
    }
}
