package com.tencent.qcloud.tim.demo.login;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.config.AppConfig;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class StyleSelectActivity extends BaseLightActivity {
    private TitleBarLayout titleBarLayout;
    private RecyclerView recyclerView;

    private StyleSelectAdapter adapter;
    private SharedPreferences mSharedPreferences;

    private static OnResultReturnListener onResultReturnListener;
    private static WeakReference<StyleSelectActivity> instance;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        instance = new WeakReference<>(this);
        mSharedPreferences = getApplicationContext().getSharedPreferences("TUIKIT_DEMO_SETTINGS", MODE_PRIVATE);
        setContentView(R.layout.activity_theme_language_select);
        titleBarLayout = findViewById(R.id.demo_select_title_bar);
        recyclerView = findViewById(R.id.theme_recycler_view);
        titleBarLayout.setTitle(getResources().getString(R.string.demo_style_title), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.getLeftGroup().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        adapter = new StyleSelectAdapter();
        initData();

        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new CustomLinearLayoutManager(this));
        DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        dividerItemDecoration.setDrawable(getResources().getDrawable(com.tencent.qcloud.tuikit.timcommon.R.drawable.core_list_divider));
        recyclerView.addItemDecoration(dividerItemDecoration);

        adapter.setOnItemClickListener(new StyleSelectAdapter.OnItemClickListener() {
            @Override
            public void onClick(int style) {
                adapter.setSelectedItem(style);
                adapter.notifyDataSetChanged();
                AppConfig.DEMO_UI_STYLE = style;
                if (mSharedPreferences != null) {
                    mSharedPreferences.edit().putInt("tuikit_demo_style", style).commit();
                }

                if (style == 1) {
                    TUIThemeManager.getInstance().changeTheme(StyleSelectActivity.this, TUIThemeManager.THEME_LIGHT);
                    changeTitleBackground();
                    notifyThemeChanged();
                }

                if (onResultReturnListener != null) {
                    onResultReturnListener.onReturn(style);
                }
            }
        });
    }

    private void changeTitleBackground() {
        int color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_light);
        int titleColor = getResources().getColor(com.tencent.qcloud.tuikit.timcommon.R.color.core_title_bar_text_bg_light);
        int backIconId = com.tencent.qcloud.tuikit.timcommon.R.drawable.core_title_bar_back_light;

        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(color);
        }
        titleBarLayout.setBackgroundColor(color);
        titleBarLayout.getMiddleTitle().setTextColor(titleColor);
        titleBarLayout.getLeftIcon().setBackgroundResource(backIconId);
    }

    private void notifyThemeChanged() {
        Intent intent = new Intent();
        intent.setAction(Constants.DEMO_THEME_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void initData() {
        String classic = getString(R.string.style_classic);
        String minimalist = getString(R.string.style_minimalist);
        List<String> styleList = new ArrayList<>();
        styleList.add(classic);
        styleList.add(minimalist);
        adapter.setData(styleList);
        adapter.setSelectedItem(AppConfig.DEMO_UI_STYLE);
    }

    public static void startStyleSelectActivity(Activity activity) {
        Intent intent = new Intent(activity, StyleSelectActivity.class);
        activity.startActivity(intent);
    }

    public static void startStyleSelectActivity(Context context, OnResultReturnListener listener) {
        Intent intent = new Intent(context, StyleSelectActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
        onResultReturnListener = listener;
    }

    @Override
    protected void onStop() {
        super.onStop();
        onResultReturnListener = null;
    }

    public static void finishActivity() {
        if (instance != null && instance.get() != null) {
            instance.get().finish();
        }
    }

    public interface OnResultReturnListener {
        void onReturn(Object res);
    }
}
