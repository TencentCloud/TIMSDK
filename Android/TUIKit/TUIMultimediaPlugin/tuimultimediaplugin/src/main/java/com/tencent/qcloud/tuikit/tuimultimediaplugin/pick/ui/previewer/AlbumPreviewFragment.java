package com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.ui.previewer;

import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.VideoView;

import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDialog;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager2.widget.ViewPager2;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.BucketBean;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.interfaces.AlbumClickListener;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.ui.picker.AlbumGridView;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.ui.previewer.SelectedPhotosView;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.utils.TUIMultimediaCoreUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaMediaProcessor;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaAuthorizationPrompter;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.BaseBean;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.VideoBean;

import java.util.List;

public class AlbumPreviewFragment extends DialogFragment {
    private static final String TAG = "AlbumPreviewActivity";
    private static final int TYPE_IMAGE = 0;
    private static final int TYPE_VIDEO = 1;

    private View rootView;
    private ImageView backButton;
    private TextView titleTv;
    private View selectButton;
    private ImageView selectCheckbox;
    private TextView editButton;
    private TextView sendButton;
    private ImageView fullImageCheckbox;
    private View fullImageButton;

    private PreviewAdapter adapter;
    private ViewPager2 viewPager2;
    private SelectedPhotosView selectedPhotosView;
    private BaseBean currentBean;
    private AlbumGridView albumGridView;
    private View.OnClickListener onSendClickListener;
    private View.OnClickListener onFullImageClickListener;
    private View.OnClickListener onSelectClickListener;
    private List<BaseBean> previewList;
    private boolean isFullImage = false;
    private BaseBean previewBean;
    private BucketBean bucketBean;

    public void setOnSendClickListener(View.OnClickListener onSendClickListener) {
        this.onSendClickListener = onSendClickListener;
    }

    public void setOnFullImageClickListener(View.OnClickListener onFullImageClickListener) {
        this.onFullImageClickListener = onFullImageClickListener;
    }

    public void setOnSelectClickListener(View.OnClickListener onSelectClickListener) {
        this.onSelectClickListener = onSelectClickListener;
    }

    public void setBucketBean(BucketBean bucketBean) {
        this.bucketBean = bucketBean;
    }

