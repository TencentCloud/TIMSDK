package com.tencent.qcloud.tuicore.component.activities;


import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

import java.io.Serializable;
import java.util.List;


public class ImageSelectActivity extends BaseLightActivity {
    public static final int RESULT_CODE_ERROR = -1;
    public static final int RESULT_CODE_SUCCESS = 0;
    public static final String TITLE = "title";
    public static final String SPAN_COUNT = "spanCount";
    public static final String DATA = "data";
    public static final String ITEM_HEIGHT = "itemHeight";
    public static final String ITEM_WIDTH = "itemWidth";
    public static final String SELECTED = "selected";
    public static final String PLACEHOLDER = "placeholder";

    private int defaultSpacing;

    private List<Object> data;
    private Object selected;
    private int placeHolder;
    private int columnNum;
    private RecyclerView imageGrid;
    private GridLayoutManager gridLayoutManager;
    private ImageGridAdapter gridAdapter;
    private TitleBarLayout titleBarLayout;
    private int itemHeight;
    private int itemWidth;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        defaultSpacing = ScreenUtil.dip2px(12);
        setContentView(R.layout.core_activity_image_select_layout);
        Intent intent = getIntent();
        String title = intent.getStringExtra(TITLE);
        titleBarLayout = findViewById(R.id.image_select_title);
        titleBarLayout.setTitle(title, ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.setTitle(getString(R.string.sure), ITitleBarLayout.Position.RIGHT);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.getRightTitle().setTextColor(0xFF006EFF);
        titleBarLayout.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setResult(RESULT_CODE_ERROR);
                finish();
            }
        });
        titleBarLayout.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (selected == null) {
                    return;
                }
                Intent resultIntent = new Intent();
                resultIntent.putExtra(DATA, (Serializable) selected);
                setResult(RESULT_CODE_SUCCESS, resultIntent);
                finish();
            }
        });

        data = (List<Object>) intent.getSerializableExtra(DATA);
        selected = intent.getSerializableExtra(SELECTED);
        placeHolder = intent.getIntExtra(PLACEHOLDER, 0);
        itemHeight = intent.getIntExtra(ITEM_HEIGHT, 0);
        itemWidth = intent.getIntExtra(ITEM_WIDTH, 0);
        columnNum = intent.getIntExtra(SPAN_COUNT, 2);
        gridLayoutManager = new GridLayoutManager(this, columnNum);
        imageGrid = findViewById(R.id.image_select_grid);
        imageGrid.addItemDecoration(new GridDecoration(columnNum, defaultSpacing, defaultSpacing));
        imageGrid.setLayoutManager(gridLayoutManager);
        imageGrid.setItemAnimator(null);
        gridAdapter = new ImageGridAdapter();
        gridAdapter.setPlaceHolder(placeHolder);
        gridAdapter.setSelected(selected);
        gridAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onClick(Object obj) {
                if (selected != null && selected.equals(obj)) {
                    selected = null;
                } else {
                    selected = obj;
                }
                setSelectedStatus();
            }
        });
        gridAdapter.setItemWidth(itemWidth);
        gridAdapter.setItemHeight(itemHeight);
        imageGrid.setAdapter(gridAdapter);
        gridAdapter.setData(data);
        setSelectedStatus();
        gridAdapter.notifyDataSetChanged();
    }

    private void setSelectedStatus() {
        if (selected != null && data != null && data.contains(selected)) {
            titleBarLayout.getRightTitle().setEnabled(true);
            titleBarLayout.getRightTitle().setTextColor(getResources().getColor(TUIThemeManager.getAttrResId(this, R.attr.core_primary_color)));
        } else {
            titleBarLayout.getRightTitle().setEnabled(false);
            titleBarLayout.getRightTitle().setTextColor(0xFF666666);
        }
        gridAdapter.setSelected(selected);
    }

    public static class ImageGridAdapter extends RecyclerView.Adapter<ImageGridAdapter.ImageViewHolder> {
        private int itemWidth;
        private int itemHeight;

        private List<Object> data;
        private Object selected;
        private int placeHolder;
        private OnItemClickListener onItemClickListener;

        public void setData(List<Object> data) {
            this.data = data;
        }

        public void setSelected(Object selected) {
            if (data == null || data.isEmpty()) {
                this.selected = selected;
            } else {
                int beforeSelectedIndex = data.indexOf(this.selected);
                notifyItemChanged(beforeSelectedIndex);
                this.selected = selected;
                int currentSelectedIndex = data.indexOf(this.selected);
                notifyItemChanged(currentSelectedIndex);
            }
        }

        public void setPlaceHolder(int placeHolder) {
            this.placeHolder = placeHolder;
        }

        public void setItemHeight(int itemHeight) {
            this.itemHeight = itemHeight;
        }

        public void setItemWidth(int itemWidth) {
            this.itemWidth = itemWidth;
        }

        public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
            this.onItemClickListener = onItemClickListener;
        }

        @NonNull
        @Override
        public ImageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.core_select_image_item_layout, parent, false);
            return new ImageViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ImageViewHolder holder, int position) {
            ImageView imageView = holder.imageView;
            setItemLayoutParams(holder);
            Object obj = data.get(position);
            if (selected != null && selected.equals(obj)) {
                holder.selectBorder.setVisibility(View.VISIBLE);
            } else {
                holder.selectBorder.setVisibility(View.GONE);
            }
            Glide.with(holder.itemView.getContext()).asBitmap()
                    .load(obj)
                    .placeholder(placeHolder)
                    .apply(new RequestOptions().error(placeHolder))
                    .into(imageView);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onClick(obj);
                    }
                }
            });
        }

        private void setItemLayoutParams(ImageViewHolder holder) {
            if (itemHeight > 0 && itemWidth > 0) {
                ViewGroup.LayoutParams params = holder.imageView.getLayoutParams();
                params.width = itemWidth;
                params.height = itemHeight;
                holder.imageView.setLayoutParams(params);

                ViewGroup.LayoutParams borderLayoutParams = holder.selectBorder.getLayoutParams();
                borderLayoutParams.width = itemWidth;
                borderLayoutParams.height = itemHeight;
                holder.selectBorder.setLayoutParams(borderLayoutParams);
            }
        }

        @Override
        public int getItemCount() {
            if (data == null || data.isEmpty()) {
                return 0;
            }
            return data.size();
        }

        public static class ImageViewHolder extends RecyclerView.ViewHolder {
            private final ImageView imageView;
            private final RelativeLayout selectBorder;

            public ImageViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.content_image);
                selectBorder = itemView.findViewById(R.id.selected_border_view);
            }
        }
    }

    /**
     * add spacing
     */
    public static class GridDecoration extends RecyclerView.ItemDecoration {

        private final int columnNum; // span count
        private final int leftRightSpace; // vertical spacing
        private final int topBottomSpace; // horizontal spacing

        public GridDecoration(int columnNum, int leftRightSpace, int topBottomSpace) {
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            outRect.left = column * leftRightSpace / columnNum;
            outRect.right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            // add top spacing
            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }
    }

    public interface OnItemClickListener {
        void onClick(Object obj);
    }
}