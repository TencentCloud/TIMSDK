package com.tencent.qcloud.tuicore;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIServiceCallback;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service register and call
 */
class ServiceManager {
    private static final String TAG = ServiceManager.class.getSimpleName();

    private static class ServiceManagerHolder {
        private static final ServiceManager serviceManager = new ServiceManager();
    }

    public static ServiceManager getInstance() {
        return ServiceManagerHolder.serviceManager;
    }

    private final Map<String, ITUIService> serviceMap = new ConcurrentHashMap<>();

    private ServiceManager() {}

    public void registerService(String serviceName, ITUIService service) {
        Log.i(TAG, "registerService : " + serviceName + "  " + service);
        if (TextUtils.isEmpty(serviceName) || service == null) {
            return;
        }
        serviceMap.put(serviceName, service);
    }

    public void unregisterService(String serviceName) {
        Log.i(TAG, "unregisterService : " + serviceName);
        if (TextUtils.isEmpty(serviceName)) {
            return;
        }
        serviceMap.remove(serviceName);
    }

    public ITUIService getService(String serviceName) {
        Log.i(TAG, "getService : " + serviceName);
        if (TextUtils.isEmpty(serviceName)) {
            return null;
        }
        return serviceMap.get(serviceName);
    }

    public Object callService(String serviceName, String method, Map<String, Object> param) {
        Log.i(TAG, "callService : " + serviceName + " method : " + method);
        ITUIService service = serviceMap.get(serviceName);
        if (service != null) {
            return service.onCall(method, param);
        } else {
            Log.w(TAG, "can't find service : " + serviceName);
            return null;
        }
    }

    public Object callService(String serviceName, String method, Map<String, Object> param, TUIServiceCallback callback) {
        Log.i(TAG, "callService : " + serviceName + " method : " + method);
        ITUIService service = serviceMap.get(serviceName);
        if (service != null) {
            return service.onCall(method, param, callback);
        } else {
            Log.w(TAG, "can't find service : " + serviceName);
            return null;
        }
    }
}
