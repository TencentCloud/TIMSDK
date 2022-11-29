package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityBean;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.ui.interfaces.ICommunityGroupIconList;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.TUICommunityFragment;

import java.util.List;

public class CommunityGroupList extends RecyclerView implements ICommunityGroupIconList {

    private CommunityGroupIconListAdapter adapter;
    private LinearLayoutManager layoutManager;
    private CommunityPresenter presenter;
    private TUICommunityFragment.OnCommunityClickListener onCommunityClickListener;

    public CommunityGroupList(@NonNull Context context) {
        super(context);
        init();
    }

    public CommunityGroupList(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CommunityGroupList(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        adapter = new CommunityGroupIconListAdapter();
        layoutManager = new LinearLayoutManager(getContext());
        addItemDecoration(new SpacingDecorate());
        setLayoutManager(layoutManager);
        setAdapter(adapter);
    }

    public void setPresenter(CommunityPresenter presenter) {
        this.presenter = presenter;
        this.presenter.setGroupIconList(this);
    }

    public void setOnCommunityClickListener(TUICommunityFragment.OnCommunityClickListener onCommunityClickListener) {
        this.onCommunityClickListener = onCommunityClickListener;
        adapter.setOnCommunityClickListener(onCommunityClickListener);
    }

    @Override
    public void onJoinedCommunityChanged(List<CommunityBean> communityBeanList) {
        adapter.setData(communityBeanList);
    }

    @Override
    public void onItemRangeChanged(int index, int count) {
        adapter.notifyItemRangeChanged(index, count);
    }

    @Override
    public void onItemInserted(int index) {
        adapter.notifyItemInserted(index);
    }

    @Override
    public void onItemChanged(int index) {
        adapter.notifyItemChanged(index);
    }

    @Override
    public void onItemRemoved(int index) {
        adapter.notifyItemRemoved(index);
    }

    public void setSelectedPosition(int position) {
        if (adapter != null) {
            adapter.setSelectedPosition(position);
            adapter.notifyItemChanged(position);
        }
    }

    public void clearSelected() {
        if (adapter != null) {
            int position = adapter.getSelectedPosition();
            adapter.setSelectedPosition(-1);
            adapter.notifyItemChanged(position);
        }
    }

    static class SpacingDecorate extends ItemDecoration {
        @Override
        public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull State state) {
            outRect.top = ScreenUtil.dip2px(20);
        }
    }

    static class CommunityGroupIconListAdapter extends Adapter<CommunityGroupIconListAdapter.CommunityGroupIconViewHolder> {

        private List<CommunityBean> data;
        private TUICommunityFragment.OnCommunityClickListener onCommunityClickListener;
        private int selectedPosition = -1;
        public void setData(List<CommunityBean> data) {
            this.data = data;
        }

        public void setOnCommunityClickListener(TUICommunityFragment.OnCommunityClickListener onCommunityClickListener) {
            this.onCommunityClickListener = onCommunityClickListener;
        }

        public void setSelectedPosition(int selectedPosition) {
            this.selectedPosition = selectedPosition;
        }

        public int getSelectedPosition() {
            return selectedPosition;
        }

        @NonNull
        @Override
        public CommunityGroupIconViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.community_group_icon_item_layout, parent, false);
            return new CommunityGroupIconViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull CommunityGroupIconViewHolder holder, int position) {
            CommunityBean communityBean = data.get(position);
            GlideEngine.loadImageSetDefault(holder.imageView, communityBean.getGroupFaceUrl(),
                    TUIThemeManager.getAttrResId(holder.itemView.getContext(), com.tencent.qcloud.tuicore.R.attr.core_default_group_icon_community));
            if (position == selectedPosition) {
                holder.selectedBorder.setVisibility(VISIBLE);
            } else {
                holder.selectedBorder.setVisibility(GONE);
            }
            holder.itemView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onCommunityClickListener != null) {
                        onCommunityClickListener.onClick(communityBean);
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            if (data == null || data.isEmpty()) {
                return 0;
            }
            return data.size();
        }

        static class CommunityGroupIconViewHolder extends ViewHolder {
            private final ImageView imageView;
            private final View selectedBorder;
            public CommunityGroupIconViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.face_url);
                selectedBorder = itemView.findViewById(R.id.selected_border_view);
            }
        }
    }
}
