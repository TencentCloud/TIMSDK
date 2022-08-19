package com.tencent.qcloud.tuikit.tuicommunity.component.banner;

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.LinearSmoothScroller;
import androidx.recyclerview.widget.PagerSnapHelper;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.BackgroundTasks;
import com.tencent.qcloud.tuikit.tuicommunity.R;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;


public class BannerView extends FrameLayout {

    private static final int DEFAULT_INTERVAL = 3000;  // 1s

    private RecyclerView bannerList;
    private BannerIndicatorView bannerIndicatorView;
    private LinearLayoutManager bannerLayoutManager;
    private BannerAdapter bannerListAdapter;
    private List<BannerItem> bannerData;

    private int oldFacePageIndex = 0;
    private int interval = DEFAULT_INTERVAL;
    private Timer switchTimer;
    public BannerView(Context context) {
        super(context);
        init(context, null);
    }

    public BannerView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public BannerView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public BannerView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        View view = LayoutInflater.from(context).inflate(R.layout.community_banner_view_layout, this);
        bannerList = view.findViewById(R.id.banner_list);
        bannerIndicatorView = view.findViewById(R.id.banner_indicator);
        bannerLayoutManager = new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false) {
            @Override
            public void smoothScrollToPosition(RecyclerView recyclerView, RecyclerView.State state,
                                               int position) {
                LinearSmoothScroller linearSmoothScroller = new LinearSmoothScroller(recyclerView.getContext()) {
                    @Override
                    protected int calculateTimeForScrolling(int dx) {
                        return super.calculateTimeForScrolling(dx) * 9;
                    }
                };
                linearSmoothScroller.setTargetPosition(position);
                startSmoothScroll(linearSmoothScroller);
            }
        };
        PagerSnapHelper pagerSnapHelper = new PagerSnapHelper();
        bannerList.setLayoutManager(bannerLayoutManager);
        pagerSnapHelper.attachToRecyclerView(bannerList);
        bannerListAdapter = new BannerAdapter();
        bannerList.setAdapter(bannerListAdapter);
        bannerList.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                int currentFacePageIndex;
                if (dx >= 0) {
                    currentFacePageIndex = bannerLayoutManager.findLastVisibleItemPosition();
                } else {
                    currentFacePageIndex = bannerLayoutManager.findFirstVisibleItemPosition();
                }
                // the page is not be selected
                if (currentFacePageIndex == RecyclerView.NO_POSITION || oldFacePageIndex == currentFacePageIndex) {
                    return;
                }
                bannerIndicatorView.playBy(oldFacePageIndex % bannerData.size(), currentFacePageIndex % bannerData.size());
                oldFacePageIndex = currentFacePageIndex;
            }
        });
    }

    public void setBannerData(List<BannerItem> data) {
        bannerData = data;
        bannerIndicatorView.init(data.size());
        bannerListAdapter.notifyDataSetChanged();
        switchTimer = new Timer();
        switchTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                BackgroundTasks.getInstance().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        int nextIndex = oldFacePageIndex + 1;
                        bannerList.smoothScrollToPosition(nextIndex);
                    }
                });
            }
        }, interval, interval);
    }

    public static class BannerItem {
        private Object imageUri;
        private OnClickListener onClickListener;

        public void setImageUri(Object imageUri) {
            this.imageUri = imageUri;
        }

        public void setOnClickListener(OnClickListener onClickListener) {
            this.onClickListener = onClickListener;
        }
    }

    class BannerAdapter extends RecyclerView.Adapter<BannerAdapter.BannerViewHolder> {
        @NonNull
        @Override
        public BannerViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.community_banner_item_view_layout, parent, false);
            return new BannerViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull BannerViewHolder holder, int position) {
            int realPosition = position % bannerData.size();
            holder.itemView.setOnClickListener(bannerData.get(realPosition).onClickListener);
            GlideEngine.loadImage(holder.imageView, bannerData.get(realPosition).imageUri);
        }

        @Override
        public int getItemCount() {
            if (bannerData == null || bannerData.isEmpty()) {
                return 0;
            }
            return Integer.MAX_VALUE;
        }

        class BannerViewHolder extends RecyclerView.ViewHolder {
            private final ImageView imageView;
            public BannerViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.image);
            }
        }
    }
}
