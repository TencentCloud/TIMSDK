
package com.tencent.qcloud.tim.uikit.component.action;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.utils.BackgroundTasks;

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
            convertView = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.pop_menu_adapter, parent, false);
            holder = new ViewHolder();
            holder.menu_icon = convertView.findViewById(R.id.pop_menu_icon);
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
