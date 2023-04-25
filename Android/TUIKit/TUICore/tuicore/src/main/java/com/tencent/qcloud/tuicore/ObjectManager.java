package com.tencent.qcloud.tuicore;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.interfaces.ITUIObjectFactory;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Object register and create
 */
class ObjectManager {
    private static final String TAG = ObjectManager.class.getSimpleName();

    private static class ObjectManagerHolder {
        private static final ObjectManager serviceManager = new ObjectManager();
    }

    public static ObjectManager getInstance() {
        return ObjectManagerHolder.serviceManager;
    }

    private final Map<String, ITUIObjectFactory> objectFactoryMap = new ConcurrentHashMap<>();

    private ObjectManager() {}

    public void registerObjectFactory(String factoryName, ITUIObjectFactory objectFactory) {
        Log.i(TAG, "registerObjectFactory : " + factoryName + "  " + objectFactory);
        if (TextUtils.isEmpty(factoryName) || objectFactory == null) {
            return;
        }
        objectFactoryMap.put(factoryName, objectFactory);
    }

    public void unregisterObjectFactory(String factoryName) {
        Log.i(TAG, "unregisterObjectFactory : " + factoryName);
        if (TextUtils.isEmpty(factoryName)) {
            return;
        }
        objectFactoryMap.remove(factoryName);
    }

    public Object createObject(String factoryName, String objectName, Map<String, Object> param) {
        Log.i(TAG, "createObject : " + factoryName + " objectName : " + objectName);
        if (TextUtils.isEmpty(factoryName)) {
            return null;
        }
        ITUIObjectFactory objectFactory = objectFactoryMap.get(factoryName);
        if (objectFactory != null) {
            return objectFactory.onCreateObject(objectName, param);
        } else {
            Log.w(TAG, "can't find objectFactory : " + factoryName);
            return null;
        }
    }
}
