package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.graphics.Bitmap;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

public class FaceMessageHolder extends MessageContentHolder {

    private ImageView contentImage;
    private ImageView videoPlayBtn;
    private TextView videoDurationText;

    public FaceMessageHolder(View itemView) {
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
        performCustomFace((FaceMessageBean) msg, position);
        if (msg.getMessageReactBean() == null || msg.getMessageReactBean().getReactSize() <= 0) {
            msgArea.setBackground(null);
            msgArea.setPadding(0, 0, 0, 0);
        }
    }

    private void performCustomFace(final FaceMessageBean msg, final int position) {
        videoPlayBtn.setVisibility(View.GONE);
        videoDurationText.setVisibility(View.GONE);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.CENTER_IN_PARENT);
        contentImage.setLayoutParams(params);

        String filter = new String(msg.getData());
        if (!filter.contains("@2x")) {
            filter += "@2x";
        }
        Bitmap bitmap = FaceManager.getCustomBitmap(msg.getIndex(), filter);
        if (bitmap == null) {
            bitmap = FaceManager.getEmoji(new String(msg.getData()));
            if (bitmap == null) {
                contentImage.setImageDrawable(itemView.getContext().getResources().getDrawable(R.drawable.face_delete));
            } else {
                contentImage.setImageBitmap(bitmap);
            }
        } else {
            contentImage.setImageBitmap(bitmap);
        }
    }

    @Override
    public void setHighLightBackground(int color) {
        Drawable drawable = contentImage.getDrawable();
        if (drawable != null) {
            drawable.setColorFilter(color, PorterDuff.Mode.SRC_OVER);
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
