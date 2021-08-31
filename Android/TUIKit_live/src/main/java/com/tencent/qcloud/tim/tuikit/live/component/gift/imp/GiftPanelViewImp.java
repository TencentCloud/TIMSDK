package com.tencent.qcloud.tim.tuikit.live.component.gift.imp;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager.widget.ViewPager;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.component.gift.GiftPanelDelegate;
import com.tencent.qcloud.tim.tuikit.live.component.gift.IGiftPanelView;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.adapter.GiftPanelAdapter;
import com.tencent.qcloud.tim.tuikit.live.component.gift.imp.adapter.GiftViewPagerAdapter;

import java.util.ArrayList;
import java.util.List;

public class GiftPanelViewImp extends BottomSheetDialog implements IGiftPanelView {
    private static final String TAG = "GiftPanelViewImp";

    private int COLUMNS = 4;
    private int ROWS = 2;

    private Context mContext;
    private List<View> mGiftViews;     //每页显示的礼物view
    private GiftController mGiftController;
    private LayoutInflater mInflater;
    private LinearLayout mDotsLayout;
    private ViewPager mViewpager;
    private GiftPanelDelegate mGiftPanelDelegate;
    private GiftInfoDataHandler mGiftInfoDataHandler;

    public GiftPanelViewImp(Context context) {
        super(context, R.style.live_action_sheet_theme);
        mContext = context;
        mGiftViews = new ArrayList<>();
        setContentView(R.layout.live_dialog_gift_panel);
        initView();
    }

    private void initView() {
        mInflater = LayoutInflater.from(mContext);
        mViewpager = findViewById(R.id.gift_panel_view_pager);
        mDotsLayout = findViewById(R.id.dots_container);
        findViewById(R.id.btn_charge).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mGiftPanelDelegate != null) {
                    Log.d(TAG, "on charge btn click");
                    mGiftPanelDelegate.onChargeClick();
                }
            }
        });
        findViewById(R.id.btn_send_gift).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mGiftController == null) {
                    return;
                }
                GiftInfo giftInfo = mGiftController.getSelectGiftInfo();
                if (giftInfo != null && mGiftPanelDelegate != null) {
                    Log.d(TAG, "onGiftItemClick: " + giftInfo);
                    mGiftPanelDelegate.onGiftItemClick(giftInfo);
                }
            }
        });
        setCanceledOnTouchOutside(true);
    }

    /**
     * 初始化礼物面板
     */
    private void initGiftData(List<GiftInfo> giftInfoList) {
        if (mGiftController == null) {
            mGiftController = new GiftController();
        }
        int pageSize = mGiftController.getPagerCount(giftInfoList.size(), COLUMNS, ROWS);
        // 获取页数
        for (int i = 0; i < pageSize; i++) {
            mGiftViews.add(mGiftController.viewPagerItem(mContext, i, giftInfoList, COLUMNS, ROWS));
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(16, 16);
            params.setMargins(10, 0, 10, 0);
            if (pageSize > 1) {
                mDotsLayout.addView(dotsItem(i), params);
            }
        }
        if (pageSize > 1) {
            mDotsLayout.setVisibility(View.VISIBLE);
        } else {
            mDotsLayout.setVisibility(View.GONE);
        }
        GiftViewPagerAdapter giftViewPagerAdapter = new GiftViewPagerAdapter(mGiftViews);
        mViewpager.setAdapter(giftViewPagerAdapter);
        mViewpager.addOnPageChangeListener(new PageChangeListener());
        mViewpager.setCurrentItem(0);
        if (pageSize > 1) {
            mDotsLayout.getChildAt(0).setSelected(true);
        }
    }

    /**
     * 礼物页切换时，底部小圆点
     *
     * @param position
     * @return
     */
    private ImageView dotsItem(int position) {
        View layout = mInflater.inflate(R.layout.live_layout_gift_dot, null);
        ImageView iv = (ImageView) layout.findViewById(R.id.face_dot);
        iv.setId(position);
        return iv;
    }

    /**
     * 礼物页改变时，dots效果也要跟着改变
     */
    class PageChangeListener implements ViewPager.OnPageChangeListener {

        @Override
        public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
        }

        @Override
        public void onPageSelected(int position) {
            for (int i = 0; i < mDotsLayout.getChildCount(); i++) {
                mDotsLayout.getChildAt(i).setSelected(false);
            }
            mDotsLayout.getChildAt(position).setSelected(true);
            for (int i = 0; i < mGiftViews.size(); i++) {//清除选中，当礼物页面切换到另一个礼物页面
                RecyclerView view = (RecyclerView) mGiftViews.get(i);
                GiftPanelAdapter adapter = (GiftPanelAdapter) view.getAdapter();
                if (mGiftController != null) {
                    int selectPageIndex = mGiftController.getSelectPageIndex();
                    adapter.clearSelection(selectPageIndex);
                }
            }
        }

        @Override
        public void onPageScrollStateChanged(int state) {

        }
    }

    @Override
    public void init(GiftInfoDataHandler giftInfoDataHandler) {
        mGiftInfoDataHandler = giftInfoDataHandler;
    }

    @Override
    public void show() {
        super.show();
        if (mGiftInfoDataHandler != null) {
            mGiftInfoDataHandler.queryGiftInfoList(new GiftInfoDataHandler.GiftQueryCallback() {
                @Override
                public void onQuerySuccess(final List<GiftInfo> giftInfoList) {
                    //确保更新UI数据在主线程中执行
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            initGiftData(giftInfoList);
                        }
                    });
                }

                @Override
                public void onQueryFailed(String errorMsg) {
                    Log.d(TAG, "request data failed, the message:" + errorMsg);
                }
            });
        }
    }

    @Override
    public void hide() {
        dismiss();
    }

    @Override
    public void setGiftPanelDelegate(GiftPanelDelegate delegate) {
        mGiftPanelDelegate = delegate;
    }
}
