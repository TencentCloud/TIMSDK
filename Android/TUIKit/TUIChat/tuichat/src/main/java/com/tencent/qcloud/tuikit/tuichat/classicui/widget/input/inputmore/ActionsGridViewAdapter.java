package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;

import java.util.List;

public class ActionsGridViewAdapter extends BaseAdapter {

    private List<InputMoreActionUnit> baseActions;

    public void setBaseActions(List<InputMoreActionUnit> baseActions) {
        this.baseActions = baseActions;
    }

    @Override
    public int getCount() {
        if (baseActions == null) {
            return 0;
        }
        return baseActions.size();
    }

    @Override
    public Object getItem(int position) {
        return baseActions.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        InputMoreActionUnit action = baseActions.get(position);
        View unitView = action.getUnitView();
        if (unitView != null) {
            return unitView;
        }

        View itemLayout;
        if (convertView == null) {
            itemLayout = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_input_layout_actoin, parent, false);
        } else {
            itemLayout = convertView;
        }

        if (action.getIconResId() > 0) {
            ((ImageView) itemLayout.findViewById(R.id.imageView)).setImageResource(action.getIconResId());
        }
        if (!TextUtils.isEmpty(action.getName())) {
            ((TextView) itemLayout.findViewById(R.id.textView)).setText(action.getName());
        }
        return itemLayout;
    }
}
