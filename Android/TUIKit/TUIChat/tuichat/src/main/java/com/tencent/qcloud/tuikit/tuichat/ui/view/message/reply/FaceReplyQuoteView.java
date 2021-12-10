package com.tencent.qcloud.tuikit.tuichat.ui.view.message.reply;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FaceReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

public class FaceReplyQuoteView extends TUIReplyQuoteView {
    private final ImageView contentImage;

    @Override
    public int getLayoutResourceId() {
        return R.layout.chat_reply_quote_face_layout;
    }

    public FaceReplyQuoteView(Context context) {
        super(context);
        contentImage = findViewById(R.id.content_image_iv);
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {
        FaceReplyQuoteBean faceReplyQuoteBean = (FaceReplyQuoteBean) quoteBean;

        String filter = new String(faceReplyQuoteBean.getData());
        if (!filter.contains("@2x")) {
            filter += "@2x";
        }
        Bitmap bitmap = FaceManager.getCustomBitmap(faceReplyQuoteBean.getIndex(), filter);
        if (bitmap == null) {
            // 自定义表情没有找到，用emoji再试一次
            bitmap = FaceManager.getEmoji(new String(faceReplyQuoteBean.getData()));

        }
        if (bitmap != null) {
            contentImage.setLayoutParams(getImageParams(contentImage.getLayoutParams(), bitmap.getWidth(), bitmap.getHeight()));
            contentImage.setImageBitmap(bitmap);
        } else {
            contentImage.setImageDrawable(getContext().getResources().getDrawable(R.drawable.face_delete));
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
