package com.tencent.qcloud.tuicore;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.TypedValue;
import android.webkit.WebView;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.interfaces.ITUIThemeChangeable;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * 静态换肤、换语言管理
 */
public class TUIThemeManager {
    private static final String TAG = TUIThemeManager.class.getSimpleName();

    private static final String SP_THEME_AND_LANGUAGE_NAME = "TUIThemeAndLanguage";
    private static final String SP_KEY_LANGUAGE = "language";
    private static final String SP_KEY_THEME = "theme";

    public static final int THEME_LIGHT = 0; // 轻量版  默认
    public static final int THEME_LIVELY = 1; // 活泼版
    public static final int THEME_SERIOUS = 2; // 严肃版

    @IntDef({THEME_LIGHT, THEME_LIVELY, THEME_SERIOUS})
    private @interface ThemeIds {}

    private static final class ThemeManagerHolder {
        private static final TUIThemeManager instance = new TUIThemeManager();
    }

    public static TUIThemeManager getInstance() {
        return ThemeManagerHolder.instance;
    }

    private TUIThemeManager() {}

    private boolean isInit = false;

    private final List<Integer> lightThemeResIds = new ArrayList<>();
    private final List<Integer> livelyThemeResIds = new ArrayList<>();
    private final List<Integer> seriousThemeResIds = new ArrayList<>();

    private int currentTheme = THEME_LIGHT;
    private String currentLanguage = "";

    static void setTheme(Context context) {
        getInstance().setThemeInternal(context);
    }

    private void setThemeInternal(Context context) {
        if (context == null) {
            return;
        }

        Context appContext = context.getApplicationContext();
        if (!isInit) {
            isInit = true;
            if (appContext instanceof Application) {
                ((Application) appContext).registerActivityLifecycleCallbacks(new ThemeAndLanguageCallback());

                // 解决 Android 7 以上 WebView 导致切换语言失败的问题。
                new WebView(appContext).destroy();
            }

            SharedPreferences sharedPreferences = context.getSharedPreferences(SP_THEME_AND_LANGUAGE_NAME, Context.MODE_PRIVATE);
            currentLanguage = sharedPreferences.getString(SP_KEY_LANGUAGE, "");
            currentTheme = sharedPreferences.getInt(SP_KEY_THEME, THEME_LIGHT);

            // 语言只需要初始化一次
            applyLanguage(appContext);
        }
        // 主题需要更新多次
        applyTheme(appContext);
    }

    public static void addLightTheme(int resId) {
        if (resId == 0) {
            return;
        }
        if (getInstance().lightThemeResIds.contains(resId)) {
            return;
        }
        getInstance().lightThemeResIds.add(resId);
    }
    public static void addLivelyTheme(int resId) {
        if (resId == 0) {
            return;
        }
        if (getInstance().livelyThemeResIds.contains(resId)) {
            return;
        }
        getInstance().livelyThemeResIds.add(resId);

    }
    public static void addSeriousTheme(int resId) {
        if (resId == 0) {
            return;
        }
        if (getInstance().seriousThemeResIds.contains(resId)) {
            return;
        }
        getInstance().seriousThemeResIds.add(resId);
    }

    public int getCurrentTheme() {
        return currentTheme;
    }

    private void mergeTheme(Resources.Theme theme) {
        if (theme == null) {
            return;
        }
        List<Integer> currentThemeResIds = lightThemeResIds;
        if (currentTheme == THEME_LIVELY) {
            currentThemeResIds = livelyThemeResIds;
        } else if (currentTheme == THEME_SERIOUS) {
            currentThemeResIds = seriousThemeResIds;
        }
        for (Integer resId : currentThemeResIds) {
            theme.applyStyle(resId, true);
        }
    }

    public void changeLanguage(Context context, String language) {
        if (context == null) {
            return;
        }

        if (TextUtils.equals(language, currentLanguage)) {
            return;
        }
        currentLanguage = language;

        SharedPreferences sharedPreferences = context.getSharedPreferences(SP_THEME_AND_LANGUAGE_NAME, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(SP_KEY_LANGUAGE, language);
        editor.commit();

        applyLanguage(context.getApplicationContext());
        applyLanguage(context);
    }

    public void applyLanguage(Context context) {
        if (context == null) {
            return;
        }

        Locale locale = getLocale(context);
        if ("en".equals(currentLanguage)) {
            locale = Locale.ENGLISH;
        } else if ("zh".equals(currentLanguage)) {
            locale = Locale.CHINA;
        }

        Resources resources = context.getResources();
        Configuration configuration = resources.getConfiguration();
        configuration.locale = locale;
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            configuration.setLocale(locale);
        }
        resources.updateConfiguration(configuration, null);

        if (Build.VERSION.SDK_INT >= 25) {
            context = context.createConfigurationContext(configuration);
            context.getResources().updateConfiguration(configuration,
                resources.getDisplayMetrics());
        }
    }

    public String getCurrentLanguage() {
        return currentLanguage;
    }

    private Locale getLocale(Context context) {
        Locale locale;

        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
            locale = context.getResources().getConfiguration().locale;
        } else {
            locale = context.getResources().getConfiguration().getLocales().get(0);
        }
        return locale;
    }

    public void changeTheme(Context context, @ThemeIds int themeId) {
        if (context == null) {
            return;
        }

        if (themeId == currentTheme) {
            return;
        }
        currentTheme = themeId;

        SharedPreferences sharedPreferences = context.getSharedPreferences(SP_THEME_AND_LANGUAGE_NAME, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(SP_KEY_THEME, themeId);
        editor.commit();

        applyTheme(context.getApplicationContext());
        applyTheme(context);
    }

    /**
     * 当前 Activity 或者 Application 应用主题
     * @param context 一般为 Application 或者 Activity
     */
    private void applyTheme(Context context) {
        if (context == null) {
            return;
        }
        Resources.Theme theme = context.getTheme();
        if (theme == null) {
            if (currentTheme == THEME_LIVELY) {
                context.setTheme(R.style.TUIBaseLivelyTheme);
            } else if (currentTheme == THEME_SERIOUS) {
                context.setTheme(R.style.TUIBaseSeriousTheme);
            } else {
                context.setTheme(R.style.TUIBaseLightTheme);
            }
            theme = context.getTheme();
        }
        mergeTheme(theme);
    }

    /**
     * 获取参与换肤的资源 id
     * @param context 一般为当前界面的 Activity，此 Activity 实现了 ITUIThemeChangeable 接口
     * @param attrId attr 自定义的要变换主题的 attr
     * @return 当前主题下的资源 id
     */
    public static int getAttrResId(Context context, int attrId) {
        if (context == null || attrId == 0) {
            return 0;
        }
        TypedValue typedValue = new TypedValue();
        context.getTheme().resolveAttribute(attrId, typedValue, true);
        return typedValue.resourceId;
    }

    static class ThemeAndLanguageCallback implements Application.ActivityLifecycleCallbacks {

        @Override
        public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
            // 如果 Activity 支持换肤则设置主题
            if (activity instanceof ITUIThemeChangeable) {
                TUIThemeManager.getInstance().applyTheme(activity);
            }
            TUIThemeManager.getInstance().applyLanguage(activity);
        }

        @Override
        public void onActivityStarted(@NonNull Activity activity) {

        }

        @Override
        public void onActivityResumed(@NonNull Activity activity) {

        }

        @Override
        public void onActivityPaused(@NonNull Activity activity) {

        }

        @Override
        public void onActivityStopped(@NonNull Activity activity) {

        }

        @Override
        public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(@NonNull Activity activity) {

        }
    }

}
