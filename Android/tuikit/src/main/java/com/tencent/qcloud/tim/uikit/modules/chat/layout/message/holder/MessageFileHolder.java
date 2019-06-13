package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMFileElem;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.FileUtil;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

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
        final TIMFileElem fileElem = (TIMFileElem) msg.getTIMMessage().getElement(0);
        final String path = msg.getDataPath();
        fileNameText.setText(fileElem.getFileName());
        String size = FileUtil.FormetFileSize(fileElem.getFileSize());
        fileSizeText.setText(size);
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ToastUtil.toastLongMessage("文件路径:" + path);
            }
        });
        if (msg.isSelf()) {
            if (msg.getStatus() == MessageInfo.MSG_STATUS_SENDING) {
                fileStatusText.setText(R.string.sending);
            } else if (msg.getStatus() == MessageInfo.MSG_STATUS_SEND_SUCCESS || msg.getStatus() == MessageInfo.MSG_STATUS_NORMAL) {
                fileStatusText.setText(R.string.sended);
            }
        } else {
            if (msg.getStatus() == MessageInfo.MSG_STATUS_DOWNLOADING) {
                fileStatusText.setText(R.string.downloading);
            } else if (msg.getStatus() == MessageInfo.MSG_STATUS_DOWNLOADED) {
                fileStatusText.setText(R.string.downloaded);
            } else if (msg.getStatus() == MessageInfo.MSG_STATUS_UN_DOWNLOAD) {
                fileStatusText.setText(R.string.un_download);
                msgContentFrame.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        msg.setStatus(MessageInfo.MSG_STATUS_DOWNLOADING);
                        sendingProgress.setVisibility(View.VISIBLE);
                        fileStatusText.setText(R.string.downloading);
                        fileElem.getToFile(path, new TIMCallBack() {
                            @Override
                            public void onError(int code, String desc) {
                                ToastUtil.toastLongMessage("getToFile fail:" + code + "=" + desc);
                                sendingProgress.setVisibility(View.GONE);
                            }

                            @Override
                            public void onSuccess() {
                                msg.setDataPath(path);
                                fileStatusText.setText(R.string.downloaded);
                                msg.setStatus(MessageInfo.MSG_STATUS_DOWNLOADED);
                                sendingProgress.setVisibility(View.GONE);
                                msgContentFrame.setOnClickListener(new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        ToastUtil.toastLongMessage("文件路径:" + path);

                                    }
                                });
                            }
                        });
                    }
                });

            }
        }
    }

}
