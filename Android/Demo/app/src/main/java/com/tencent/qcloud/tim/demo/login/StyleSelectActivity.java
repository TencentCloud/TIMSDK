package com.tencent.qcloud.tim.demo.login;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.TUIBuild;

import java.util.ArrayList;
import java.util.List;

public class StyleSelectActivity extends BaseLightActivity {

    private StyleSelectActivity.OnItemClickListener onItemClickListener;
    private TitleBarLayout titleBarLayout;
    private RecyclerView recyclerView;
    private final List<String> styleList = new ArrayList<>();
    private StyleSelectActivity.SelectAdapter adapter;
    private SharedPreferences mSharedPreferences;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
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

        adapter = new StyleSelectActivity.SelectAdapter();
        initData();

        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new CustomLinearLayoutManager(this));
        DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        dividerItemDecoration.setDrawable(getResources().getDrawable(com.tencent.qcloud.tuicore.R.drawable.core_list_divider));
        recyclerView.addItemDecoration(dividerItemDecoration);

        onItemClickListener = new StyleSelectActivity.OnItemClickListener() {
            @Override
            public void onClick(int style) {
                adapter.setSelectedItem(style);
                adapter.notifyDataSetChanged();
                DemoApplication.tuikit_demo_style = style;
                if (mSharedPreferences != null) {
                    mSharedPreferences.edit().putInt("tuikit_demo_style", style).commit();
                }

                if (style == 1) {
                    TUIThemeManager.getInstance().changeTheme(StyleSelectActivity.this, TUIThemeManager.THEME_LIGHT);
                    changeTitleBackground();
                    notifyThemeChanged();
                }
            }
        };
    }

    private void changeTitleBackground() {
        int color = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_header_start_color_light);
        int titleColor = getResources().getColor(com.tencent.qcloud.tuicore.R.color.core_title_bar_text_bg_light);
        int backIconId = com.tencent.qcloud.tuicore.R.drawable.core_title_bar_back_light;

        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(color);
        }
        titleBarLayout.setBackgroundColor(color);
        titleBarLayout.getMiddleTitle().setTextColor(titleColor);
        titleBarLayout.getLeftIcon().setBackgroundResource(backIconId);
    }

    private void notifyThemeChanged() {
        Intent intent = new Intent();
        intent.setAction(ThemeSelectActivity.DEMO_THEME_CHANGED_ACTION);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void initData() {
        String classic = getString(R.string.style_classic);
        String minimalist = getString(R.string.style_minimalist);
        styleList.add(classic);
        styleList.add(minimalist);
        adapter.setSelectedItem(DemoApplication.tuikit_demo_style);
    }

    public static void startStyleSelectActivity(Activity activity) {
        Intent intent = new Intent(activity, StyleSelectActivity.class);
        activity.startActivity(intent);
    }


    class SelectAdapter extends RecyclerView.Adapter<StyleSelectActivity.SelectAdapter.SelectViewHolder> {
        int selectedItem = -1;

        public void setSelectedItem(int selectedItem) {
            this.selectedItem = selectedItem;
        }

        @NonNull
        @Override
        public StyleSelectActivity.SelectAdapter.SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(StyleSelectActivity.this).inflate(com.tencent.qcloud.tuicore.R.layout.core_select_item_layout,parent, false);
            return new StyleSelectActivity.SelectAdapter.SelectViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull StyleSelectActivity.SelectAdapter.SelectViewHolder holder, int position) {
            String language = styleList.get(position);
            holder.name.setText(language);
            if (selectedItem == position) {
                holder.selectedIcon.setVisibility(View.VISIBLE);
            } else {
                holder.selectedIcon.setVisibility(View.GONE);
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onItemClickListener.onClick(position);
                }
            });
        }

        @Override
        public int getItemCount() {
            return styleList.size();
        }

        class SelectViewHolder extends RecyclerView.ViewHolder {
            TextView name;
            ImageView selectedIcon;
            public SelectViewHolder(@NonNull View itemView) {
                super(itemView);
                name = itemView.findViewById(com.tencent.qcloud.tuicore.R.id.name);
                selectedIcon = itemView.findViewById(com.tencent.qcloud.tuicore.R.id.selected_icon);
            }
        }
    }

    public interface OnItemClickListener {
        void onClick(int style);
    }
}
