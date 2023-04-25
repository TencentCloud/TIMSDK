package com.tencent.qcloud.tim.demo.login;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.TUIBuild;
import com.tencent.qcloud.tuikit.timcommon.component.CustomLinearLayoutManager;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;


public class LanguageSelectActivity extends BaseLightActivity {

    public static final String LANGUAGE = "language";

    private OnItemClickListener onItemClickListener;
    private TitleBarLayout titleBarLayout;
    private RecyclerView recyclerView;
    private final Map<String, String> languageMap = new HashMap<>();
    private final List<String> languageList = new ArrayList<>();
    private SelectAdapter adapter;
    private String currentLanguage;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_theme_language_select);
        titleBarLayout = findViewById(R.id.demo_select_title_bar);
        recyclerView = findViewById(R.id.theme_recycler_view);
        titleBarLayout.setTitle(getResources().getString(R.string.demo_language_title), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.getLeftGroup().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        currentLanguage = TUIThemeManager.getInstance().getCurrentLanguage();
        if (TextUtils.isEmpty(currentLanguage)) {
            Locale locale;
            if (TUIBuild.getVersionInt() < Build.VERSION_CODES.N) {
                locale = getResources().getConfiguration().locale;
            } else {
                locale = getResources().getConfiguration().getLocales().get(0);
            }
            currentLanguage = locale.getLanguage();
        }
        adapter = new SelectAdapter();
        initData();

        recyclerView.setAdapter(adapter);
        recyclerView.setLayoutManager(new CustomLinearLayoutManager(this));
        DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(this, DividerItemDecoration.VERTICAL);
        dividerItemDecoration.setDrawable(getResources().getDrawable(com.tencent.qcloud.tuikit.timcommon.R.drawable.core_list_divider));
        recyclerView.addItemDecoration(dividerItemDecoration);

        onItemClickListener = new OnItemClickListener() {
            @Override
            public void onClick(String language) {
                if (TextUtils.equals(currentLanguage, language)) {
                    return;
                } else {
                    currentLanguage = language;
                }
                int index = TextUtils.equals(language, "zh") ? 0 : 1;
                adapter.setSelectedItem(index);
                adapter.notifyDataSetChanged();
                TUIThemeManager.getInstance().changeLanguage(LanguageSelectActivity.this, currentLanguage);
                changeTitleLanguage();
                notifyLanguageChanged();
            }
        };
    }

    private void notifyLanguageChanged() {
        Intent intent = new Intent();
        intent.setAction(Constants.DEMO_LANGUAGE_CHANGED_ACTION);
        intent.putExtra(LANGUAGE, currentLanguage);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }

    private void changeTitleLanguage() {
        titleBarLayout.setTitle(getResources().getString(R.string.demo_language_title), ITitleBarLayout.Position.MIDDLE);
    }

    private void initData() {
        String simplifiedChinese = "简体中文";
        String english = "English";
        languageList.add(simplifiedChinese);
        languageMap.put(simplifiedChinese, "zh");
        languageList.add(english);
        languageMap.put(english, "en");
        if (TextUtils.equals(currentLanguage, "zh")) {
            adapter.setSelectedItem(0);
        } else {
            adapter.setSelectedItem(1);
        }
    }

    public static void startSelectLanguage(Activity activity) {
        Intent intent = new Intent(activity, LanguageSelectActivity.class);
        activity.startActivity(intent);
    }


    class SelectAdapter extends RecyclerView.Adapter<SelectAdapter.SelectViewHolder> {
        int selectedItem = -1;

        public void setSelectedItem(int selectedItem) {
            this.selectedItem = selectedItem;
        }

        @NonNull
        @Override
        public SelectAdapter.SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(LanguageSelectActivity.this).inflate(com.tencent.qcloud.tuikit.timcommon.R.layout.core_select_item_layout,parent, false);
            return new SelectAdapter.SelectViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull SelectAdapter.SelectViewHolder holder, int position) {
            String language = languageList.get(position);
            holder.name.setText(language);
            if (selectedItem == position) {
                holder.selectedIcon.setVisibility(View.VISIBLE);
            } else {
                holder.selectedIcon.setVisibility(View.GONE);
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onItemClickListener.onClick(languageMap.get(language));
                }
            });
        }

        @Override
        public int getItemCount() {
            return languageMap.size();
        }

        class SelectViewHolder extends RecyclerView.ViewHolder {
            TextView name;
            ImageView selectedIcon;
            public SelectViewHolder(@NonNull View itemView) {
                super(itemView);
                name = itemView.findViewById(com.tencent.qcloud.tuikit.timcommon.R.id.name);
                selectedIcon = itemView.findViewById(com.tencent.qcloud.tuikit.timcommon.R.id.selected_icon);
            }
        }
    }

    public interface OnItemClickListener {
        void onClick(String language);
    }
}