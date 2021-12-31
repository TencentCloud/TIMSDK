package com.tencent.qcloud.tuicore;

import android.text.TextUtils;
import android.util.Log;

import com.tencent.qcloud.tuicore.interfaces.ITUIService;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service 注册和调用
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
}
