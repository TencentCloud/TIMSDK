package com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore;


import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;

import java.util.List;

public class ActionsGridViewAdapter extends BaseAdapter {

    private Context context;

    private List<InputMoreActionUnit> baseActions;

    public ActionsGridViewAdapter(Context context, List<InputMoreActionUnit> baseActions) {
        this.context = context;
        this.baseActions = baseActions;
    }

    @Override
    public int getCount() {
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
        View itemlayout;
        if (convertView == null) {
            itemlayout = LayoutInflater.from(context).inflate(R.layout.chat_input_layout_actoin, parent, false);
        } else {
            itemlayout = convertView;
        }

        InputMoreActionUnit action = baseActions.get(position);
        if (action.getIconResId() > 0)
            ((ImageView) itemlayout.findViewById(R.id.imageView)).setImageResource(action.getIconResId());
        if (action.getTitleId() > 0)
            ((TextView) itemlayout.findViewById(R.id.textView)).setText(context.getString(action.getTitleId()));
        return itemlayout;
    }
}

