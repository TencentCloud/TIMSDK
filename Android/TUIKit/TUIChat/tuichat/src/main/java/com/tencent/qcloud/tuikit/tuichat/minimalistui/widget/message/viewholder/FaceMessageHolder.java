package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FaceMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;

public class FaceMessageHolder extends MessageContentHolder {
    private static final int DEFAULT_FACE_MAX_SIZE = 80; // dp

    private final ImageView contentImage;
    private final LinearLayout faceLayout;

    public FaceMessageHolder(View itemView) {
        super(itemView);
        contentImage = itemView.findViewById(R.id.face_image);
        timeInLineTextLayout = itemView.findViewById(R.id.time_in_line_text);
        faceLayout = itemView.findViewById(R.id.face_message_content_layout);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_face_message_content_layout;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        performCustomFace((FaceMessageBean) msg);
    }

    private void performCustomFace(final FaceMessageBean msg) {
        int defaultFaceSize = ScreenUtil.dip2px(DEFAULT_FACE_MAX_SIZE);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.width = defaultFaceSize;
        params.height = defaultFaceSize;
        contentImage.setLayoutParams(params);
        String faceKey = null;
        if (msg.getData() != null) {
            faceKey = new String(msg.getData());
        }
        FaceManager.loadFace(msg.getIndex(), faceKey, contentImage);
    }

    @Override
    protected void setGravity(boolean isStart) {
        faceLayout.setGravity(Gravity.END);
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
