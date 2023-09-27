package com.tencent.qcloud.tuikit.timcommon.component.activities;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.component.TitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.component.gatherimage.SynthesizedImageView;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import java.io.File;
import java.io.Serializable;
import java.util.List;

public class ImageSelectActivity extends BaseLightActivity {
    private static final String TAG = ImageSelectActivity.class.getSimpleName();

    public static final int RESULT_CODE_ERROR = -1;
    public static final int RESULT_CODE_SUCCESS = 0;
    public static final String TITLE = "title";
    public static final String SPAN_COUNT = "spanCount";
    public static final String DATA = "data";
    public static final String ITEM_HEIGHT = "itemHeight";
    public static final String ITEM_WIDTH = "itemWidth";
    public static final String SELECTED = "selected";
    public static final String PLACEHOLDER = "placeholder";
    public static final String NEED_DOWNLOAD_LOCAL = "needDownload";

    private int defaultSpacing;

    private List<ImageBean> data;
    private ImageBean selected;
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
        titleBarLayout.setTitle(getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.getRightTitle().setTextColor(0xFF006EFF);
        titleBarLayout.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setResult(RESULT_CODE_ERROR);
                finish();
            }
        });
        boolean needDownload = intent.getBooleanExtra(NEED_DOWNLOAD_LOCAL, false);
        titleBarLayout.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (selected == null) {
                    return;
                }
                if (needDownload) {
                    downloadUrl();
                } else {
                    Intent resultIntent = new Intent();
                    resultIntent.putExtra(DATA, (Serializable) selected);
                    setResult(RESULT_CODE_SUCCESS, resultIntent);
                    finish();
                }
            }
        });

        data = (List<ImageBean>) intent.getSerializableExtra(DATA);
        selected = (ImageBean) intent.getSerializableExtra(SELECTED);
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
            public void onClick(ImageBean obj) {
                selected = obj;
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

    private void downloadUrl() {
        if (selected == null) {
            return;
        }

        if (selected.isDefault()) {
            selected.setLocalPath(TUIConstants.TUIChat.CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL);
            setResult(selected);
            ToastUtil.toastShortMessage(getResources().getString(R.string.setting_success));
            finish();
            return;
        }

        String url = selected.getImageUri();
        if (TextUtils.isEmpty(url)) {
            Log.d(TAG, "DownloadUrl is null");
            return;
        }

        final ProgressDialog dialog = new ProgressDialog(this);
        dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        dialog.setCancelable(false);
        dialog.setCanceledOnTouchOutside(false);
        dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                // TODO Auto-generated method stub
                finish();
            }
        });
        dialog.setMessage(getResources().getString(R.string.setting));
        dialog.show();

        ImageBean finalBean = selected;
        Glide.with(this)
            .downloadOnly()
            .load(url)
            .listener(new RequestListener<File>() {
                @Override
                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<File> target, boolean isFirstResource) {
                    dialog.cancel();
                    Log.e(TAG, "DownloadUrl onLoadFailed e = " + e);
                    ToastUtil.toastShortMessage(getResources().getString(R.string.setting_fail));
                    return false;
                }

                @Override
                public boolean onResourceReady(File resource, Object model, Target<File> target, DataSource dataSource, boolean isFirstResource) {
                    dialog.cancel();
                    String path = resource.getAbsolutePath();
                    Log.e(TAG, "DownloadUrl resource path = " + path);
                    finalBean.setLocalPath(path);
                    setResult(finalBean);
                    ToastUtil.toastShortMessage(getResources().getString(R.string.setting_success));
                    return false;
                }
            })
            .preload();
    }

    private void setResult(ImageBean bean) {
        Intent resultIntent = new Intent();
        resultIntent.putExtra(DATA, (Serializable) bean);
        setResult(RESULT_CODE_SUCCESS, resultIntent);
        finish();
    }

    private void setSelectedStatus() {
        if (selected != null && data != null && data.contains(selected)) {
            titleBarLayout.getRightTitle().setEnabled(true);
            titleBarLayout.getRightTitle().setTextColor(
                getResources().getColor(TUIThemeManager.getAttrResId(this, com.tencent.qcloud.tuicore.R.attr.core_primary_color)));
        } else {
            titleBarLayout.getRightTitle().setEnabled(false);
            titleBarLayout.getRightTitle().setTextColor(0xFF666666);
        }
        gridAdapter.setSelected(selected);
    }

    public static class ImageGridAdapter extends RecyclerView.Adapter<ImageGridAdapter.ImageViewHolder> {
        private int itemWidth;
        private int itemHeight;

        private List<ImageBean> data;
        private ImageBean selected;
        private int placeHolder;
        private OnItemClickListener onItemClickListener;

        public void setData(List<ImageBean> data) {
            this.data = data;
        }

        public void setSelected(ImageBean selected) {
            if (data == null || data.isEmpty()) {
                this.selected = selected;
            } else {
                this.selected = selected;
                notifyDataSetChanged();
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
            ImageBean imageBean = data.get(position);
            if (selected != null && imageBean != null && TextUtils.equals(selected.getThumbnailUri(), imageBean.getThumbnailUri())) {
                holder.selectBorderLayout.setVisibility(View.VISIBLE);
            } else {
                holder.selectBorderLayout.setVisibility(View.GONE);
            }

            if (imageBean.getGroupGridAvatar() != null) {
                holder.defaultLayout.setVisibility(View.GONE);
                if (imageView instanceof SynthesizedImageView) {
                    SynthesizedImageView synthesizedImageView = ((SynthesizedImageView) (imageView));
                    String imageId = imageBean.getImageId();
                    synthesizedImageView.setImageId(imageId);
                    synthesizedImageView.displayImage(imageBean.getGroupGridAvatar()).load(imageId);
                }
            } else if (imageBean.isDefault()) {
                holder.defaultLayout.setVisibility(View.VISIBLE);
                imageView.setImageResource(android.R.color.transparent);
            } else {
                holder.defaultLayout.setVisibility(View.GONE);
                Glide.with(holder.itemView.getContext())
                    .asBitmap()
                    .load(imageBean.getThumbnailUri())
                    .placeholder(placeHolder)
                    .apply(new RequestOptions().error(placeHolder))
                    .into(imageView);
            }

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onClick(imageBean);
                    }
                }
            });
        }

        private void setItemLayoutParams(ImageViewHolder holder) {
            if (itemHeight > 0 && itemWidth > 0) {
                ViewGroup.LayoutParams itemViewLayoutParams = holder.itemView.getLayoutParams();
                itemViewLayoutParams.width = itemWidth;
                itemViewLayoutParams.height = itemHeight;
                holder.itemView.setLayoutParams(itemViewLayoutParams);

                ViewGroup.LayoutParams params = holder.imageView.getLayoutParams();
                params.width = itemWidth;
                params.height = itemHeight;
                holder.imageView.setLayoutParams(params);

                ViewGroup.LayoutParams borderLayoutParams = holder.selectBorderLayout.getLayoutParams();
                borderLayoutParams.width = itemWidth;
                borderLayoutParams.height = itemHeight;
                holder.selectBorderLayout.setLayoutParams(borderLayoutParams);

                ViewGroup.LayoutParams borderParams = holder.selectedBorder.getLayoutParams();
                borderParams.width = itemWidth;
                borderParams.height = itemHeight;
                holder.selectedBorder.setLayoutParams(borderParams);
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
            private final ImageView selectedBorder;
            private final RelativeLayout selectBorderLayout;
            private final Button defaultLayout;

            public ImageViewHolder(@NonNull View itemView) {
                super(itemView);
                imageView = itemView.findViewById(R.id.content_image);
                selectedBorder = itemView.findViewById(R.id.select_border);
                selectBorderLayout = itemView.findViewById(R.id.selected_border_area);
                defaultLayout = itemView.findViewById(R.id.default_image_layout);
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

            int left = column * leftRightSpace / columnNum;
            int right = leftRightSpace * (columnNum - 1 - column) / columnNum;
            if (LayoutUtil.isRTL()) {
                outRect.left = right;
                outRect.right = left;
            } else {
                outRect.left = left;
                outRect.right = right;
            }
            // add top spacing
            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }
    }

    public interface OnItemClickListener {
        void onClick(ImageBean obj);
    }

    public static class ImageBean implements Serializable {
        String thumbnailUri; // for display
        String imageUri; // for download
        String localPath; // for local path
        boolean isDefault = false; // for default display
        List<Object> groupGridAvatar = null; // for group grid avatar
        String imageId;

        public ImageBean() {}

        public ImageBean(String thumbnailUri, String imageUri, boolean isDefault) {
            this.thumbnailUri = thumbnailUri;
            this.imageUri = imageUri;
            this.isDefault = isDefault;
        }

        public String getImageUri() {
            return imageUri;
        }

        public String getThumbnailUri() {
            return thumbnailUri;
        }

        public void setImageUri(String imageUri) {
            this.imageUri = imageUri;
        }

        public void setThumbnailUri(String thumbnailUri) {
            this.thumbnailUri = thumbnailUri;
        }

        public String getLocalPath() {
            return localPath;
        }

        public void setLocalPath(String localPath) {
            this.localPath = localPath;
        }

        public boolean isDefault() {
            return isDefault;
        }

        public void setDefault(boolean aDefault) {
            isDefault = aDefault;
        }

        public List<Object> getGroupGridAvatar() {
            return groupGridAvatar;
        }

        public void setGroupGridAvatar(List<Object> groupGridAvatar) {
            this.groupGridAvatar = groupGridAvatar;
        }

        public String getImageId() {
            return imageId;
        }

        public void setImageId(String imageId) {
            this.imageId = imageId;
        }
    }
}