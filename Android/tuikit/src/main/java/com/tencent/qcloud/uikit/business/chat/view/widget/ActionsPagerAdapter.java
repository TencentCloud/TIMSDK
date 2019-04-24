package com.tencent.qcloud.uikit.business.chat.view.widget;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;

import com.tencent.qcloud.uikit.R;

import java.util.ArrayList;
import java.util.List;


public class ActionsPagerAdapter extends PagerAdapter {

    private final int ITEM_COUNT_PER_GRID_VIEW = 4;
    private final Context context;
    private int actionWidth, actionHeight;

    private final List<MessageOperaUnit> actions;
    private final ViewPager viewPager;
    private final int gridViewCount;

    public ActionsPagerAdapter(ViewPager viewPager, List<MessageOperaUnit> actions) {
        this.context = viewPager.getContext();
        this.actions = new ArrayList<>(actions);
        this.viewPager = viewPager;
        this.gridViewCount = (actions.size() + ITEM_COUNT_PER_GRID_VIEW - 1) / ITEM_COUNT_PER_GRID_VIEW;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        int end = (position + 1) * ITEM_COUNT_PER_GRID_VIEW > actions.size() ? actions
                .size() : (position + 1) * ITEM_COUNT_PER_GRID_VIEW;
        List<MessageOperaUnit> subBaseActions = actions.subList(position
                * ITEM_COUNT_PER_GRID_VIEW, end);

        GridView gridView = new GridView(context);
        gridView.setAdapter(new ActionsGridviewAdapter(context, subBaseActions));
        if (actions.size() >= 4) {
            gridView.setNumColumns(4);

            container.post(new Runnable() {
                @Override
                public void run() {
                    ViewGroup.LayoutParams layoutParams = viewPager.getLayoutParams();
                    layoutParams.height = actionHeight;
                    viewPager.setLayoutParams(layoutParams);
                }
            });
        } else {
            gridView.setNumColumns(actions.size());

            container.post(new Runnable() {
                @Override
                public void run() {
                    ViewGroup.LayoutParams layoutParams = viewPager.getLayoutParams();
                    layoutParams.height = actionHeight;
                    viewPager.setLayoutParams(layoutParams);
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
                actions.get(index).getOnClickListener().onClick(view);
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
        return gridViewCount;
    }

    @Override
    public int getItemPosition(Object object) {
        return POSITION_NONE;
    }
}
