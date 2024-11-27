package com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.ui.picker;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.ColorFilter;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.VectorDrawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.SimpleItemAnimator;
import androidx.vectordrawable.graphics.drawable.VectorDrawableCompat;

import com.bumptech.glide.Glide;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.BaseBean;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.BucketBean;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.interfaces.OnSelectedBucketChangedListener;

import java.util.List;

public class BucketListPop extends FrameLayout {
    private static final int DEFAULT_ANIM_DURATION = 200;

    private RecyclerView bucketList;
    private BucketAdapter adapter;
    private LinearLayoutManager layoutManager;

    private List<BucketBean> data;
    private OnSelectedBucketChangedListener onSelectedBucketChangedListener;

    private int listHeight = -1;
    private boolean isShowing = false;
    private BucketBean bucketBean;

    public BucketListPop(@NonNull Context context) {
        super(context);
        init();
    }

    public BucketListPop(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public BucketListPop(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    public void setSelectedBucketBean(BucketBean bucketBean) {
        this.bucketBean = bucketBean;
    }

    public void setData(List<BucketBean> data) {
        this.data = data;
        adapter.notifyDataSetChanged();
    }

    public void setOnSelectedBucketChangedListener(OnSelectedBucketChangedListener listener) {
        this.onSelectedBucketChangedListener = listener;
    }

    private void init() {
        View view = LayoutInflater.from(getContext()).inflate(R.layout.multimedia_plugin_picker_bucket_pop_layout, this, true);
        bucketList = view.findViewById(R.id.bucket_list);
        SimpleItemAnimator animator = (SimpleItemAnimator) bucketList.getItemAnimator();
        if (animator != null) {
            animator.setSupportsChangeAnimations(false);
        }
        bucketList.setItemAnimator(null);
        adapter = new BucketAdapter();
        layoutManager = new LinearLayoutManager(getContext());
        bucketList.setAdapter(adapter);
        bucketList.setLayoutManager(layoutManager);
        view.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
        setAlpha(0);
    }

    public void show() {
        setVisibility(VISIBLE);
        post(() -> {
            if (listHeight < 0) {
                listHeight = bucketList.getHeight();
            }
            changeHeightWithAnim(0, listHeight, null);
            isShowing = true;
            this.animate().alpha(1).setDuration(DEFAULT_ANIM_DURATION).start();
        });
    }

    public void dismiss() {
        changeHeightWithAnim(bucketList.getHeight(), 0, () -> {
            isShowing = false;
            setVisibility(GONE);
        });
        this.animate().alpha(0).setDuration(DEFAULT_ANIM_DURATION).start();
    }

    private void changeHeightWithAnim(int from, int to, Runnable onFinished) {
        ValueAnimator animator = ValueAnimator.ofInt(from, to);
        animator.setDuration(DEFAULT_ANIM_DURATION);
        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                ViewGroup.LayoutParams layoutParams = bucketList.getLayoutParams();
                layoutParams.height = (int) animation.getAnimatedValue();
                bucketList.setLayoutParams(layoutParams);
            }
        });
        animator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationCancel(Animator animation) {
                if (onFinished != null) {
                    onFinished.run();
                }
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                if (onFinished != null) {
                    onFinished.run();
                }
            }
        });
        animator.start();
    }

    public boolean isShowing() {
        return isShowing;
    }

    class BucketAdapter extends RecyclerView.Adapter<BucketViewHolder> {

        @NonNull
        @Override
        public BucketViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.multimedia_plugin_picker_bucket_pop_list_item_layout, parent, false);
            return new BucketViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull BucketViewHolder holder, int position) {
            BucketBean bucketBean = data.get(position);
            holder.bucketBean = bucketBean;
            String bucketName = bucketBean.bucketName;
            List<BaseBean> beanList = bucketBean.albumList;
            if (BucketListPop.this.bucketBean == bucketBean) {
                holder.selectedIcon.setVisibility(VISIBLE);
            } else {
                holder.selectedIcon.setVisibility(GONE);
            }
            int size;
            BaseBean bean = null;
            if (beanList == null || beanList.isEmpty()) {
                size = 0;
            } else {
                size = beanList.size();
                bean = beanList.get(0);
                Glide.with(holder.bucketIcon).asBitmap().load(bean).into(holder.bucketIcon);
            }
            holder.bucketNameTv.setText(bucketName + "");
            holder.bucketCountTv.setText("(" + size + ")");
            holder.itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    BucketListPop.this.bucketBean = bucketBean;
                    if (onSelectedBucketChangedListener != null) {
                        onSelectedBucketChangedListener.onSelectedBucketChanged(bucketBean);
                    }
                    notifyItemRangeChanged(0, getItemCount());
                    dismiss();
                }
            });
        }

        @Override
        public int getItemCount() {
            if (data == null) {
                return 0;
            }
            return data.size();
        }
    }

    static class BucketViewHolder extends RecyclerView.ViewHolder {
        ImageView bucketIcon;
        TextView bucketNameTv;
        TextView bucketCountTv;
        ImageView selectedIcon;
        BucketBean bucketBean;

        public BucketViewHolder(@NonNull View itemView) {
            super(itemView);
            bucketIcon = itemView.findViewById(R.id.bucket_icon);
            bucketNameTv = itemView.findViewById(R.id.bucket_name_tv);
            bucketCountTv = itemView.findViewById(R.id.bucket_count_tv);
            selectedIcon = itemView.findViewById(R.id.selected_icon);
            Drawable drawable = selectedIcon.getDrawable();
            if (drawable instanceof VectorDrawable) {
                int color = itemView.getContext().getResources().getColor(
                        TUIThemeManager.getAttrResId(itemView.getContext(), com.tencent.qcloud.tuicore.R.attr.core_primary_color));
                ColorFilter filter = new PorterDuffColorFilter(color, PorterDuff.Mode.SRC_IN);
                drawable.setColorFilter(filter);
            }
        }
    }
}
