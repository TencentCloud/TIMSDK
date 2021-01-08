package com.tencent.liteav.demo.beauty.adapter;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.tencent.liteav.demo.beauty.model.BeautyInfo;
import com.tencent.liteav.demo.beauty.model.TabInfo;
import com.tencent.liteav.demo.beauty.utils.BeautyUtils;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.utils.UIUtil;

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
        if (view instanceof TextView) {
            setCurrentPosition(index, (TextView) view);
        }
    }

    private void setCurrentPosition(int position, TextView view) {
        if (mTextSelected != null) {
            BeautyUtils.setTextViewColor(mTextSelected, mBeautyInfo.getBeautyTabNameColorNormal());
            mTextSelected.setCompoundDrawablesWithIntrinsicBounds(null,null,null,null);
        }
        mTextSelected = (TextView) view;
        BeautyUtils.setTextViewColor(mTextSelected, mBeautyInfo.getBeautyTabNameColorSelect());
        Drawable drawable= mContext.getResources().getDrawable(R.drawable.live_tab_view_select);
        view.setCompoundDrawablesWithIntrinsicBounds(null,null,null,drawable);
        if (mTabClickListener != null) {
            mTabClickListener.onTabChange(getItem(position), position);
        }
    }

    public void setOnTabClickListener(OnTabChangeListener tabClickListener) {
        mTabClickListener = tabClickListener;
    }
}
