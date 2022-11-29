package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.Nullable;

import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuicore.component.imageEngine.impl.GlideEngine;
import com.tencent.qcloud.tuicore.util.ImageUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.List;

public class ImageReplyQuoteView extends TUIReplyQuoteView {
    protected View imageMsgLayout;
    protected ImageView imageMsgIv;
    protected ImageView videoPlayIv;

    protected static final int DEFAULT_RADIUS = 2;
    protected final List<String> downloadEles = new ArrayList<>();
    protected String mImagePath = null;

    public ImageReplyQuoteView(Context context) {
        super(context);
        imageMsgLayout = findViewById(R.id.image_msg_layout);
        imageMsgIv = findViewById(R.id.image_msg_iv);
        videoPlayIv = findViewById(R.id.video_play_iv);
    }

    @Override
    public int getLayoutResourceId() {
        return R.layout.chat_reply_quote_image_layout;
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {
        ImageMessageBean messageBean = (ImageMessageBean) quoteBean.getMessageBean();
        imageMsgLayout.setVisibility(View.VISIBLE);
        imageMsgIv.setLayoutParams(getImageParams(imageMsgIv.getLayoutParams(), messageBean.getImgWidth(), messageBean.getImgHeight()));
        final List<ImageMessageBean.ImageBean> imgs = messageBean.getImageBeanList();
        String imagePath = messageBean.getDataPath();
        String originImagePath = TUIChatUtils.getOriginImagePath(messageBean);
        if (!TextUtils.isEmpty(originImagePath)) {
            imagePath = originImagePath;
        }
        if (!TextUtils.isEmpty(imagePath)) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(imageMsgIv, imagePath, null, DEFAULT_RADIUS);
        } else {
            GlideEngine.clear(imageMsgIv);
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
                        GlideEngine.clear(imageMsgIv);
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
                            messageBean.setDataPath(path);
                            GlideEngine.loadCornerImageWithoutPlaceHolder(imageMsgIv, messageBean.getDataPath(), new RequestListener() {
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
    }

    protected ViewGroup.LayoutParams getImageParams(ViewGroup.LayoutParams params, int width, int height) {

        if (width == 0 || height == 0) {
            return params;
        }
        int maxSize = getResources().getDimensionPixelSize(R.dimen.reply_message_image_size);
        if (width > height) {
            params.width = maxSize;
            params.height = maxSize * height / width;
        } else {
            params.width = maxSize * width / height;
            params.height = maxSize;
        }
        return params;
    }
}
