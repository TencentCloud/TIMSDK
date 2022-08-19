package com.tencent.qcloud.tuicore;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.util.TypedValue;
import android.webkit.WebView;

import androidx.annotation.IntDef;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuicore.util.TUIUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Static skinning, language
 */
public class TUIThemeManager {
    private static final String TAG = TUIThemeManager.class.getSimpleName();

    private static final String SP_THEME_AND_LANGUAGE_NAME = "TUIThemeAndLanguage";
    private static final String SP_KEY_LANGUAGE = "language";
    private static final String SP_KEY_THEME = "theme";

    public static final int THEME_LIGHT = 0; // default
    public static final int THEME_LIVELY = 1;
    public static final int THEME_SERIOUS = 2;

    public static final String LANGUAGE_ZH_CN = "zh";
    public static final String LANGUAGE_EN = "en";

    private static final class ThemeManagerHolder {
        private static final TUIThemeManager instance = new TUIThemeManager();
    }

    public static TUIThemeManager getInstance() {
        return ThemeManagerHolder.instance;
    }

    private boolean isInit = false;

    private final Map<Integer, List<Integer>> themeResIDMap = new HashMap<>();
    private final Map<String, Locale> languageMap = new HashMap<>();

    private int currentThemeID = THEME_LIGHT;
    private String currentLanguage = "";
    private Locale defaultLocale = null;

    private TUIThemeManager() {
        languageMap.put(LANGUAGE_ZH_CN, Locale.SIMPLIFIED_CHINESE);
        languageMap.put(LANGUAGE_EN, Locale.ENGLISH);
    }

    public static void setTheme(Context context) {
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
            }

            Locale defaultLocale = getLocale(appContext);
            SPUtils spUtils = SPUtils.getInstance(SP_THEME_AND_LANGUAGE_NAME);
            currentLanguage = spUtils.getString(SP_KEY_LANGUAGE, defaultLocale.getLanguage());
            currentThemeID = spUtils.getInt(SP_KEY_THEME, THEME_LIGHT);

            // The language only needs to be initialized once
            applyLanguage(appContext);
        }
        // The theme needs to be updated multiple times
        applyTheme(appContext);
    }

    /**
     * Solve the problem that WebView on Android 7 and above causes failure to switch languages.
     * Solve the problem of using WebView Crash for multiple processes above Android 9.
     */
    public static void setWebViewLanguage(Context appContext) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                WebView.setDataDirectorySuffix(TUIUtil.getProcessName());
            }
            new WebView(appContext).destroy();
        } catch (Throwable throwable) {
            Log.e("TUIThemeManager", "init language settings failed, " + throwable.getMessage());
        }
    }

    public void setDefaultLocale(Locale defaultLocale) {
        this.defaultLocale = defaultLocale;
    }

    public static void addTheme(int themeID, int resID) {
        if (resID == 0) {
            Log.e(TAG, "addTheme failed, theme resID is zero");
            return;
        }
        Log.i(TAG, "addTheme themeID=" + themeID + " resID=" + resID);
        List<Integer> themeResIDList = getInstance().themeResIDMap.get(themeID);
        if (themeResIDList == null) {
            themeResIDList = new ArrayList<>();
            getInstance().themeResIDMap.put(themeID, themeResIDList);
        }
        if (themeResIDList.contains(resID)) {
            return;
        }
        themeResIDList.add(resID);
        TUIThemeManager.getInstance().applyTheme(ServiceInitializer.getAppContext());
    }

    public static void addLightTheme(int resId) {
        addTheme(THEME_LIGHT, resId);
    }

    public static void addLivelyTheme(int resId) {
        addTheme(THEME_LIVELY, resId);
    }
    public static void addSeriousTheme(int resId) {
        addTheme(THEME_SERIOUS, resId);
    }

    public int getCurrentTheme() {
        return currentThemeID;
    }

    private void mergeTheme(Resources.Theme theme) {
        if (theme == null) {
            return;
        }

        List<Integer> currentThemeResIDList = themeResIDMap.get(currentThemeID);
        if (currentThemeResIDList == null) {
            return;
        }
        for (Integer resId : currentThemeResIDList) {
            theme.applyStyle(resId, true);
        }
    }

    public static void addLanguage(String language, Locale locale) {
        Log.i(TAG, "addLanguage language=" + language + " locale=" + locale);
        getInstance().languageMap.put(language, locale);
    }

    public void changeLanguage(Context context, String language) {
        if (context == null) {
            return;
        }

        if (TextUtils.equals(language, currentLanguage)) {
            return;
        }
        currentLanguage = language;
        SPUtils spUtils = SPUtils.getInstance(SP_THEME_AND_LANGUAGE_NAME);
        spUtils.put(SP_KEY_LANGUAGE, language, true);

        applyLanguage(context.getApplicationContext());
        applyLanguage(context);
    }

    public void applyLanguage(Context context) {
        if (context == null) {
            return;
        }
        Locale locale = languageMap.get(currentLanguage);
        if (locale == null) {
            if (defaultLocale != null) {
                locale = defaultLocale;
            } else {
                locale = getLocale(context);
            }
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

    public Locale getLocale(Context context) {
        Locale locale;

        if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
            locale = context.getResources().getConfiguration().locale;
        } else {
            locale = context.getResources().getConfiguration().getLocales().get(0);
        }
        return locale;
    }

    public void changeTheme(Context context, int themeId) {
        if (context == null) {
            return;
        }

        if (themeId == currentThemeID) {
            return;
        }
        currentThemeID = themeId;

        SPUtils spUtils = SPUtils.getInstance(SP_THEME_AND_LANGUAGE_NAME);
        spUtils.put(SP_KEY_THEME, themeId, true);

        applyTheme(context.getApplicationContext());
        applyTheme(context);
    }

    private void applyTheme(Context context) {
        if (context == null) {
            return;
        }
        Resources.Theme theme = context.getTheme();
        if (theme == null) {
            context.setTheme(R.style.TUIBaseTheme);
            theme = context.getTheme();
        }
        mergeTheme(theme);
    }

    /**
     * Get resources for skinning
     * 
     * @param context   context
     * @param attrId    custom attribute
     * @return resources for skinning
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
            TUIThemeManager.getInstance().applyTheme(activity);
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
