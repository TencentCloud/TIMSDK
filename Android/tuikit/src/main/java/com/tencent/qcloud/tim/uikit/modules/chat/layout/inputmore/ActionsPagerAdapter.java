package com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;

import com.tencent.qcloud.tim.uikit.R;

import java.util.ArrayList;
import java.util.List;


public class ActionsPagerAdapter extends PagerAdapter {

    private final int ITEM_COUNT_PER_GRID_VIEW = 4;
    private final Context mContext;
    private int actionWidth, actionHeight;

    private final List<InputMoreActionUnit> mInputMoreList;
    private final ViewPager mViewPager;
    private final int mGridViewCount;

    public ActionsPagerAdapter(ViewPager mViewPager, List<InputMoreActionUnit> mInputMoreList) {
        this.mContext = mViewPager.getContext();
        this.mInputMoreList = new ArrayList<>(mInputMoreList);
        this.mViewPager = mViewPager;
        this.mGridViewCount = (mInputMoreList.size() + ITEM_COUNT_PER_GRID_VIEW - 1) / ITEM_COUNT_PER_GRID_VIEW;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        int end = (position + 1) * ITEM_COUNT_PER_GRID_VIEW > mInputMoreList.size() ? mInputMoreList
                .size() : (position + 1) * ITEM_COUNT_PER_GRID_VIEW;
        List<InputMoreActionUnit> subBaseActions = mInputMoreList.subList(position
                * ITEM_COUNT_PER_GRID_VIEW, end);

        GridView gridView = new GridView(mContext);
        gridView.setAdapter(new ActionsGridViewAdapter(mContext, subBaseActions));
        if (mInputMoreList.size() >= 4) {
            gridView.setNumColumns(4);

            container.post(new Runnable() {
                @Override
                public void run() {
                    ViewGroup.LayoutParams layoutParams = mViewPager.getLayoutParams();
                    layoutParams.height = actionHeight;
                    mViewPager.setLayoutParams(layoutParams);
                }
            });
        } else {
            gridView.setNumColumns(mInputMoreList.size());

            container.post(new Runnable() {
                @Override
                public void run() {
                    ViewGroup.LayoutParams layoutParams = mViewPager.getLayoutParams();
                    layoutParams.height = actionHeight;
                    mViewPager.setLayoutParams(layoutParams);
                }
            });
        }
        gridView.setSelector(R.color.transparent);
        gridView.setHorizontalSpacing(0);
        gridView.setVerticalSpacing(0);
        gridView.setGravity(Gravity.CENTER);
        gridView.setTag(Integer.valueOf(position));
        gridView.setOnItemClickListener(new GridView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                int index = ((Integer) parent.getTag()) * ITEM_COUNT_PER_GRID_VIEW + position;
                mInputMoreList.get(index).getOnClickListener().onClick(view);
            }
        });

        container.addView(gridView);
        return gridView;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        // TODO
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view == object;
    }

    @Override
    public int getCount() {
        return mGridViewCount;
    }

    @Override
    public int getItemPosition(Object object) {
        return POSITION_NONE;
    }
}
