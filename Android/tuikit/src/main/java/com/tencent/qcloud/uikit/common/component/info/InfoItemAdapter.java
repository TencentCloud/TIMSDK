package com.tencent.qcloud.uikit.common.component.info;

import android.graphics.Color;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.R;

import java.util.ArrayList;
import java.util.List;


public class InfoItemAdapter extends BaseAdapter {
    private List<InfoItemAction> actions = new ArrayList<>();

    @Override
    public int getCount() {
        return actions.size();
    }

    @Override
    public InfoItemAction getItem(int position) {
        return actions.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ItemActionHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.info_item_action_adapter, null);
            holder = new ItemActionHolder();
            holder.border = convertView.findViewById(R.id.info_item_border);
            holder.leftIcon = convertView.findViewById(R.id.info_item_icon);
            holder.label = convertView.findViewById(R.id.info_item_label);
            holder.extra = convertView.findViewById(R.id.info_item_extra);
            holder.rightIcon = convertView.findViewById(R.id.info_item_right_icon);
            convertView.setTag(holder);
        } else {
            holder = (ItemActionHolder) convertView.getTag();
        }

        InfoItemAction action = getItem(position);
        holder.leftIcon.setVisibility(View.GONE);
        if (action.getLeftIcon() > 0) {
            holder.leftIcon.setVisibility(View.VISIBLE);
            holder.leftIcon.setImageResource(action.getLeftIcon());
        } else {
            holder.leftIcon.setVisibility(View.GONE);
        }
        if (!TextUtils.isEmpty(action.getLabel())) {
            holder.label.setText(action.getLabel());
        } else {
            holder.label.setText("");
        }

        if (!TextUtils.isEmpty(action.getExtra())) {
            holder.extra.setText(action.getExtra());
        } else {
            holder.extra.setText("");
        }

        if (action.getBackgroundColor() != 0) {
            convertView.setBackgroundColor(action.getBackgroundColor());
        } else {
            convertView.setBackgroundColor(Color.WHITE);
        }
        holder.rightIcon.setVisibility(action.isRightIconVisible() ? View.VISIBLE : View.GONE);
        if (position == 0) {
            holder.border.setVisibility(View.GONE);
        } else if (position == getCount() - 1) {
            holder.border.setVisibility(View.VISIBLE);
        }
        return convertView;
    }


    public void setDataSource(List<InfoItemAction> dataSource) {
        this.actions = dataSource;
    }

    class ItemActionHolder {
        private ImageView leftIcon, rightIcon;
        private TextView label, extra;
        private View border;
    }
}
