package com.tencent.qcloud.tim.demo.login;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.util.ArrayList;
import java.util.List;

public class ThemeSelectActivity extends BaseLightActivity {
    public static final String THEME = "language";
    public static final String DEMO_THEME_CHANGED_ACTION = "demoThemeChangedAction";

    private OnItemClickListener onItemClickListener;
    private TitleBarLayout titleBarLayout;
    private RecyclerView recyclerView;
    private final List<ThemeBean> themeBeanList = new ArrayList<>();
    private SelectAdapter adapter;
    private int currentThemeId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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

        initData();

        currentThemeId = TUIThemeManager.getInstance().getCurrentTheme();
        adapter = new SelectAdapter();
        adapter.setSelectedId(currentThemeId);

        int padding = ScreenUtil.dip2px(15.36f);
        recyclerView.setPadding(padding, padding, padding, padding);
        recyclerView.addItemDecoration(new GridDecoration(2, ScreenUtil.dip2px(11.52f), ScreenUtil.dip2px(9.6f)));
        recyclerView.setLayoutManager(new GridLayoutManager(this, 2));
        recyclerView.setAdapter(adapter);
        onItemClickListener = new OnItemClickListener() {
            @Override
            public void onClick(int themeId) {
                if (currentThemeId == themeId) {
                    return;
                } else {
                    currentThemeId = themeId;
                }
                adapter.setSelectedId(currentThemeId);
                adapter.notifyDataSetChanged();
                TUIThemeManager.getInstance().changeTheme(ThemeSelectActivity.this, currentThemeId);
                changeTitleBackground();
                notifyThemeChanged();
            }
        };
    }

    private void notifyThemeChanged() {
        Intent intent = new Intent();
        intent.setAction(DEMO_THEME_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void changeTitleBackground() {
        int color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_light);
        int titleColor = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_title_bar_text_bg_light);
        int backIconId = com.tencent.qcloud.tuicore.R.drawable.core_title_bar_back_light;
        if (currentThemeId == TUIThemeManager.THEME_LIVELY) {
            color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_lively);
            titleColor = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_title_bar_text_bg_lively);
            backIconId = com.tencent.qcloud.tuicore.R.drawable.core_title_bar_back_lively;
        } else if (currentThemeId == TUIThemeManager.THEME_SERIOUS) {
            color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_serious);
            titleColor = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_title_bar_text_bg_serious);
            backIconId = com.tencent.qcloud.tuicore.R.drawable.core_title_bar_back_serious;
        }
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(color);
        }
        titleBarLayout.setBackgroundColor(color);
        titleBarLayout.getMiddleTitle().setTextColor(titleColor);
        titleBarLayout.getLeftIcon().setBackgroundResource(backIconId);

    }

    private void initData() {
        ThemeBean lightBean = new ThemeBean();
        lightBean.id = TUIThemeManager.THEME_LIGHT;
        lightBean.name = getString(R.string.light_theme);
        lightBean.resId = R.drawable.demo_theme_select_bg_light;
        ThemeBean livelyBean = new ThemeBean();
        livelyBean.id = TUIThemeManager.THEME_LIVELY;
        livelyBean.name = getString(R.string.lively_theme);
        livelyBean.resId = R.drawable.demo_theme_select_bg_lively;
        ThemeBean seriousBean = new ThemeBean();
        seriousBean.id = TUIThemeManager.THEME_SERIOUS;
        seriousBean.name = getString(R.string.serious_theme);
        seriousBean.resId = R.drawable.demo_theme_select_bg_serious;
        themeBeanList.add(lightBean);
        themeBeanList.add(seriousBean);
        themeBeanList.add(livelyBean);
    }

    public static void startSelectTheme(Activity activity) {
        Intent intent = new Intent(activity, ThemeSelectActivity.class);
        activity.startActivity(intent);
    }

    public static class ThemeBean {
        int id;
        String name;
        int resId;
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


    class SelectAdapter extends RecyclerView.Adapter<SelectAdapter.SelectViewHolder> {
        int selectedId = -1;

        public void setSelectedId(int selectedId) {
            this.selectedId = selectedId;
        }

        @NonNull
        @Override
        public SelectAdapter.SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(ThemeSelectActivity.this).inflate(R.layout.layout_theme_select_item, parent, false);
            return new SelectAdapter.SelectViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull SelectAdapter.SelectViewHolder holder, int position) {
            ThemeBean themeBean = themeBeanList.get(position);
            holder.content.setBackgroundResource(themeBean.resId);
            holder.name.setText(themeBean.name);
            if (selectedId == themeBean.id) {
                holder.frame.setForeground(getResources().getDrawable(R.drawable.item_selected_border));
                holder.selectedIcon.setBackgroundResource(R.drawable.check_box_selected);
            } else {
                holder.frame.setForeground(null);
                holder.selectedIcon.setBackgroundResource(R.drawable.demo_checkbox_unselect_bg);
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onItemClickListener.onClick(themeBean.id);
                }
            });
        }

        @Override
        public int getItemCount() {
            return themeBeanList.size();
        }

        class SelectViewHolder extends RecyclerView.ViewHolder{
            TextView name;
            ImageView selectedIcon;
            FrameLayout frame;
            RelativeLayout content;
            public SelectViewHolder(@NonNull View itemView) {
                super(itemView);
                name = itemView.findViewById(R.id.name);
                selectedIcon = itemView.findViewById(R.id.selected_icon);
                frame = itemView.findViewById(R.id.item_frame);
                content = itemView.findViewById(R.id.item_content);
                itemView.setClipToOutline(true);
                frame.setClipToOutline(true);
                content.setClipToOutline(true);
            }
        }
    }

    public interface OnItemClickListener {
        void onClick(int themeId);
    }
}