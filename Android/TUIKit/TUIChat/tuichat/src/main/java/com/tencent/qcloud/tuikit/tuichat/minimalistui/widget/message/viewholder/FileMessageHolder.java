package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.progress.ProgressPresenter;
import com.tencent.qcloud.tuikit.tuichat.interfaces.NetworkConnectionListener;

public class FileMessageHolder extends MessageContentHolder {

    private TextView fileNameText;
    private TextView fileSizeText;
    private View fileContent;

    private ProgressPresenter.ProgressListener progressListener;
    private NetworkConnectionListener networkConnectionListener;

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
        msgArea.setPadding(0, 0, 0, 0);
        msgId = msg.getId();
        if (isForwardMode || isMessageDetailMode) {
            fileStatusImage.setVisibility(View.GONE);
        }
        normalBackground = msgArea.getBackground();
        fileContentBackground = fileContent.getBackground();

        progressListener = new ProgressPresenter.ProgressListener() {
            @Override
            public void onProgress(int progress) {
                updateProgress(progress, (FileMessageBean) msg);
            }
        };

        FileMessageBean message = (FileMessageBean) msg;
        final String path = message.getDataPath();
        fileNameText.setText(message.getFileName());
        String size = FileUtil.formatFileSize(message.getFileSize());
        final String fileName = message.getFileName();
        fileSizeText.setText(size);
        if (!isMultiSelectMode) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADED) {
                        FileUtil.openFile(path, fileName);
                    }
                }
            });
        } else {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onItemClickListener != null) {
                        onItemClickListener.onMessageClick(v, position, msg);
                    }
                }
            });
        }

        if (message.getStatus() == TUIMessageBean.MSG_STATUS_SEND_SUCCESS
                && message.getDownloadStatus() == FileMessageBean.MSG_STATUS_DOWNLOADED) {
            fileStatusImage.setVisibility(View.GONE);

        } else if (message.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
        } else if (message.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
        } else {
            if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADING) {
                fileStatusImage.setVisibility(View.GONE);
            } else if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADED) {
                fileStatusImage.setVisibility(View.GONE);
            } else if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_UN_DOWNLOAD) {
                fileStatusImage.setImageResource(R.drawable.chat_minimalist_file_download_icon);
                fileStatusImage.setVisibility(View.VISIBLE);
            }
        }

        if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_UN_DOWNLOAD) {
            if (isMultiSelectMode) {
                return;
            }
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    downloadFile(message, path, fileName, true);
                }
            });
            fileStatusImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    downloadFile(message, path, fileName, true);
                }
            });
        }
        networkConnectionListener = new NetworkConnectionListener() {
            @Override
            public void onConnected() {
                if (message.getDownloadStatus() == FileMessageBean.MSG_STATUS_DOWNLOADING) {
                    downloadFile(message, path, fileName, false);
                }
            }
        };
        TUIChatService.getInstance().registerNetworkListener(networkConnectionListener);
        ProgressPresenter.getInstance().registerProgressListener(msg.getId(), progressListener);
    }

    private void downloadFile(FileMessageBean message, String path, String fileName, boolean isUserClick) {
        if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADED) {
            return;
        }

        if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADING && isUserClick) {
            return;
        }

        fileStatusImage.setVisibility(View.GONE);

        message.setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADING);
        message.downloadFile(path, new FileMessageBean.FileDownloadCallback() {
            @Override
            public void onProgress(long currentSize, long totalSize) {
                int progress = (int) (currentSize * 100 / totalSize);
                ProgressPresenter.getInstance().updateProgress(message.getId(), progress);
            }

            @Override
            public void onError(int code, String desc) {
                ToastUtil.toastLongMessage("download file failed:" + code + "=" + desc);
                fileStatusImage.setImageResource(R.drawable.chat_minimalist_file_download_icon);
                fileStatusImage.setVisibility(View.VISIBLE);
            }

            @Override
            public void onSuccess() {
                message.setDataPath(path);
                message.setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADED);
                msgContentFrame.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADED) {
                            FileUtil.openFile(path, fileName);
                        }
                    }
                });
            }
        });
    }

    private void updateProgress(int progress, FileMessageBean msg) {
        if (!TextUtils.equals(msg.getId(), msgId)) {
            return;
        }

        msg.setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADING);
        if (progress == 0 || progress == 100) {
            if (progress == 100) {
                String size = FileUtil.formatFileSize(msg.getFileSize());
                fileSizeText.setText(size);
                msg.setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADED);
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
        ProgressPresenter.getInstance().unregisterProgressListener(msgId, progressListener);
        progressListener = null;
    }
}