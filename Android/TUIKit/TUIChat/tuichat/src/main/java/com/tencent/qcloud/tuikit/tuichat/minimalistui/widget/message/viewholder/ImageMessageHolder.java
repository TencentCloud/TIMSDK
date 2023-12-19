package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.ImageVideoScanActivity;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;

public class ImageMessageHolder extends MessageContentHolder {
    protected static final int DEFAULT_MAX_SIZE = 540;
    protected static final int DEFAULT_RADIUS = 0;
    public RoundCornerImageView contentImage;
    protected ImageView videoPlayBtn;
    private TUIValueCallback downloadCallback;
    private String msgID;

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
        msgID = msg.getId();
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

        String imagePath = ChatFileDownloadPresenter.getImagePath(msg);
        if (FileUtil.isFileExists(imagePath)) {
            loadImage(msg, imagePath);
        } else {
            GlideEngine.clear(contentImage);
            downloadCallback = new TUIValueCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    TUIChatLog.d("downloadImage progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.e("MessageAdapter img getImage", code + ":" + desc);
                    if (mAdapter != null) {
                        mAdapter.onItemRefresh(msg);
                    }
                }

                @Override
                public void onSuccess(Object obj) {
                    loadImage(msg, imagePath);
                }
            };
            ChatFileDownloadPresenter.downloadImage(msg, downloadCallback);
        }
        if (isMultiSelectMode) {
            contentImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, msg);
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
                        onItemClickListener.onMessageLongClick(msgArea, msg);
                    }
                    return true;
                }
            });
        }
        setImagePadding(msg);
    }

    private void loadImage(TUIMessageBean messageBean, String imagePath) {
        if (TextUtils.equals(messageBean.getId(), msgID)) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, imagePath, null, DEFAULT_RADIUS);
        }
    }

    protected void setImagePadding(TUIMessageBean messageBean) {
        int padding = ScreenUtil.dip2px(1);
        msgArea.setPaddingRelative(padding, padding, padding, padding);
    }

    @Override
    protected void optimizeMessageContent(boolean isShowAvatar) {
        if (!isShowAvatar) {
            contentImage.setRadius(ScreenUtil.dip2px(16));
        } else {
            boolean isRTL = LayoutUtil.isRTL();
            contentImage.setRadius(ScreenUtil.dip2px(16));
            if (isShowStart) {
                if (isRTL) {
                    contentImage.setRightBottomRadius(0);
                } else {
                    contentImage.setLeftBottomRadius(0);
                }
            } else {
                if (isRTL) {
                    contentImage.setLeftBottomRadius(0);
                } else {
                    contentImage.setRightBottomRadius(0);
                }
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
