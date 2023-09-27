package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply;

import android.content.Context;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.TUIReplyQuoteView;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class ImageReplyQuoteView extends TUIReplyQuoteView {
    protected static final int DEFAULT_RADIUS = 2;

    protected ImageView imageMsgIv;
    protected ImageView videoPlayIv;

    private TUIValueCallback downloadImageCallback;

    public ImageReplyQuoteView(Context context) {
        super(context);
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
        imageMsgIv.setLayoutParams(getImageParams(imageMsgIv.getLayoutParams(), messageBean.getImgWidth(), messageBean.getImgHeight()));
        String imagePath = ChatFileDownloadPresenter.getImagePath(messageBean);
        if (FileUtil.isFileExists(imagePath)) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(imageMsgIv, imagePath, null, DEFAULT_RADIUS);
        } else {
            GlideEngine.clear(imageMsgIv);
            downloadImageCallback = new TUIValueCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    TUIChatLog.i("downloadImage progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.e("MessageAdapter img getImage", code + ":" + desc);
                }

                @Override
                public void onSuccess(Object obj) {
                    GlideEngine.loadCornerImageWithoutPlaceHolder(imageMsgIv, imagePath, null, DEFAULT_RADIUS);
                }
            };
            ChatFileDownloadPresenter.downloadImage(messageBean, downloadImageCallback);
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
