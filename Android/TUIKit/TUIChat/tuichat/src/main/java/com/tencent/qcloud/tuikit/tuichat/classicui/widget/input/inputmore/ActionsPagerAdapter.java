package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.inputmore;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;

import java.util.ArrayList;
import java.util.List;

import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;


public class ActionsPagerAdapter extends PagerAdapter {

    private final int ITEM_COUNT_PER_GRID_VIEW = 8;
    private final int COLUMN_COUNT = 4;
    private final Context mContext;
    private final List<InputMoreActionUnit> mInputMoreList;
    private final ViewPager mViewPager;
    private final int mGridViewCount;
    private int actionWidth, actionHeight;

    public ActionsPagerAdapter(ViewPager mViewPager, List<InputMoreActionUnit> mInputMoreList) {
        this.mContext = mViewPager.getContext();
        this.mInputMoreList = new ArrayList<>(mInputMoreList);
        this.mViewPager = mViewPager;
        this.mGridViewCount = (mInputMoreList.size() + ITEM_COUNT_PER_GRID_VIEW - 1) / ITEM_COUNT_PER_GRID_VIEW;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        int end = (position + 1) * ITEM_COUNT_PER_GRID_VIEW > mInputMoreList.size()
                ? mInputMoreList.size() : (position + 1) * ITEM_COUNT_PER_GRID_VIEW;
        List<InputMoreActionUnit> subBaseActions = mInputMoreList.subList(position
                * ITEM_COUNT_PER_GRID_VIEW, end);

        GridView gridView = new GridView(mContext);
        gridView.setAdapter(new ActionsGridViewAdapter(mContext, subBaseActions));
        if (mInputMoreList.size() >= COLUMN_COUNT) {
            gridView.setNumColumns(COLUMN_COUNT);

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
        gridView.setHorizontalSpacing(60);
        gridView.setVerticalSpacing(60);
        gridView.setGravity(Gravity.CENTER);
        gridView.setTag(Integer.valueOf(position));
        gridView.setOnItemClickListener(new GridView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                int index = ((Integer) parent.getTag()) * ITEM_COUNT_PER_GRID_VIEW + position;
                mInputMoreList.get(index).getOnClickListener().onClick();
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
