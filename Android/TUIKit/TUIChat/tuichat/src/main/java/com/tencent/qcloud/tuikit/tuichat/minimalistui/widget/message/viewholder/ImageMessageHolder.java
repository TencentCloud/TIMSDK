package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.Nullable;

import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.ImageVideoScanActivity;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ImageMessageHolder extends MessageContentHolder {
    protected static final int DEFAULT_MAX_SIZE = 540;
    protected static final int DEFAULT_RADIUS = 0;
    protected final List<String> downloadEles = new ArrayList<>();
    public RoundCornerImageView contentImage;
    protected ImageView videoPlayBtn;
    private String mImagePath = null;

    public ImageMessageHolder(View itemView) {
        super(itemView);
        contentImage = itemView.findViewById(R.id.content_image_iv);
        videoPlayBtn = itemView.findViewById(R.id.video_play_btn);
        timeInLineTextLayout = itemView.findViewById(R.id.image_msg_time_in_line_text);
        timeInLineTextLayout.setTimeColor(0xFFFFFFFF);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_message_adapter_content_image;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        performImage((ImageMessageBean) msg, position);
    }

    private ViewGroup.LayoutParams getImageParams(ViewGroup.LayoutParams params, final ImageMessageBean msg) {
        if (msg.getImgWidth() == 0 || msg.getImgHeight() == 0) {
            params.width = DEFAULT_MAX_SIZE;
            params.height = DEFAULT_MAX_SIZE;
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

    private void performImage(final ImageMessageBean msg, final int position) {
        contentImage.setLayoutParams(getImageParams(contentImage.getLayoutParams(), msg));
        videoPlayBtn.setVisibility(View.GONE);

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
                    if (!path.equals(mImagePath)) {
                        GlideEngine.clear(contentImage);
                    }
                    img.downloadImage(path, new ImageMessageBean.ImageBean.ImageDownloadCallback() {
                        @Override
                        public void onProgress(long currentSize, long totalSize) {
                            TUIChatLog.i("downloadImage progress current:", currentSize + ", total:" + totalSize);
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
        if (isMultiSelectMode) {
            contentImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, position, msg);
                    }
                }
            });
        } else {
            contentImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent(TUIChatService.getAppContext(), ImageVideoScanActivity.class);
                    intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
                    if (isForwardMode) {
                        if (getDataSource() != null && !getDataSource().isEmpty()) {
                            intent.putExtra(TUIChatConstants.OPEN_MESSAGES_SCAN_FORWARD, (Serializable) getDataSource());
                        }
                    }

                    intent.putExtra(TUIChatConstants.OPEN_MESSAGE_SCAN, msg);
                    intent.putExtra(TUIChatConstants.FORWARD_MODE, isForwardMode);
                    TUIChatService.getAppContext().startActivity(intent);
                }
            });
            contentImage.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageLongClick(msgArea, position, msg);
                    }
                    return true;
                }
            });
        }
        setImagePadding(msg);
    }

    protected void setImagePadding(TUIMessageBean messageBean) {
        int padding = ScreenUtil.dip2px(1);
        msgArea.setPadding(padding, padding, padding, padding);
    }

    @Override
    protected void optimizeMessageContent(boolean isShowAvatar) {
        if (!isShowAvatar) {
            contentImage.setRadius(ScreenUtil.dip2px(16));
        } else {
            if (isShowStart) {
                contentImage.setRadius(ScreenUtil.dip2px(16));
                contentImage.setLeftBottomRadius(0);
            } else {
                contentImage.setRadius(ScreenUtil.dip2px(16));
                contentImage.setRightBottomRadius(0);
            }
        }
    }

    @Override
    public void setHighLightBackground(int color) {
        Drawable drawable = contentImage.getDrawable();
        if (drawable != null) {
            drawable.setColorFilter(color, PorterDuff.Mode.SRC_ATOP);
        }
    }

    @Override
    public void clearHighLightBackground() {
        Drawable drawable = contentImage.getDrawable();
        if (drawable != null) {
            drawable.setColorFilter(null);
        }
    }
}
