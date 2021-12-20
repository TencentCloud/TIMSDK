package com.tencent.qcloud.tuicore.component.action;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.util.ArrayList;
import java.util.List;

public class PopMenuAdapter extends BaseAdapter {

    private List<PopMenuAction> dataSource = new ArrayList<>();

    public PopMenuAdapter() {

    }

    public void setDataSource(final List datas) {
        dataSource = datas;
        BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                notifyDataSetChanged();
            }
        });
    }

    @Override
    public int getCount() {
        return dataSource.size();
    }

    @Override
    public Object getItem(int position) {
        return dataSource.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {

        ViewHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(TUIConfig.getAppContext()).inflate(R.layout.pop_menu_adapter, parent, false);
            holder = new ViewHolder();
            holder.menu_icon = convertView.findViewById(R.id.pop_menu_icon);

            int iconSize = convertView.getResources().getDimensionPixelSize(R.dimen.core_pop_menu_icon_size);
            ViewGroup.LayoutParams params = holder.menu_icon.getLayoutParams();
            params.width = iconSize;
            params.height = iconSize;
            holder.menu_icon.setLayoutParams(params);

            holder.menu_lable = convertView.findViewById(R.id.pop_menu_label);
            convertView.setTag(holder);
        } else {// 有直接获得ViewHolder
            holder = (ViewHolder) convertView.getTag();
        }
        PopMenuAction action = (PopMenuAction) getItem(position);
        holder.menu_icon.setVisibility(View.VISIBLE);
        if (action.getIcon() != null) {
            holder.menu_icon.setImageBitmap(action.getIcon());
        } else if (action.getIconResId() > 0) {
            holder.menu_icon.setImageResource(action.getIconResId());
        } else {
            holder.menu_icon.setVisibility(View.GONE);
        }
        holder.menu_lable.setText(action.getActionName());
        return convertView;
    }

    static class ViewHolder {
        TextView menu_lable;
        ImageView menu_icon;
    }
}
