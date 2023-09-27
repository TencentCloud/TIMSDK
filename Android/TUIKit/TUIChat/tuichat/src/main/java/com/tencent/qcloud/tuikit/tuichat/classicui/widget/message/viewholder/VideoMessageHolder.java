package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

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
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan.ImageVideoScanActivity;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ChatRingProgressBar;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;

public class VideoMessageHolder extends MessageContentHolder {
    private static final String TAG = "VideoMessageHolder";
    private static final int DEFAULT_MAX_SIZE = 540;
    private static final int DEFAULT_RADIUS = 10;
    private ImageView contentImage;
    private ImageView videoPlayBtn;
    private TextView videoDurationText;

    private FrameLayout progressContainer;
    private ChatRingProgressBar fileProgressBar;
    private TextView progressText;
    private ImageView progressIcon;

    private TUIValueCallback downloadSnapshotCallback;
    private TUIValueCallback downloadVideoCallback;
    private ProgressPresenter.ProgressListener progressListener;
    private String msgID;

    public VideoMessageHolder(View itemView) {
        super(itemView);
        contentImage = itemView.findViewById(R.id.content_image_iv);
        videoPlayBtn = itemView.findViewById(R.id.video_play_btn);
        videoDurationText = itemView.findViewById(R.id.video_duration_tv);
        progressContainer = itemView.findViewById(R.id.progress_container);
        fileProgressBar = itemView.findViewById(R.id.file_progress_bar);
        progressText = itemView.findViewById(R.id.file_progress_text);
        progressIcon = itemView.findViewById(R.id.file_progress_icon);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_image;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        msgID = msg.getId();
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
        progressContainer.setLayoutParams(getImageParams(progressContainer.getLayoutParams(), msg));
        progressContainer.setVisibility(View.GONE);
        progressText.setVisibility(View.GONE);
        sendingProgress.setVisibility(View.GONE);
        videoPlayBtn.setVisibility(View.VISIBLE);
        videoDurationText.setVisibility(View.VISIBLE);

        String snapshotPath = ChatFileDownloadPresenter.getVideoSnapshotPath(msg);
        if (FileUtil.isFileExists(snapshotPath)) {
            loadSnapshotImage(msg, snapshotPath);
        } else {
            GlideEngine.clear(contentImage);
            downloadSnapshotCallback = new TUIValueCallback() {
                @Override
                public void onProgress(long currentSize, long totalSize) {
                    TUIChatLog.d("downloadSnapshot progress current:", currentSize + ", total:" + totalSize);
                }

                @Override
                public void onError(int code, String desc) {
                    TUIChatLog.e("MessageAdapter video getImage", code + ":" + desc);
                    ToastUtil.toastShortMessage(ErrorMessageConverter.convertIMError(code, desc));
                }

                @Override
                public void onSuccess(Object obj) {
                    loadSnapshotImage(msg, snapshotPath);
                }
            };
            ChatFileDownloadPresenter.downloadVideoSnapshot(msg, downloadSnapshotCallback);
        }

        String durations = DateTimeUtil.formatSecondsTo00(msg.getDuration());
        videoDurationText.setText(durations);

        final String videoPath = ChatFileDownloadPresenter.getVideoPath(msg);
        if (!FileUtil.isFileExists(videoPath)) {
            showProgressBar();
        }

        if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_SUCCESS) {
            statusImage.setVisibility(View.GONE);
        } else if (FileUtil.isFileExists(videoPath) && msg.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            statusImage.setVisibility(View.GONE);
            showProgressBar();
        } else if (msg.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            statusImage.setVisibility(View.VISIBLE);
        }

        progressListener = new ProgressPresenter.ProgressListener() {
            @Override
            public void onProgress(int progress) {
                updateProgress(progress, msg);
            }
        };
        ProgressPresenter.registerProgressListener(msg.getId(), progressListener);

        if (isMultiSelectMode) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, position, msg);
                    }
                }
            });
            return;
        }
        downloadVideoCallback = new TUIValueCallback() {
            @Override
            public void onProgress(long currentSize, long totalSize) {
                int progress = (int) (currentSize * 100 / totalSize);
                ProgressPresenter.updateProgress(msg.getId(), progress);
                TUIChatLog.i(TAG, "downloadVideo progress current:" + currentSize + ", total:" + totalSize);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, "downloadVideo failed. code:" + code + " msg:" + desc);
                String errorMessage = ErrorMessageConverter.convertIMError(code, desc);
                ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.download_file_error) + code + " " + errorMessage);
            }

            @Override
            public void onSuccess(Object obj) {
                TUIChatLog.i(TAG, "downloadVideo onSuccess");
                ProgressPresenter.updateProgress(msg.getId(), 100);
            }
        };
        if (!FileUtil.isFileExists(videoPath) && ChatFileDownloadPresenter.isDownloading(videoPath)) {
            ChatFileDownloadPresenter.downloadVideo(msg, downloadVideoCallback);
        }
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (msg.isSelf() && msg.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
                    return;
                }
                if (FileUtil.isFileExists(videoPath)) {
                    progressContainer.setVisibility(View.GONE);
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
                } else {
                    ChatFileDownloadPresenter.downloadVideo(msg, downloadVideoCallback);
                }
            }
        });

        if (msg.getMessageReactBean() == null || msg.getMessageReactBean().getReactSize() <= 0) {
            setMessageBubbleBackground(null);
            setMessageBubbleZeroPadding();
        }
    }

    private void loadSnapshotImage(TUIMessageBean messageBean, String snapshotPath) {
        if (TextUtils.equals(msgID, messageBean.getId())) {
            GlideEngine.loadCornerImageWithoutPlaceHolder(contentImage, snapshotPath, null, DEFAULT_RADIUS);
        }
    }

    private void showProgressBar() {
        progressContainer.setVisibility(View.VISIBLE);
        progressIcon.setVisibility(View.VISIBLE);
        fileProgressBar.setVisibility(View.VISIBLE);
        fileProgressBar.setProgress(0);
        videoPlayBtn.setVisibility(View.GONE);
    }

    private void updateProgress(int progress, VideoMessageBean messageBean) {
        progressContainer.setVisibility(View.VISIBLE);
        fileProgressBar.setVisibility(View.VISIBLE);
        fileProgressBar.setProgress(progress);
        progressText.setVisibility(View.VISIBLE);
        progressText.setText(progress + "%");
        progressIcon.setVisibility(View.GONE);
        if (progress == 100) {
            videoPlayBtn.setVisibility(View.VISIBLE);
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
