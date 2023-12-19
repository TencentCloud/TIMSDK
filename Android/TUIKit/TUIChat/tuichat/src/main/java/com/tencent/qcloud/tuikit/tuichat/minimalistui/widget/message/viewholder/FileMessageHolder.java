package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.interfaces.NetworkConnectionListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.Locale;

public class FileMessageHolder extends MessageContentHolder {
    private static final String TAG = "FileMessageHolder";
    private TextView fileNameText;
    private TextView fileSizeText;
    private View fileContent;

    private ProgressPresenter.ProgressListener progressListener;
    private NetworkConnectionListener networkConnectionListener;
    private TUIValueCallback downloadCallback;

    private Drawable normalBackground;
    private Drawable fileContentBackground;
    private String msgId;

    public FileMessageHolder(View itemView) {
        super(itemView);
        fileNameText = itemView.findViewById(R.id.file_name_tv);
        fileSizeText = itemView.findViewById(R.id.file_size_tv);
        fileContent = itemView.findViewById(R.id.file_content);
        timeInLineTextLayout = itemView.findViewById(R.id.file_msg_time_in_line_text);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.minimalist_message_adapter_content_file;
    }

    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        setMessageBubbleZeroPadding();
        msgId = msg.getId();
        if (isForwardMode || isMessageDetailMode) {
            fileStatusImage.setVisibility(View.GONE);
        }
        normalBackground = getMessageBubbleBackground();
        fileContentBackground = fileContent.getBackground();

        progressListener = new ProgressPresenter.ProgressListener() {
            @Override
            public void onProgress(int progress) {
                updateProgress(progress, (FileMessageBean) msg);
            }
        };

        FileMessageBean message = (FileMessageBean) msg;
        final String path = ChatFileDownloadPresenter.getFilePath(message);
        fileNameText.setText(message.getFileName());
        String size = FileUtil.formatFileSize(message.getFileSize());
        final String fileName = message.getFileName();
        fileSizeText.setText(size);
        if (!isMultiSelectMode) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (FileUtil.isFileExists(path)) {
                        FileUtil.openFile(path, fileName);
                    }
                }
            });
        } else {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, msg);
                    }
                }
            });
        }

        boolean isFileExists = FileUtil.isFileExists(path);
        if (isFileExists) {
            fileStatusImage.setVisibility(View.GONE);
        } else {
            fileStatusImage.setImageResource(com.tencent.qcloud.tuikit.timcommon.R.drawable.chat_minimalist_file_download_icon);
            fileStatusImage.setVisibility(View.VISIBLE);
        }

        if (!isFileExists) {
            if (isMultiSelectMode) {
                return;
            }
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    downloadFile(message);
                }
            });
            fileStatusImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    downloadFile(message);
                }
            });
            if (ChatFileDownloadPresenter.isDownloading(path)) {
                downloadFile(message);
            }
        }

        networkConnectionListener = new NetworkConnectionListener() {
            @Override
            public void onConnected() {
                String filePath = ChatFileDownloadPresenter.getFilePath(message);
                if (!FileUtil.isFileExists(filePath) && message.isDownloading()) {
                    downloadFile(message);
                }
            }
        };
        TUIChatService.getInstance().registerNetworkListener(networkConnectionListener);
        ProgressPresenter.getInstance().registerProgressListener(msg.getId(), progressListener);
    }

    private void downloadFile(FileMessageBean message) {
        String path = ChatFileDownloadPresenter.getFilePath(message);
        if (FileUtil.isFileExists(path)) {
            return;
        }
        message.setDownloading(true);
        fileStatusImage.setVisibility(View.GONE);
        downloadCallback = new TUIValueCallback() {
            @Override
            public void onProgress(long currentSize, long totalSize) {
                int progress = (int) (currentSize * 100 / totalSize);
                ProgressPresenter.getInstance().updateProgress(message.getId(), progress);
            }

            @Override
            public void onError(int code, String desc) {
                TUIChatLog.e(TAG, String.format(Locale.US, "download file %s failed code %d,message %s", path, code, desc));
                ToastUtil.toastLongMessage(ErrorMessageConverter.convertIMError(code, desc));
                setFileStatus(message, true);
            }

            @Override
            public void onSuccess(Object obj) {
                message.setDownloading(false);
                updateProgress(100, message);
                setFileStatus(message, false);
                if (mAdapter != null) {
                    mAdapter.onItemRefresh(message);
                }
            }
        };
        ChatFileDownloadPresenter.downloadFile(message, downloadCallback);
    }

    private void setFileStatus(TUIMessageBean messageBean, boolean isVisible) {
        if (TextUtils.equals(messageBean.getId(), msgId)) {
            fileStatusImage.setVisibility(isVisible ? View.VISIBLE : View.GONE);
        }
    }

    private void updateProgress(int progress, FileMessageBean msg) {
        if (!TextUtils.equals(msg.getId(), msgId)) {
            return;
        }

        if (progress == 0 || progress == 100) {
            if (progress == 100) {
                String size = FileUtil.formatFileSize(msg.getFileSize());
                fileSizeText.setText(size);
            }
        } else {
            fileSizeText.setText(progress + "%");
        }
    }

    @Override
    public void setHighLightBackground(int color) {
        if (normalBackground != null) {
            normalBackground.setColorFilter(color, PorterDuff.Mode.SRC_IN);
        }
        if (fileContentBackground != null) {
            fileContentBackground.setColorFilter(color, PorterDuff.Mode.SRC_OVER);
        }
    }

    @Override
    public void clearHighLightBackground() {
        if (normalBackground != null) {
            normalBackground.setColorFilter(null);
        }
        if (fileContentBackground != null) {
            fileContentBackground.setColorFilter(null);
        }
    }

    @Override
    public void onRecycled() {
        ProgressPresenter.unregisterProgressListener(msgId, progressListener);
        progressListener = null;
    }
}