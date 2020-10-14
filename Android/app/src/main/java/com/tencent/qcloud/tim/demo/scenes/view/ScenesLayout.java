package com.tencent.qcloud.tim.demo.scenes.view;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.fragment.app.FragmentTransaction;
import androidx.viewpager.widget.ViewPager;

import com.google.android.material.tabs.TabLayout;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.scenes.BaseScenesFragment;
import com.tencent.qcloud.tim.demo.scenes.LiveRoomFragment;

import java.util.ArrayList;
import java.util.List;

public class ScenesLayout extends RelativeLayout {

    private static final String TAG = ScenesLayout.class.getSimpleName();
    private Context mContext;

    private TabLayout mTabLayout;
    private ViewPager mViewPager;

    public ScenesLayout(@NonNull Context context) {
        super(context);
        initialize(context);
    }

    public ScenesLayout(@NonNull Context context, AttributeSet attrs) {
        super(context, attrs);
        initialize(context);
    }

    public ScenesLayout(@NonNull Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initialize(context);
    }

    private void initialize(@NonNull Context context) {
        mContext = context;
        inflate(mContext, R.layout.live_layout_scenes, this);

        mTabLayout = findViewById(R.id.live_scenes_tab);
        mViewPager = findViewById(R.id.live_scenes_pager);
    }

    public void setFragmentManager(@NonNull FragmentManager manager) {
        List<TabPagerModel> tabPagerModels = new ArrayList<>();
        tabPagerModels.add(new TabPagerModel(new LiveRoomFragment(), getResources().getString(R.string.live_scenes_live_room)));
        PagerAdapter adapter = new PagerAdapter(manager, tabPagerModels);
        FragmentTransaction fragmentTransaction = manager.beginTransaction();
        fragmentTransaction.commit();
        mViewPager.setAdapter(adapter);
        mTabLayout.setupWithViewPager(mViewPager);
    }

    private static class PagerAdapter extends FragmentPagerAdapter {

        private List<TabPagerModel> mTabPagerModels;

        public PagerAdapter(@NonNull FragmentManager fm, @NonNull List<TabPagerModel> tabPagerModels) {
            super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
            mTabPagerModels = tabPagerModels;
        }

        @NonNull
        @Override
        public Fragment getItem(int position) {
            return mTabPagerModels.get(position).fragment;
        }

        @Override
        public int getCount() {
            return mTabPagerModels.size();
        }

        @Nullable
        @Override
        public CharSequence getPageTitle(int position) {
            return mTabPagerModels.get(position).title;
        }
    }

    private static class TabPagerModel {
        public BaseScenesFragment fragment;
        public String title;

        TabPagerModel(BaseScenesFragment fragment, String title) {
            this.fragment = fragment;
            this.title = title;
        }
    }
}
