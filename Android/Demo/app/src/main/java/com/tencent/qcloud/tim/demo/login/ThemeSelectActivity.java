package com.tencent.qcloud.tim.demo.login;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class ThemeSelectActivity extends BaseLightActivity {
    public static final String THEME = "language";

    private TitleBarLayout titleBarLayout;
    private RecyclerView recyclerView;
    private ThemeSelectAdapter adapter;
    private int currentThemeId;

    private static OnResultReturnListener onResultReturnListener;
    private static WeakReference<ThemeSelectActivity> instance;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        instance = new WeakReference<>(this);
        setContentView(R.layout.activity_theme_language_select);
        titleBarLayout = findViewById(R.id.demo_select_title_bar);
        recyclerView = findViewById(R.id.theme_recycler_view);
        titleBarLayout.setTitle(getResources().getString(R.string.modify_theme), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.getLeftGroup().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

        currentThemeId = TUIThemeManager.getInstance().getCurrentTheme();
        adapter = new ThemeSelectAdapter();
        adapter.setSelectedId(currentThemeId);

        initData();
        int padding = ScreenUtil.dip2px(15.36f);
        recyclerView.setPadding(padding, padding, padding, padding);
        recyclerView.addItemDecoration(new GridDecoration(2, ScreenUtil.dip2px(11.52f), ScreenUtil.dip2px(9.6f)));
        recyclerView.setLayoutManager(new GridLayoutManager(this, 2));
        recyclerView.setAdapter(adapter);

        adapter.setOnItemClickListener(new ThemeSelectAdapter.OnItemClickListener() {
            @Override
            public void onClick(int themeId) {
                if (currentThemeId == themeId) {
                    if (onResultReturnListener != null) {
                        onResultReturnListener.onReturn(currentThemeId);
                    }
                    return;
                } else {
                    currentThemeId = themeId;
                }
                adapter.setSelectedId(currentThemeId);
                adapter.notifyDataSetChanged();
                TUIThemeManager.getInstance().changeTheme(ThemeSelectActivity.this, currentThemeId);
                changeTitleBackground();
                notifyThemeChanged();

                if (onResultReturnListener != null) {
                    onResultReturnListener.onReturn(currentThemeId);
                }
            }
        });
    }

    private void notifyThemeChanged() {
        Intent intent = new Intent();
        intent.setAction(Constants.DEMO_THEME_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void changeTitleBackground() {
        int color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_light);
        int titleColor = getResources().getColor(com.tencent.qcloud.tuikit.timcommon.R.color.core_title_bar_text_bg_light);
        int backIconId = com.tencent.qcloud.tuikit.timcommon.R.drawable.core_title_bar_back_light;
        if (currentThemeId == TUIThemeManager.THEME_LIVELY) {
            color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_lively);
            titleColor = getResources().getColor(com.tencent.qcloud.tuikit.timcommon.R.color.core_title_bar_text_bg_lively);
            backIconId = com.tencent.qcloud.tuikit.timcommon.R.drawable.core_title_bar_back_lively;
        } else if (currentThemeId == TUIThemeManager.THEME_SERIOUS) {
            color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_serious);
            titleColor = getResources().getColor(com.tencent.qcloud.tuikit.timcommon.R.color.core_title_bar_text_bg_serious);
            backIconId = com.tencent.qcloud.tuikit.timcommon.R.drawable.core_title_bar_back_serious;
        }
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(color);
        }
        titleBarLayout.setBackgroundColor(color);
        titleBarLayout.getMiddleTitle().setTextColor(titleColor);
        titleBarLayout.getLeftIcon().setBackgroundResource(backIconId);
    }

    private void initData() {
        ThemeSelectAdapter.ThemeBean lightBean = new ThemeSelectAdapter.ThemeBean();
        lightBean.id = TUIThemeManager.THEME_LIGHT;
        lightBean.name = getString(R.string.light_theme);
        lightBean.resId = R.drawable.demo_theme_select_bg_light;
        ThemeSelectAdapter.ThemeBean livelyBean = new ThemeSelectAdapter.ThemeBean();
        livelyBean.id = TUIThemeManager.THEME_LIVELY;
        livelyBean.name = getString(R.string.lively_theme);
        livelyBean.resId = R.drawable.demo_theme_select_bg_lively;
        ThemeSelectAdapter.ThemeBean seriousBean = new ThemeSelectAdapter.ThemeBean();
        seriousBean.id = TUIThemeManager.THEME_SERIOUS;
        seriousBean.name = getString(R.string.serious_theme);
        seriousBean.resId = R.drawable.demo_theme_select_bg_serious;
        List<ThemeSelectAdapter.ThemeBean> themeBeanList = new ArrayList<>();
        themeBeanList.add(lightBean);
        themeBeanList.add(seriousBean);
        themeBeanList.add(livelyBean);
        adapter.setData(themeBeanList);
    }

    public static void startSelectTheme(Activity activity) {
        Intent intent = new Intent(activity, ThemeSelectActivity.class);
        activity.startActivity(intent);
    }

    public static void startSelectTheme(Context context, OnResultReturnListener listener) {
        Intent intent = new Intent(context, ThemeSelectActivity.class);
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

    /**
     * Add spacing and dividers
     */
    static class GridDecoration extends RecyclerView.ItemDecoration {
        private final int columnNum;
        private final int leftRightSpace;
        private final int topBottomSpace;

        public GridDecoration(int columnNum, int leftRightSpace, int topBottomSpace) {
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            outRect.left = column * leftRightSpace / columnNum;
            outRect.right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            // Add top spacing when multiple lines
            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }
    }

    public interface OnResultReturnListener {
        void onReturn(Object res);
    }
}