package com.tencent.liteav.demo.beauty.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.tencent.liteav.demo.beauty.model.BeautyInfo;
import com.tencent.liteav.demo.beauty.model.TabInfo;
import com.tencent.liteav.demo.beauty.utils.BeautyUtils;

public class TabAdapter extends BaseAdapter implements View.OnClickListener {

    private Context             mContext;
    private BeautyInfo          mBeautyInfo;
    private TextView            mTextSelected;
    private OnTabChangeListener mTabClickListener;

    public interface OnTabChangeListener {
        void onTabChange(TabInfo tabInfo, int position);
    }

    public TabAdapter(Context context, BeautyInfo beautyInfo) {
        mContext = context;
        mBeautyInfo = beautyInfo;
    }

    @Override
    public int getCount() {
        return mBeautyInfo.getBeautyTabList().size();
    }

    @Override
    public TabInfo getItem(int position) {
        return mBeautyInfo.getBeautyTabList().get(position);
    }

    @Override
    public long getItemId(int position) {
        return mBeautyInfo.getBeautyTabList().get(position).getTabId();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        TextView tabView;
        if (convertView == null) {
            tabView = new TextView(mContext);
            BeautyUtils.setTextViewColor(tabView, mBeautyInfo.getBeautyTabNameColorNormal());
            BeautyUtils.setTextViewSize(tabView, mBeautyInfo.getBeautyTabNameSize());
            ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(mBeautyInfo.getBeautyTabNameWidth(), mBeautyInfo.getBeautyTabNameHeight());
            tabView.setLayoutParams(layoutParams);
        } else {
            tabView = (TextView) convertView;
        }
        if (position == 0) {
            tabView.setPadding(BeautyUtils.dip2px(mContext, 20), 0, BeautyUtils.dip2px(mContext, 11), BeautyUtils.dip2px(mContext, 30));
        } else {
            tabView.setPadding(BeautyUtils.dip2px(mContext, 12), 0, BeautyUtils.dip2px(mContext, 11), BeautyUtils.dip2px(mContext, 30));
        }
        BeautyUtils.setTextViewText(tabView, getItem(position).getTabName());
        tabView.setTag(position);
        tabView.setOnClickListener(this);
        if (position == 0) {
            setCurrentPosition(0, tabView);
        }
        return tabView;
    }

    @Override
    public void onClick(View view) {
        int index = (int) view.getTag();
        setCurrentPosition(index, view);
    }

    private void setCurrentPosition(int position, View view) {
        if (mTextSelected != null) {
            BeautyUtils.setTextViewColor(mTextSelected, mBeautyInfo.getBeautyTabNameColorNormal());
        }
        mTextSelected = (TextView) view;
        BeautyUtils.setTextViewColor(mTextSelected, mBeautyInfo.getBeautyTabNameColorSelect());
        if (mTabClickListener != null) {
            mTabClickListener.onTabChange(getItem(position), position);
        }
    }

    public void setOnTabClickListener(OnTabChangeListener tabClickListener) {
        mTabClickListener = tabClickListener;
    }
}
