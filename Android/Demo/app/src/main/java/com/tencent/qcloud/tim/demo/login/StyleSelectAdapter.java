package com.tencent.qcloud.tim.demo.login;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import java.util.ArrayList;
import java.util.List;

public class StyleSelectAdapter extends RecyclerView.Adapter<StyleSelectAdapter.SelectViewHolder> {
    private static final String TAG = StyleSelectAdapter.class.getSimpleName();

    int selectedItem = -1;
    private List<String> styleList = new ArrayList<>();
    private OnItemClickListener onItemClickListener;
    private StyleSelectAdapter.SelectViewHolder mViewHolder;

    public void setSelectedItem(int selectedItem) {
        this.selectedItem = selectedItem;
    }

    @NonNull
    @Override
    public StyleSelectAdapter.SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(com.tencent.qcloud.tuikit.timcommon.R.layout.core_select_item_layout, parent, false);
        return new StyleSelectAdapter.SelectViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull StyleSelectAdapter.SelectViewHolder holder, int position) {
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
        mViewHolder = holder;
    }

    @Override
    public int getItemCount() {
        return styleList.size();
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    public void setData(List<String> data) {
        this.styleList = data;
    }

    public void refreshViewByThemeChanged() {
        if (mViewHolder == null) {
            DemoLog.e(TAG, "mViewHolder is null");
            return;
        }

        int currentTheme = TUIThemeManager.getInstance().getCurrentTheme();
        if (currentTheme == TUIThemeManager.THEME_LIGHT) {
            mViewHolder.selectedIcon.setBackgroundResource(com.tencent.qcloud.tuikit.timcommon.R.drawable.core_selected_icon_light);
        } else if (currentTheme == TUIThemeManager.THEME_LIVELY) {
            mViewHolder.selectedIcon.setBackgroundResource(com.tencent.qcloud.tuikit.timcommon.R.drawable.core_selected_icon_lively);
        } else if (currentTheme == TUIThemeManager.THEME_SERIOUS) {
            mViewHolder.selectedIcon.setBackgroundResource(com.tencent.qcloud.tuikit.timcommon.R.drawable.core_selected_icon_serious);
        }
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

    public interface OnItemClickListener {
        void onClick(int style);
    }
}
