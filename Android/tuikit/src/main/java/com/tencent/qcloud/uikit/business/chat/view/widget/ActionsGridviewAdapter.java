package com.tencent.qcloud.uikit.business.chat.view.widget;


import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.uikit.R;

import java.util.List;

public class ActionsGridviewAdapter extends BaseAdapter {

    private Context context;

    private List<MessageOperaUnit> baseActions;

    public ActionsGridviewAdapter(Context context, List<MessageOperaUnit> baseActions) {
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
            itemlayout = LayoutInflater.from(context).inflate(R.layout.chat_bottom_actoin, parent, false);
        } else {
            itemlayout = convertView;
        }

        MessageOperaUnit action = baseActions.get(position);
        if (action.getIconResId() > 0)
            ((ImageView) itemlayout.findViewById(R.id.imageView)).setImageResource(action.getIconResId());
        if (action.getTitleId() > 0)
            ((TextView) itemlayout.findViewById(R.id.textView)).setText(context.getString(action.getTitleId()));
        return itemlayout;
    }
}

