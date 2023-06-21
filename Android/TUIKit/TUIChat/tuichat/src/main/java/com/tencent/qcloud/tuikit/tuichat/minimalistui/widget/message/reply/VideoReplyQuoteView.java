package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.reply;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class VideoReplyQuoteView extends ImageReplyQuoteView {
    public VideoReplyQuoteView(Context context) {
        super(context);
    }

    @Override
    public void onDrawReplyQuote(TUIReplyQuoteBean quoteBean) {
        VideoMessageBean messageBean = (VideoMessageBean) quoteBean.getMessageBean();

        ViewGroup.LayoutParams layoutParams = getImageParams(imageMsgIv.getLayoutParams(), messageBean.getImgWidth(), messageBean.getImgHeight());
        imageMsgIv.setLayoutParams(layoutParams);
        videoPlayIv.setLayoutParams(layoutParams);
        imageMsgLayout.setVisibility(View.VISIBLE);
        videoPlayIv.setVisibility(View.VISIBLE);
        if (!TextUtils.isEmpty(messageBean.getSnapshotPath())) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(imageMsgIv, messageBean.getSnapshotPath(), null, DEFAULT_RADIUS);
        } else {
            GlideEngine.clear(imageMsgIv);
            synchronized (downloadEles) {
                if (!downloadEles.contains(messageBean.getSnapshotUUID())) {
                    downloadEles.add(messageBean.getSnapshotUUID());
                }
            }

            final String path = TUIConfig.getImageDownloadDir() + messageBean.getSnapshotUUID();
            messageBean.downloadSnapshot(path, new VideoMessageBean.VideoDownloadCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    TUIChatLog.i("downloadSnapshot progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    downloadEles.remove(messageBean.getSnapshotUUID());
                    TUIChatLog.e("MessageAdapter video getImage", code + ":" + desc);
                }

                @Override
                public void onSuccess() {
                    downloadEles.remove(messageBean.getSnapshotUUID());
                    messageBean.setSnapshotPath(path);
                    GlideEngine.loadCornerImageWithoutPlaceHolder(imageMsgIv, messageBean.getSnapshotPath(), null, DEFAULT_RADIUS);
                }
            });
        }
    }
}
