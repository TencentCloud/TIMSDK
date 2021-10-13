package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.util.FileUtil;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.FileElemBean;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class MessageFileHolder extends MessageContentHolder {

    private TextView fileNameText;
    private TextView fileSizeText;
    private TextView fileStatusText;
    private ImageView fileIconImage;

    public MessageFileHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_file;
    }

    @Override
    public void initVariableViews() {
        fileNameText = rootView.findViewById(R.id.file_name_tv);
        fileSizeText = rootView.findViewById(R.id.file_size_tv);
        fileStatusText = rootView.findViewById(R.id.file_status_tv);
        fileIconImage = rootView.findViewById(R.id.file_icon_iv);
    }

    @Override
    public void layoutVariableViews(final MessageInfo msg, final int position) {
        FileElemBean fileElemBean = FileElemBean.createFileElemBean(msg);
        if (fileElemBean == null) {
            return;
        }
        final String path = msg.getDataPath();
        fileNameText.setText(fileElemBean.getFileName());
        String size = FileUtil.formatFileSize(fileElemBean.getFileSize());
        final String fileName = fileElemBean.getFileName();
        fileSizeText.setText(size);
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FileUtil.openFile(path, fileName);
            }
        });

        if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_SUCCESS
                && msg.getDownloadStatus() == MessageInfo.MSG_STATUS_DOWNLOADED) {
            fileStatusText.setText(R.string.sended);
        } else if (msg.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
            fileStatusText.setText(R.string.sending);
        } else if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_FAIL) {
            fileStatusText.setText(R.string.send_failed);
        } else {
            if (msg.getDownloadStatus() == MessageInfo.MSG_STATUS_DOWNLOADING) {
                fileStatusText.setText(R.string.downloading);
            } else if (msg.getDownloadStatus() == MessageInfo.MSG_STATUS_DOWNLOADED) {
                if (!msg.isSelf()) {
                    fileStatusText.setText(R.string.downloaded);
                } else {
                    fileStatusText.setText(R.string.sended);
                }
            } else if (msg.getDownloadStatus() == MessageInfo.MSG_STATUS_UN_DOWNLOAD) {
                fileStatusText.setText(R.string.un_download);
            }
        }

        if (msg.getDownloadStatus() == MessageInfo.MSG_STATUS_UN_DOWNLOAD) {
            msgContentFrame.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (msg.getDownloadStatus() == MessageInfo.MSG_STATUS_DOWNLOADING
                            || msg.getDownloadStatus() == MessageInfo.MSG_STATUS_DOWNLOADED) {
                        return;
                    }
                    msg.setDownloadStatus(MessageInfo.MSG_STATUS_DOWNLOADING);
                    sendingProgress.setVisibility(View.VISIBLE);
                    fileStatusText.setText(R.string.downloading);
                    fileElemBean.downloadFile(path, new FileElemBean.FileDownloadCallback() {
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
                            msg.setDataPath(path);
                            if (!msg.isSelf()) {
                                fileStatusText.setText(R.string.downloaded);
                            } else {
                                fileStatusText.setText(R.string.sended);
                            }
                            msg.setDownloadStatus(MessageInfo.MSG_STATUS_DOWNLOADED);
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