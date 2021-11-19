package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.content.Intent;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.photoview.PhotoViewActivity;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.List;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

public class ImageMessageHolder extends MessageContentHolder {

    private static final int DEFAULT_MAX_SIZE = 540;
    private static final int DEFAULT_RADIUS = 10;
    private final List<String> downloadEles = new ArrayList<>();
    private ImageView contentImage;
    private ImageView videoPlayBtn;
    private TextView videoDurationText;
    private String mImagePath = null;

    public ImageMessageHolder(View itemView) {
        super(itemView);
        contentImage = itemView.findViewById(R.id.content_image_iv);
        videoPlayBtn = itemView.findViewById(R.id.video_play_btn);
        videoDurationText = itemView.findViewById(R.id.video_duration_tv);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_image;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        msgContentFrame.setBackground(null);
        performImage((ImageMessageBean) msg, position);
    }

    private ViewGroup.LayoutParams getImageParams(ViewGroup.LayoutParams params, final ImageMessageBean msg) {
        if (msg.getImgWidth() == 0 || msg.getImgHeight() == 0) {
            return params;
        }
        if (msg.getImgWidth() > msg.getImgHeight()) {
            params.width = DEFAULT_MAX_SIZE;
            params.height = DEFAULT_MAX_SIZE * msg.getImgHeight() / msg.getImgWidth();
        } else {
            params.width = DEFAULT_MAX_SIZE * msg.getImgWidth() / msg.getImgHeight();
            params.height = DEFAULT_MAX_SIZE;
        }
        return params;
    }

    private void resetParentLayout() {
        ((FrameLayout) contentImage.getParent().getParent()).setPadding(17, 0, 13, 0);
    }

    private void performImage(final ImageMessageBean msg, final int position) {
        contentImage.setLayoutParams(getImageParams(contentImage.getLayoutParams(), msg));
        resetParentLayout();
        videoPlayBtn.setVisibility(View.GONE);
        videoDurationText.setVisibility(View.GONE);


        final List<ImageMessageBean.ImageBean> imgs = msg.getImageBeanList();
        String imagePath = msg.getDataPath();
        String originImagePath = TUIChatUtils.getOriginImagePath(msg);
        if (!TextUtils.isEmpty(originImagePath)) {
            imagePath = originImagePath;
        }
        if (!TextUtils.isEmpty(imagePath)) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, imagePath, null, DEFAULT_RADIUS);
        } else {
            GlideEngine.clear(contentImage);
            for (int i = 0; i < imgs.size(); i++) {
                final ImageMessageBean.ImageBean img = imgs.get(i);
                if (img.getType() == ImageMessageBean.IMAGE_TYPE_THUMB) {
                    synchronized (downloadEles) {
                        if (downloadEles.contains(img.getUUID())) {
                            break;
                        }
                        downloadEles.add(img.getUUID());
                    }
                    final String path = ImageUtil.generateImagePath(img.getUUID(), ImageMessageBean.IMAGE_TYPE_THUMB);
                    // 如果contentImage的路径和当前图片路径不同，说明图片未加载过或者recyclerView复用了之前的缓存，为了避免显示错乱需要清空
                    if (!path.equals(mImagePath)) {
                        GlideEngine.clear(contentImage);
                    }
                    img.downloadImage(path, new ImageMessageBean.ImageBean.ImageDownloadCallback() {
                        @Override
                        public void onProgress(long currentSize, long totalSize) {
                            TUIChatLog.i("downloadImage progress current:",
                                    currentSize + ", total:" + totalSize);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            downloadEles.remove(img.getUUID());
                            TUIChatLog.e("MessageAdapter img getImage", code + ":" + desc);
                        }

                        @Override
                        public void onSuccess() {
                            downloadEles.remove(img.getUUID());
                            msg.setDataPath(path);
                            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, msg.getDataPath(), new RequestListener() {
                                @Override
                                public boolean onLoadFailed(@Nullable GlideException e, Object model, Target target, boolean isFirstResource) {
                                    mImagePath = null;
                                    return false;
                                }

                                @Override
                                public boolean onResourceReady(Object resource, Object model, Target target, DataSource dataSource, boolean isFirstResource) {
                                    mImagePath = path;
                                    return false;
                                }
                            }, DEFAULT_RADIUS);
                        }
                    });
                    break;
                }
            }
        }
        contentImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String localImgPath = TUIChatUtils.getOriginImagePath(msg);
                boolean isOriginImg = localImgPath != null;
                // 点击后的预览图片路径 如果是原图直接放原图，否则用缩略图
                String previewImgPath = localImgPath;
                for (int i = 0; i < imgs.size(); i++) {
                    ImageMessageBean.ImageBean img = imgs.get(i);
                    if (img.getType() == ImageMessageBean.IMAGE_TYPE_ORIGIN) {
                        PhotoViewActivity.mCurrentOriginalImage = img.getV2TIMImage();
                    }
                    if (img.getType() == ImageMessageBean.IMAGE_TYPE_THUMB) {
                        if (!isOriginImg) {
                            previewImgPath = ImageUtil.generateImagePath(img.getUUID(), ImageMessageBean.IMAGE_TYPE_THUMB);
                        }
                    }
                }
                Intent intent = new Intent(TUIChatService.getAppContext(), PhotoViewActivity.class);
                intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
                intent.putExtra(TUIChatConstants.IMAGE_PREVIEW_PATH, previewImgPath);
                intent.putExtra(TUIChatConstants.IS_ORIGIN_IMAGE, isOriginImg);
                TUIChatService.getAppContext().startActivity(intent);
            }
        });
        contentImage.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View view) {
                if (onItemLongClickListener != null) {
                    onItemLongClickListener.onMessageLongClick(view, position, msg);
                }
                return true;
            }
        });
    }

}
