package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class FileMessageHolder extends MessageContentHolder {

    private TextView fileNameText;
    private TextView fileSizeText;
    private TextView fileStatusText;
    private ImageView fileIconImage;

    public FileMessageHolder(View itemView) {
        super(itemView);
        fileNameText = itemView.findViewById(R.id.file_name_tv);
        fileSizeText = itemView.findViewById(R.id.file_size_tv);
        fileStatusText = itemView.findViewById(R.id.file_status_tv);
        fileIconImage = itemView.findViewById(R.id.file_icon_iv);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_file;
    }

    @Override
    public void layoutVariableViews(final TUIMessageBean msg, final int position) {
        sendingProgress.setVisibility(View.GONE);
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
                    FileUtil.openFile(path, fileName);
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

        if (isForwardMode) {
            msgContentFrame.setBackgroundResource(R.drawable.chat_bubble_other_cavity_bg);
            statusImage.setVisibility(View.GONE);
        } else {
            //// 聊天气泡设置
            if (msg.isSelf()) {
                if (properties.getRightBubble() != null && properties.getRightBubble().getConstantState() != null) {
                    msgContentFrame.setBackground(properties.getRightBubble().getConstantState().newDrawable());
                } else {
                    msgContentFrame.setBackgroundResource(R.drawable.chat_bubble_self_cavity_bg);
                }
            } else {
                if (properties.getLeftBubble() != null && properties.getLeftBubble().getConstantState() != null) {
                    msgContentFrame.setBackground(properties.getLeftBubble().getConstantState().newDrawable());
                    msgContentFrame.setLayoutParams(msgContentFrame.getLayoutParams());
                } else {
                    msgContentFrame.setBackgroundResource(R.drawable.chat_bubble_other_cavity_bg);
                }
            }
        }

        if (message.getStatus() == TUIMessageBean.MSG_STATUS_SEND_SUCCESS
                && message.getDownloadStatus() == FileMessageBean.MSG_STATUS_DOWNLOADED) {
            fileStatusText.setText(R.string.sended);
        } else if (message.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            fileStatusText.setText(R.string.sending);
        } else if (message.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            fileStatusText.setText(R.string.send_failed);
        } else {
            if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADING) {
                fileStatusText.setText(R.string.downloading);
            } else if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADED) {
                if (!message.isSelf()) {
                    fileStatusText.setText(R.string.downloaded);
                } else {
                    fileStatusText.setText(R.string.sended);
                }
            } else if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_UN_DOWNLOAD) {
                fileStatusText.setText(R.string.un_download);
            }
        }

        if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_UN_DOWNLOAD) {
            if (isMultiSelectMode) {
                return;
            }
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADING
                            || message.getDownloadStatus() == TUIMessageBean.MSG_STATUS_DOWNLOADED) {
                        return;
                    }
                    message.setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADING);
                    sendingProgress.setVisibility(View.VISIBLE);
                    fileStatusText.setText(R.string.downloading);
                    message.downloadFile(path, new FileMessageBean.FileDownloadCallback() {
                        @Override
                        public void onProgress(long currentSize, long totalSize) {
                            TUIChatLog.i("downloadSound progress current:", currentSize + ", total:" + totalSize);
                        }

                        @Override
                        public void onError(int code, String desc) {
                            ToastUtil.toastLongMessage("getToFile fail:" + code + "=" + desc);
                            fileStatusText.setText(R.string.un_download);
                            sendingProgress.setVisibility(View.GONE);
                        }

                        @Override
                        public void onSuccess() {
                            message.setDataPath(path);
                            if (!message.isSelf()) {
                                fileStatusText.setText(R.string.downloaded);
                            } else {
                                fileStatusText.setText(R.string.sended);
                            }
                            message.setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADED);
                            sendingProgress.setVisibility(View.GONE);
                            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    FileUtil.openFile(path, fileName);
                                }
                            });
                        }
                    });
                }
            });
        }
    }
}