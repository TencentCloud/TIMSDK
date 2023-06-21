package com.tencent.qcloud.tuikit.timcommon.component.action;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;

import java.util.ArrayList;
import java.util.List;

public class PopDialogAdapter extends BaseAdapter {
    private List<PopMenuAction> dataSource = new ArrayList<>();

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
            convertView = LayoutInflater.from(TUIConfig.getAppContext()).inflate(R.layout.pop_dialog_adapter, parent, false);
            holder = new ViewHolder();
            holder.text = convertView.findViewById(R.id.pop_dialog_text);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        PopMenuAction action = (PopMenuAction) getItem(position);
        holder.text.setText(action.getActionName());
        return convertView;
    }

    static class ViewHolder {
        TextView text;
    }
}
