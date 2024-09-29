package com.tencent.qcloud.tuikit.tuichat.util;

import androidx.datastore.preferences.core.MutablePreferences;
import androidx.datastore.preferences.core.Preferences;
import androidx.datastore.preferences.core.PreferencesKeys;
import androidx.datastore.preferences.rxjava3.RxPreferenceDataStoreBuilder;
import androidx.datastore.rxjava3.RxDataStore;
import com.google.gson.Gson;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;
import io.reactivex.rxjava3.core.Flowable;
import io.reactivex.rxjava3.core.Single;
import io.reactivex.rxjava3.disposables.Disposable;
import io.reactivex.rxjava3.functions.Consumer;
import io.reactivex.rxjava3.schedulers.Schedulers;

public class DataStoreUtil {
    private static final String TAG = DataStoreUtil.class.getSimpleName();

    private static final DataStoreUtil instance = new DataStoreUtil();
    private RxDataStore<Preferences> dataStore =
        new RxPreferenceDataStoreBuilder(TUIChatService.getAppContext(), TUIChatConstants.DataStore.DATA_STORE_NAME).build();

    public static DataStoreUtil getInstance() {
        return instance;
    }

    private DataStoreUtil() {}

    public <T> T getValue(String key, Class<T> cls) {
        Preferences.Key<String> dstKey = PreferencesKeys.stringKey(key);
        Flowable<String> currentFlow = dataStore.data().map(prefs -> prefs.get(dstKey));
        String content = currentFlow.blockingFirst();
        Gson gson = new Gson();
        return gson.fromJson(content, cls);
    }

    public <T> void getValueAsync(String key, GetResult<T> callback, Class<T> cls) {
        Preferences.Key<String> dstKey = PreferencesKeys.stringKey(key);
        Flowable<String> currentFlow = dataStore.data().map(prefs -> prefs.get(dstKey));
        final DisposableHandler disposableHandler = new DisposableHandler();
        disposableHandler.disposable = currentFlow.subscribeOn(Schedulers.io())
                                         .observeOn(AndroidSchedulers.mainThread())
                                         .subscribe(
                                             new Consumer<String>() {
                                                 @Override
                                                 public void accept(String data) throws Throwable {
                                                     String content = currentFlow.blockingFirst();
                                                     Gson gson = new Gson();
                                                     T result = gson.fromJson(content, cls);
                                                     callback.onSuccess(result);
                                                     if (disposableHandler.disposable != null && !disposableHandler.disposable.isDisposed()) {
                                                         disposableHandler.disposable.dispose();
                                                     }
                                                 }
                                             },
                                             new Consumer<Throwable>() {
                                                 @Override
                                                 public void accept(Throwable throwable) {
                                                     callback.onFail();
                                                     if (disposableHandler.disposable != null && !disposableHandler.disposable.isDisposed()) {
                                                         disposableHandler.disposable.dispose();
                                                     }
                                                 }
                                             });
    }

    public <T> void putValue(String key, T value) {
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

    static class DisposableHandler {
        Disposable disposable;
    }

    public interface GetResult<T> {
        void onSuccess(T result);

        void onFail();
    }
}
