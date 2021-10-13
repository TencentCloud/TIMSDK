package com.tencent.qcloud.tuicore;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Parcelable;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 实现 Activity 路由跳转，只在 TUICore 内部使用，不对外暴露
 */
class TUIRouter {
    private static final String TAG = TUIRouter.class.getSimpleName();

    private static final TUIRouter router = new TUIRouter();

    public static TUIRouter getInstance() {
        return router;
    }

    private static final Map<String, String> routerMap = new HashMap<>();

    private static Context context;

    private static boolean initialized = false;

    private TUIRouter() {
    }

    public synchronized static void init(Context context) {
        if (initialized) {
            return;
        }
        TUIRouter.context = context;
        if (context == null) {
            Log.e(TAG, "init failed, context is null.");
            return;
        }
        initRouter(context);
        initialized = true;
    }

    public Navigation setDestination(String path) {
        Navigation navigation = new Navigation();
        navigation.setDestination(path);
        return navigation;
    }

    static class Navigation {
        String destination;
        Bundle options;
        Intent intent = new Intent();

        public Navigation setOptions(Bundle options) {
            this.options = options;
            return this;
        }

        public Navigation putExtra(String key, boolean value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, byte value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, char value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, short value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, int value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, long value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, float value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, double value) {
            intent.putExtra(key, value);
            return this;
        }

        public Navigation putExtra(String key, String value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, CharSequence value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, Parcelable value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, Parcelable[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, Serializable value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, boolean[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, byte[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, short[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, char[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, int[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, long[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, float[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, double[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, String[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, CharSequence[] value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtra(String key, Bundle value) {
            if (value != null) {
                intent.putExtra(key, value);
            }
            return this;
        }

        public Navigation putExtras(Bundle bundle) {
            if (bundle != null) {
                intent.putExtras(bundle);
            }
            return this;
        }

        public Navigation putExtras(Intent src) {
            if (src != null) {
                intent.putExtras(src);
            }
            return this;
        }

        public Navigation setDestination(String path) {
            destination = routerMap.get(path);
            if (destination == null) {
                Log.e(TAG, "destination is null.");
                return this;
            }
            intent.setComponent(new ComponentName(TUIRouter.context, destination));
            return this;
        }

        public Navigation setIntent(Intent intent) {
            this.intent = intent;
            return this;
        }

        public Intent getIntent() {
            return this.intent;
        }

        // 使用默认的 ApplicationContext 启动 Activity
        public void navigate() {
            navigate((Context) null);
        }

        // 使用传入的 Context 启动 Activity
        public void navigate(Context context) {
            navigate(context, -1);
        }

        // 使用传入的 Fragment 启动 Activity
        public void navigate(Fragment fragment) {
            navigate(fragment, -1);
        }

        // 使用传入的 Fragment 启动 Activity，并返回接收返回结果
        public void navigate(Fragment fragment, int requestCode) {
            if (!initialized) {
                Log.e(TAG, "have not initialized.");
                return;
            }
            if (intent == null) {
                Log.e(TAG, "intent is null.");
                return;
            }
            try {
                if (fragment != null) {
                    if (requestCode >= 0) {
                        fragment.startActivityForResult(intent, requestCode);
                    } else {
                        fragment.startActivity(intent, options);
                    }
                } else {
                    startActivity(null, requestCode);
                }
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
            }
        }

        // 使用传入的 Context 启动 Activity，并返回接收返回结果
        public void navigate(Context context, int requestCode) {
            if (!initialized) {
                Log.e(TAG, "have not initialized.");
                return;
            }
            if (intent == null) {
                Log.e(TAG, "intent is null.");
                return;
            }
            Context startContext = context;
            if (context == null) {
                startContext = TUIRouter.context;
            }
            startActivity(startContext, requestCode);
        }

        private void startActivity(Context context, int requestCode) {
            if (context == null) {
                Log.e(TAG, "StartActivity failed, context is null.Please init");
                return;
            }
            try {
                if (context instanceof Activity && requestCode >= 0) {
                    ActivityCompat.startActivityForResult((Activity) context, intent, requestCode, options);
                } else {
                    if (!(context instanceof Activity)) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    }
                    ActivityCompat.startActivity(context, intent, options);
                }
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
            }
        }
    }


    public static void initRouter(Context context) {
        ActivityInfo[] activityInfos = null;
        List<String> activityNames = new ArrayList<>();
        PackageManager packageManager = context.getPackageManager();
        try {
            PackageInfo packageInfo = packageManager.getPackageInfo(context.getPackageName(), PackageManager.GET_ACTIVITIES);
            activityInfos = packageInfo.activities;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        if (activityInfos != null) {
            for (ActivityInfo activityInfo : activityInfos) {
                activityNames.add(activityInfo.name);
            }
        }
        for (String activityName : activityNames) {
            String[] splitStr = activityName.split("\\.");
            routerMap.put(splitStr[splitStr.length - 1], activityName);
        }
    }

    public static Context getContext() {
        return context;
    }
}