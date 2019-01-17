
package com.tencent.qcloud.uikit.business.contact.view.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.common.BackgroundTasks;

import java.util.ArrayList;
import java.util.List;

public class ContactPopMenuAdapter extends BaseAdapter {

    private List<ContactPopMenuAction> dataSource = new ArrayList<>();

    public ContactPopMenuAdapter() {

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
            holder.menu_icon = (ImageView) convertView.findViewById(R.id.pop_menu_icon);
            holder.menu_lable = (TextView) convertView.findViewById(R.id.pop_menu_label);
            convertView.setTag(holder);
        } else {// 有直接获得ViewHolder
            holder = (ViewHolder) convertView.getTag();
        }
        ContactPopMenuAction action = (ContactPopMenuAction) getItem(position);
        if (action.getIcon() != null)
            holder.menu_icon.setImageBitmap(action.getIcon());
        holder.menu_lable.setText(action.getActionName());
        return convertView;
    }

    static class ViewHolder {
        TextView menu_lable;
        ImageView menu_icon;
    }


}
