package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.config.ShortcutMenuConfig;
import java.util.List;

public class ShortcutView extends RecyclerView {
    private LayoutManager layoutManager;
    private ShortcutAdapter adapter;
    private List<ShortcutMenuConfig.TUIChatShortcutMenuData> dataList;

    public ShortcutView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public ShortcutView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public ShortcutView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        layoutManager = new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false);
        setLayoutManager(layoutManager);
        adapter = new ShortcutAdapter();
        setAdapter(adapter);
    }

    public void setDataList(List<ShortcutMenuConfig.TUIChatShortcutMenuData> dataList) {
        this.dataList = dataList;
        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
    }

    class ShortcutAdapter extends Adapter<ShortcutViewHolder> {
        @NonNull
        @Override
        public ShortcutViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_input_shortcut_item, parent, false);
            return new ShortcutViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ShortcutViewHolder holder, int position) {
            ShortcutMenuConfig.TUIChatShortcutMenuData data = dataList.get(position);
            holder.shortcutView.setText(data.text);
            if (data.textColor != ShortcutMenuConfig.TUIChatShortcutMenuData.UNDEFINED) {
                holder.shortcutView.setTextColor(data.textColor);
            }
            if (data.textFontSize != ShortcutMenuConfig.TUIChatShortcutMenuData.UNDEFINED) {
                holder.shortcutView.setTextSize(data.textFontSize);
            }
            if (data.background != null) {
                holder.shortcutView.setBackground(data.background);
            }
            holder.shortcutView.setOnClickListener(data.onClickListener);
        }

        @Override
        public int getItemCount() {
            if (dataList != null) {
                return dataList.size();
            } else {
                return 0;
            }
        }
    }

    static class ShortcutViewHolder extends ViewHolder {
        TextView shortcutView;

        public ShortcutViewHolder(@NonNull View itemView) {
            super(itemView);
            shortcutView = (TextView) itemView;
        }
    }
}