    public void setPreviewBean(BaseBean previewBean) {
        this.previewBean = previewBean;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        setRetainInstance(true);
        Dialog dialog = new AppCompatDialog(getContext(), R.style.AlbumTransparentPopStyle);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        Window window = dialog.getWindow();
        if (window != null) {
            window.setBackgroundDrawable(new ColorDrawable());
            window.getDecorView().setPadding(0, 0, 0, 0);
            int color = getResources().getColor(R.color.multimedia_plugin_picker_dark_color);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
                window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                window.setStatusBarColor(color);
                window.setNavigationBarColor(color);
            }
            WindowManager.LayoutParams lp = window.getAttributes();
            lp.width = WindowManager.LayoutParams.MATCH_PARENT;
            lp.height = WindowManager.LayoutParams.MATCH_PARENT;
            window.setAttributes(lp);
        }
        return dialog;
    }

    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.multimedia_plugin_picker_preview_layout, container, false);
        backButton = rootView.findViewById(R.id.back_button);
        backButton.getDrawable().setAutoMirrored(true);
        titleTv = rootView.findViewById(R.id.preview_title);
        selectedPhotosView = rootView.findViewById(R.id.selected_list);
        selectButton = rootView.findViewById(R.id.select_button);
        selectCheckbox = rootView.findViewById(R.id.select_checkbox);
        sendButton = rootView.findViewById(R.id.send_button);
        fullImageCheckbox = rootView.findViewById(R.id.full_image_checkbox);
        fullImageButton = rootView.findViewById(R.id.full_image_button);
        editButton = rootView.findViewById(R.id.edit_button);
        if (!TUIMultimediaIConfig.getInstance().isSupportAlbumPickerEdit() ||
                !TUIMultimediaAuthorizationPrompter.isShowAdvanceFunction()) {
            editButton.setVisibility(View.GONE);
        }

        if (!TUIMultimediaIConfig.getInstance().isSupportAlbumPickerTranscodeSelect() ||
                !TUIMultimediaAuthorizationPrompter.isShowAdvanceFunction()) {
            fullImageButton.setVisibility(View.GONE);
        }

        setData();
        setOnClickListener();
        return rootView;
    }

    public void setAlbumGridView(AlbumGridView albumGridView) {
        this.albumGridView = albumGridView;
    }

    public void setFullImage(boolean fullImage) {
        this.isFullImage = fullImage;
    }

    private void setData() {
        BaseBean previewBean = this.previewBean;
        currentBean = previewBean;
        if (previewBean == null) {
            previewList = albumGridView.getSelectedPhotoList();
            currentBean = previewList.get(0);
        } else {
            previewList = bucketBean.albumList;
        }
        adapter = new PreviewAdapter();
        adapter.data = previewList;
        viewPager2 = rootView.findViewById(R.id.view_pager);
        viewPager2.setOrientation(ViewPager2.ORIENTATION_HORIZONTAL);
        viewPager2.setAdapter(adapter);

        int index = previewList.indexOf(previewBean);
        titleTv.setText(index + 1 + "/" + previewList.size());
        viewPager2.setCurrentItem(index, false);
        viewPager2.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                titleTv.setText(position + 1 + "/" + previewList.size());
                currentBean = previewList.get(position);
                selectedPhotosView.switchPhoto(currentBean);
                setSelectCheckboxBg();
            }
        });
        selectedPhotosView.setPhotoList(albumGridView.getSelectedPhotoList());
        selectedPhotosView.switchPhoto(currentBean);
        selectedPhotosView.setAlbumClickListener(new AlbumClickListener() {
            @Override
            public void onClick(BaseBean bean) {
                switchToPage(bean);
            }

            @Override
            public void onSelectChanged(BaseBean bean) {

            }

        });
        setFullImageCheckboxState();
        setSelectCheckboxBg();
    }

    private void setFullImageCheckboxState() {
        if (this.isFullImage) {
            fullImageCheckbox.setSelected(true);
        } else {
            fullImageCheckbox.setSelected(false);
        }
    }

    private void switchToPage(BaseBean bean) {
        List<BaseBean> beanList = adapter.data;
        int index = beanList.indexOf(bean);
        if (index >= 0) {
            currentBean = bean;
            viewPager2.setCurrentItem(index, false);
        }
    }

    private void setOnClickListener() {
        backButton.setOnClickListener((v) -> dismiss());
        selectButton.setOnClickListener((v) -> toggleSelected());
        fullImageButton.setOnClickListener((v) -> toggleFullImage());
        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (albumGridView.getSelectedPhotoList().isEmpty()) {
                    albumGridView.setSelected(currentBean, true);
                }
                if (onSendClickListener != null) {
                    onSendClickListener.onClick(v);
                }
            }
        });
        selectedPhotosView.setClickListener(new AlbumClickListener() {
            @Override
            public void onClick(BaseBean bean) {
                if (!isAdded()) {
                    return;
                }
                switchToPage(bean);
            }

            @Override
            public void onSelectChanged(BaseBean bean) {

            }
        });
        editButton.setOnClickListener((v) -> {
            Context context = getContext();
            if (!(context instanceof ActivityResultCaller) || !isAdded()) {
                return;
            }
            Uri editUri = currentBean.getFinalUri();
            TUIMultimediaMediaProcessor.getInstance().editMedia(context, editUri, uri -> {
                if (uri != null) {
                    for (BaseBean baseBean : previewList) {
                        if (baseBean.getFinalUri() == editUri) {
                            baseBean.editedUri = uri;
                            albumGridView.freshPhoto(baseBean);
                            selectedPhotosView.freshPhoto(baseBean);
                            adapter.freshPhoto(baseBean);
                            break;
                        }
                    }
                }
            });
        });
    }

    private void toggleFullImage() {
        this.isFullImage = !this.isFullImage;
        setFullImageCheckboxState();
        if (onFullImageClickListener != null) {
            onFullImageClickListener.onClick(fullImageButton);
        }
    }

    private void toggleSelected() {
        boolean valid = TUIMultimediaCoreUtil.checkSize(currentBean.getFinalUri());
        if (!valid) {
            return;
        }
        if (currentBean.isSelected) {
            albumGridView.setSelected(currentBean, false);
            selectedPhotosView.removePhoto(currentBean);
        } else {
            albumGridView.setSelected(currentBean, true);
            selectedPhotosView.addPhoto(currentBean);
        }
        if (onSelectClickListener != null) {
            onSelectClickListener.onClick(selectButton);
        }
        setSelectCheckboxBg();
    }

    private void setSelectCheckboxBg() {
        if (currentBean.isSelected) {
            selectCheckbox.setBackgroundResource(R.drawable.multimedia_plugin_picker_preview_selected_checkbox_bg);
            selectCheckbox.setImageResource(R.drawable.multimedia_plugin_picker_preview_selected_tick_icon);
        } else {
            selectCheckbox.setBackgroundResource(R.drawable.multimedia_plugin_picker_select_gray_ring_bg);
            selectCheckbox.setImageResource(0);
        }
        List<BaseBean> selectedSet = albumGridView.getSelectedPhotoList();
        if (selectedSet.isEmpty()) {
            sendButton.setText(getString(R.string.multimedia_plugin_picker_send));
        } else {
            sendButton.setText(getString(R.string.multimedia_plugin_picker_send) + "(" + selectedSet.size() + ")");
        }
        if (!selectedSet.isEmpty()) {
            selectedPhotosView.setVisibility(View.VISIBLE);
        } else {
            selectedPhotosView.setVisibility(View.GONE);
        }
    }

    static class PreviewAdapter extends RecyclerView.Adapter<PreviewViewHolder> {
        public List<BaseBean> data;

        @Override
        public PreviewViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view;
            if (viewType == TYPE_VIDEO) {
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.multimedia_plugin_picker_preview_video_item_layout, parent, false);
                return new PreviewVideoHolder(view);
            } else {
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.multimedia_plugin_picker_preview_image_item_layout, parent, false);
                return new PreviewImageHolder(view);
            }
        }

        @Override
        public void onBindViewHolder(PreviewViewHolder holder, int position) {
            BaseBean bean = data.get(position);
            holder.bind(bean);
        }

        @Override
        public int getItemCount() {
            if (data == null) {
                return 0;
            } else {
                return data.size();
            }
        }

        @Override
        public int getItemViewType(int position) {
            BaseBean baseBean = data.get(position);
            if (baseBean instanceof VideoBean) {
                return TYPE_VIDEO;
            } else {
                return TYPE_IMAGE;
            }
        }

        public void freshPhoto(BaseBean bean) {
            if (data != null && bean != null) {
                int index = data.indexOf(bean);
                if (index != -1) {
                    notifyItemChanged(index);
                }
            }
        }
    }

    static class PreviewViewHolder extends RecyclerView.ViewHolder {
        public PreviewViewHolder(View itemView) {
            super(itemView);
        }

        public void bind(BaseBean bean) {}
    }

    static class PreviewImageHolder extends PreviewViewHolder {
        ImageView imageView;
        public PreviewImageHolder(View itemView) {
            super(itemView);
            imageView = itemView.findViewById(R.id.image_view);
        }

        @Override
        public void bind(BaseBean bean) {
            Glide.with(itemView.getContext())
                .load(bean.getFinalUri())
                .diskCacheStrategy(DiskCacheStrategy.NONE)
                .skipMemoryCache(true)
                .dontTransform()
                .dontAnimate()
                .into(imageView);
        }
    }

    static class PreviewVideoHolder extends PreviewViewHolder {
        VideoView videoView;
        View playButton;
        ImageView previewImage;
        public PreviewVideoHolder(View itemView) {
            super(itemView);
            videoView = itemView.findViewById(R.id.video_view);
            playButton = itemView.findViewById(R.id.play_button);
            previewImage = itemView.findViewById(R.id.video_preview_image_view);
        }

        @Override
        public void bind(BaseBean bean) {
            itemView.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
                @Override
                public void onViewAttachedToWindow(@NonNull View v) {}

                @Override
                public void onViewDetachedFromWindow(@NonNull View v) {
                    if (videoView.isPlaying()) {
                        videoView.stopPlayback();
                    }
                    playButton.setVisibility(View.VISIBLE);
                    previewImage.setVisibility(View.VISIBLE);
                }
            });
            Uri uri = bean.getFinalUri();
            Glide.with(itemView.getContext()).load(uri).into(previewImage);
            videoView.setVideoURI(uri);
            playButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    playButton.setVisibility(View.GONE);
                    previewImage.setVisibility(View.GONE);
                    videoView.start();
                }
            });
        }
    }
}
