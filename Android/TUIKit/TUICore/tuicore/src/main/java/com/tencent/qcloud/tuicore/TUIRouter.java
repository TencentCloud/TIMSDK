package com.tencent.qcloud.tuicore;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
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
import android.util.Pair;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultCaller;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContract;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

/**
 * For Activity routing jump, only used inside TUICore, not exposed to the outside
 */
class TUIRouter {
    private static final String TAG = TUIRouter.class.getSimpleName();

    private static final TUIRouter router = new TUIRouter();

    public static TUIRouter getInstance() {
        return router;
    }

    private static final Map<String, String> routerMap = new HashMap<>();

    private static final Map<ActivityResultCaller, ActivityResultLauncher<Pair<Intent, ActivityResultCallback<ActivityResult>>>> activityResultLauncherMap =
        new WeakHashMap<>();

    @SuppressLint("StaticFieldLeak") private static Context context;

    private static boolean initialized = false;

    private TUIRouter() {}

    public static synchronized void init(Context context) {
        if (initialized) {
            return;
        }
        TUIRouter.context = context;
        if (context == null) {
            Log.e(TAG, "init failed, context is null.");
            return;
        }
        initRouter(context);
        initActivityResultLauncher(context);
        initialized = true;
    }

    static class RouterActivityResultContract
        extends ActivityResultContract<Pair<Intent, ActivityResultCallback<ActivityResult>>, Pair<ActivityResult, ActivityResultCallback<ActivityResult>>> {
        private ActivityResultCallback<ActivityResult> callback;

        @NonNull
        @Override
        public Intent createIntent(@NonNull Context context, Pair<Intent, ActivityResultCallback<ActivityResult>> input) {
            callback = input.second;
            return input.first;
        }

        @Override
        public Pair<ActivityResult, ActivityResultCallback<ActivityResult>> parseResult(int resultCode, @Nullable Intent intent) {
            Pair<ActivityResult, ActivityResultCallback<ActivityResult>> pair = Pair.create(new ActivityResult(resultCode, intent), callback);
            callback = null;
            return pair;
        }
    }

    static class RouterActivityResultCallback implements ActivityResultCallback<Pair<ActivityResult, ActivityResultCallback<ActivityResult>>> {
        @Override
        public void onActivityResult(Pair<ActivityResult, ActivityResultCallback<ActivityResult>> resultCallbackPair) {
            if (resultCallbackPair.second != null) {
                resultCallbackPair.second.onActivityResult(resultCallbackPair.first);
            }
        }
    }

    private static void initActivityResultLauncher(Context context) {
        if (context instanceof Application) {
            ((Application) context).registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
                @Override
                public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
                    if (activity instanceof ActivityResultCaller) {
                        registerForActivityResult((ActivityResultCaller) activity);
                        if (activity instanceof FragmentActivity) {
                            ((FragmentActivity) activity)
                                .getSupportFragmentManager()
                                .registerFragmentLifecycleCallbacks(new FragmentManager.FragmentLifecycleCallbacks() {
                                    @Override
                                    public void onFragmentCreated(
                                        @NonNull FragmentManager fragmentManager, @NonNull Fragment fragment, @Nullable Bundle savedInstanceState) {
                                        registerForActivityResult(fragment);
                                    }

                                    @Override
                                    public void onFragmentDestroyed(@NonNull FragmentManager fm, @NonNull Fragment fragment) {
                                        clearLauncher(fragment);
                                    }
                                }, true);
                        }
                    }
                }

                private void registerForActivityResult(ActivityResultCaller resultCaller) {
                    ActivityResultLauncher<Pair<Intent, ActivityResultCallback<ActivityResult>>> activityFragmentResultLauncher =
                        resultCaller.registerForActivityResult(new RouterActivityResultContract(), new RouterActivityResultCallback());
                    activityResultLauncherMap.put(resultCaller, activityFragmentResultLauncher);
                }

                private void clearLauncher(ActivityResultCaller resultCaller) {
                    activityResultLauncherMap.remove(resultCaller);
                }

                @Override
                public void onActivityStarted(@NonNull Activity activity) {}

                @Override
                public void onActivityResumed(@NonNull Activity activity) {}

                @Override
                public void onActivityPaused(@NonNull Activity activity) {}

                @Override
                public void onActivityStopped(@NonNull Activity activity) {}

                @Override
                public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {}

                @Override
                public void onActivityDestroyed(@NonNull Activity activity) {
                    if (activity instanceof ActivityResultCaller) {
                        clearLauncher((ActivityResultCaller) activity);
                    }
                }
            });
        }
    }

    public Navigation setDestination(String path) {
        Navigation navigation = new Navigation();
        navigation.setDestination(path);
        return navigation;
    }

    public Navigation setDestination(Class<? extends Activity> activityClazz) {
        Navigation navigation = new Navigation();
        navigation.setDestination(activityClazz);
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

        public Navigation setDestination(Class<? extends Activity> activityClazz) {
            intent.setComponent(new ComponentName(TUIRouter.context, activityClazz));
            return this;
        }

        public Navigation setIntent(Intent intent) {
            this.intent = intent;
            return this;
        }

        public Intent getIntent() {
            return this.intent;
        }

        public void navigate() {
            navigate((Context) null);
        }

        public void navigate(Context context) {
            navigate(context, -1);
        }

        public void navigate(Fragment fragment) {
            navigate(fragment, -1);
        }

        @Deprecated
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

        public void navigate(ActivityResultCaller caller, ActivityResultCallback<ActivityResult> callback) {
            if (!initialized) {
                Log.e(TAG, "have not initialized.");
                return;
            }
            if (intent == null) {
                Log.e(TAG, "intent is null.");
                return;
            }
            try {
                ActivityResultLauncher<Pair<Intent, ActivityResultCallback<ActivityResult>>> launcher = activityResultLauncherMap.get(caller);
                if (launcher != null) {
                    launcher.launch(Pair.create(intent, callback));
                }
            } catch (Exception e) {
                Log.e(TAG, "start activity failed, " + e.getLocalizedMessage());
            }
        }

        @Deprecated
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

    public static void startActivityForResult(
        @Nullable ActivityResultCaller caller, String activityName, Bundle param, ActivityResultCallback<ActivityResult> resultCallback) {
        Navigation navigation = TUIRouter.getInstance().setDestination(activityName).putExtras(param);
        navigation.navigate(caller, resultCallback);
    }

    public static void startActivityForResult(
        @Nullable ActivityResultCaller caller, Class<? extends Activity> activityClazz, Bundle param, ActivityResultCallback<ActivityResult> resultCallback) {
        Navigation navigation = TUIRouter.getInstance().setDestination(activityClazz).putExtras(param);
        navigation.navigate(caller, resultCallback);
    }

    public static void startActivityForResult(@Nullable ActivityResultCaller caller, Intent intent, ActivityResultCallback<ActivityResult> resultCallback) {
        Navigation navigation = new Navigation();
        navigation.setIntent(intent);
        navigation.navigate(caller, resultCallback);
    }

    /**
     * use {@link #startActivityForResult}
     */
    @Deprecated
    public static void startActivity(@Nullable Object starter, String activityName, Bundle param, int requestCode) {
        TUIRouter.Navigation navigation = TUIRouter.getInstance().setDestination(activityName).putExtras(param);
        if (starter instanceof Fragment) {
            navigation.navigate((Fragment) starter, requestCode);
        } else if (starter instanceof Context) {
            navigation.navigate((Context) starter, requestCode);
        } else {
            navigation.navigate((Context) null, requestCode);
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