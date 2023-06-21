package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.ImageVideoScanActivity;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.File;
import java.io.Serializable;

public class VideoMessageHolder extends ImageMessageHolder {
    public VideoMessageHolder(View itemView) {
        super(itemView);
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        performVideo((VideoMessageBean) msg, position);
    }

    private ViewGroup.LayoutParams getImageParams(ViewGroup.LayoutParams params, final VideoMessageBean msg) {
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

    private void performVideo(final VideoMessageBean msg, final int position) {
        contentImage.setLayoutParams(getImageParams(contentImage.getLayoutParams(), msg));

        videoPlayBtn.setVisibility(View.VISIBLE);

        if (!TextUtils.isEmpty(msg.getSnapshotPath()) && new File(msg.getSnapshotPath()).exists()) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, msg.getSnapshotPath(), null, DEFAULT_RADIUS);
        } else {
            GlideEngine.clear(contentImage);
            synchronized (downloadEles) {
                if (!downloadEles.contains(msg.getSnapshotUUID())) {
                    downloadEles.add(msg.getSnapshotUUID());
                }
            }

            final String path = TUIConfig.getImageDownloadDir() + msg.getSnapshotUUID();
            msg.downloadSnapshot(path, new VideoMessageBean.VideoDownloadCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    TUIChatLog.i("downloadSnapshot progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    downloadEles.remove(msg.getSnapshotUUID());
                    TUIChatLog.e("MessageAdapter video getImage", code + ":" + desc);
                }

                @Override
                public void onSuccess() {
                    downloadEles.remove(msg.getSnapshotUUID());
                    msg.setSnapshotPath(path);
                    GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, msg.getSnapshotPath(), null, DEFAULT_RADIUS);
                }
            });
        }

        if (isMultiSelectMode) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, position, msg);
                    }
                }
            });
        } else {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
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
        }

        setImagePadding(msg);
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
