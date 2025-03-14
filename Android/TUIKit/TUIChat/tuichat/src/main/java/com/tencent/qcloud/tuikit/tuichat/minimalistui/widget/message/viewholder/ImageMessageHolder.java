package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.component.RoundFrameLayout;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ImageUtil;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideobrowse.ImageVideoBrowseActivity;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ChatRingProgressBar;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;

public class ImageMessageHolder extends MessageContentHolder {
    protected static final int DEFAULT_MAX_SIZE = 540;
    protected static final int DEFAULT_RADIUS = 0;
    public RoundCornerImageView contentImage;
    public RoundFrameLayout roundFrameLayout;
    protected ImageView videoPlayBtn;
    protected TUIValueCallback downloadCallback;
    protected FrameLayout progressContainer;
    protected ChatRingProgressBar fileProgressBar;
    protected TextView progressText;
    protected ImageView downloadIcon;
    protected ProgressPresenter.ProgressListener progressListener;
    private String msgID;

    public ImageMessageHolder(View itemView) {
        super(itemView);
        contentImage = itemView.findViewById(R.id.content_image_iv);
        roundFrameLayout = itemView.findViewById(R.id.image_round_container);
        videoPlayBtn = itemView.findViewById(R.id.video_play_btn);
        timeInLineTextLayout = itemView.findViewById(R.id.image_msg_time_in_line_text);
        timeInLineTextLayout.setTimeColor(0xFFFFFFFF);
        progressContainer = itemView.findViewById(R.id.progress_container);
        fileProgressBar = itemView.findViewById(R.id.file_progress_bar);
        progressText = itemView.findViewById(R.id.file_progress_text);
        downloadIcon = itemView.findViewById(R.id.file_download_icon);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_message_adapter_content_image;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        msgID = msg.getId();
        if (msg.hasRiskContent()) {
            videoPlayBtn.setVisibility(View.GONE);
            progressContainer.setVisibility(View.GONE);
            downloadCallback = null;
            ViewGroup.LayoutParams params = contentImage.getLayoutParams();
            params.width = itemView.getResources().getDimensionPixelSize(R.dimen.chat_image_message_error_size);
            params.height = itemView.getResources().getDimensionPixelSize(R.dimen.chat_image_message_error_size);
            GlideEngine.loadImage(contentImage, R.drawable.chat_risk_image_replace_icon);
            contentImage.setLayoutParams(params);
            setImagePadding(msg);
            msgContentFrame.setOnClickListener(null);
        } else {
            performImage((ImageMessageBean) msg);
        }
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

    private void performImage(final ImageMessageBean msg) {
        if (msg.isSending() && msg.getImgHeight() == 0 && msg.getImgWidth() == 0) {
            String imagePath = ChatFileDownloadPresenter.getImagePath(msg);
            int[] size = ImageUtil.getImageSize(imagePath);
            msg.setImgWidth(size[0]);
            msg.setImgHeight(size[1]);
        }
        setLayoutParams(msg);
        progressContainer.setVisibility(View.GONE);
        progressText.setVisibility(View.GONE);
        videoPlayBtn.setVisibility(View.GONE);
        setImagePadding(msg);
        videoPlayBtn.setVisibility(View.GONE);
        if (msg.isProcessing()) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, msg.getProcessingThumbnail(), null, DEFAULT_RADIUS);
            return;
        }

        progressListener = progress -> updateProgress(progress, msg);
        ProgressPresenter.registerProgressListener(msg.getId(), progressListener);

        String imagePath = ChatFileDownloadPresenter.getImagePath(msg);
        if (FileUtil.isFileExists(imagePath)) {
            loadImage(msg, imagePath);
        } else {
            GlideEngine.clear(contentImage);
            showProgressBar();
            downloadCallback = new TUIValueCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    int progress = Math.round(currentSize * 1.0f * 100 / totalSize);
                    ProgressPresenter.updateProgress(msg.getId(), progress);
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
                    ProgressPresenter.updateProgress(msg.getId(), 100);
                    loadImage(msg, imagePath);
                }
            };
            ChatFileDownloadPresenter.downloadImage(msg, downloadCallback);
        }

        if (msg.isSending()) {
            showProgressBar();
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
                    Intent intent = new Intent(TUIChatService.getAppContext(), ImageVideoBrowseActivity.class);
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
    }

    private void setLayoutParams(ImageMessageBean msg) {
        contentImage.setLayoutParams(getImageParams(contentImage.getLayoutParams(), msg));
        ViewGroup.LayoutParams progressParams = getImageParams(progressContainer.getLayoutParams(), msg);
        progressContainer.setLayoutParams(progressParams);
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
            roundFrameLayout.setRadius(ScreenUtil.dip2px(16));
        } else {
            boolean isRTL = LayoutUtil.isRTL();
            roundFrameLayout.setRadius(ScreenUtil.dip2px(16));
            if (isLayoutOnStart) {
                if (isRTL) {
                    roundFrameLayout.setRightBottomRadius(0);
                } else {
                    roundFrameLayout.setLeftBottomRadius(0);
                }
            } else {
                if (isRTL) {
                    roundFrameLayout.setLeftBottomRadius(0);
                } else {
                    roundFrameLayout.setRightBottomRadius(0);
                }
            }
        }
    }

    private void showProgressBar() {
        progressContainer.setVisibility(View.VISIBLE);
        fileProgressBar.setVisibility(View.VISIBLE);
        fileProgressBar.setProgress(0);
        progressText.setVisibility(View.GONE);
    }

    private void updateProgress(int progress, TUIMessageBean messageBean) {
        if (!TextUtils.equals(msgID, messageBean.getId())) {
            return;
        }
        progressText.setVisibility(View.VISIBLE);
        fileProgressBar.setProgress(progress);
        progressText.setText(progress + "%");
        downloadIcon.setVisibility(View.GONE);
        if (progress == 100) {
            progressContainer.setVisibility(View.GONE);
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
