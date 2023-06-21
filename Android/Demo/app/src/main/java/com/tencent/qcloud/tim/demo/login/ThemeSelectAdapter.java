package com.tencent.qcloud.tim.demo.login;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.TIMAppService;
import java.util.ArrayList;
import java.util.List;

public class ThemeSelectAdapter extends RecyclerView.Adapter<ThemeSelectAdapter.SelectViewHolder> {
    private static final String TAG = ThemeSelectAdapter.class.getSimpleName();

    private List<ThemeBean> themeBeanList = new ArrayList<>();
    private int selectedId = -1;
    private OnItemClickListener onItemClickListener;
    public void setSelectedId(int selectedId) {
        this.selectedId = selectedId;
    }

    @NonNull
    @Override
    public ThemeSelectAdapter.SelectViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.layout_theme_select_item, parent, false);
        return new ThemeSelectAdapter.SelectViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ThemeSelectAdapter.SelectViewHolder holder, int position) {
        ThemeBean themeBean = themeBeanList.get(position);
        holder.content.setBackgroundResource(themeBean.resId);
        holder.name.setText(themeBean.name);
        if (selectedId == themeBean.id) {
            holder.frame.setForeground(TIMAppService.getAppContext().getResources().getDrawable(R.drawable.item_selected_border));
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

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    public void setData(List<ThemeBean> data) {
        themeBeanList = data;
    }

    class SelectViewHolder extends RecyclerView.ViewHolder {
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

    public static class ThemeBean {
        public int id;
        public String name;
        public int resId;
    }

    public interface OnItemClickListener {
        void onClick(int themeId);
    }
}
