package com.tencent.qcloud.tuikit.timcommon.component.action;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import java.util.ArrayList;
import java.util.List;

public class PopMenuAdapter extends BaseAdapter {
    private List<PopMenuAction> dataSource = new ArrayList<>();

    public PopMenuAdapter() {}

    public void setDataSource(final List datas) {
        dataSource = datas;
        ThreadUtils.postOnUiThread(new Runnable() {
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
            holder.menuIcon = convertView.findViewById(R.id.pop_menu_icon);

            int iconSize = convertView.getResources().getDimensionPixelSize(R.dimen.core_pop_menu_icon_size);
            ViewGroup.LayoutParams params = holder.menuIcon.getLayoutParams();
            params.width = iconSize;
            params.height = iconSize;
            holder.menuIcon.setLayoutParams(params);

            holder.menuLable = convertView.findViewById(R.id.pop_menu_label);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        PopMenuAction action = (PopMenuAction) getItem(position);
        holder.menuIcon.setVisibility(View.VISIBLE);
        if (action.getIcon() != null) {
            holder.menuIcon.setImageBitmap(action.getIcon());
        } else if (action.getIconResId() > 0) {
            holder.menuIcon.setImageResource(action.getIconResId());
        } else {
            holder.menuIcon.setVisibility(View.GONE);
        }
        holder.menuLable.setText(action.getActionName());
        return convertView;
    }

    static class ViewHolder {
        TextView menuLable;
        ImageView menuIcon;
    }
}
