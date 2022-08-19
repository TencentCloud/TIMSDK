package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMFileElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.FileReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.reply.TUIReplyQuoteBean;

import java.io.File;

public class FileMessageBean extends TUIMessageBean {

    private String dataPath;
    private V2TIMFileElem fileElem;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        if (getStatus() == TUIMessageBean.MSG_STATUS_REVOKE) {
            return;
        }
        fileElem = v2TIMMessage.getFileElem();
        String filename = fileElem.getUUID();
        if (TextUtils.isEmpty(filename)) {
            filename = System.currentTimeMillis() + fileElem.getFileName();
        }
        final String path = TUIConfig.getFileDownloadDir() + filename;
        String finalPath = path;
        File file = new File(path);

        if (file.exists()) {
            if (isSelf()) {
                setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
            }
            setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADED);
        } else {
            if (isSelf()) {
                if (TextUtils.isEmpty(fileElem.getPath())) {
                    setDownloadStatus(TUIMessageBean.MSG_STATUS_UN_DOWNLOAD);
                } else {
                    file = new File(fileElem.getPath());
                    if (file.exists()) {
                        setStatus(TUIMessageBean.MSG_STATUS_SEND_SUCCESS);
                        setDownloadStatus(TUIMessageBean.MSG_STATUS_DOWNLOADED);
                        finalPath = fileElem.getPath();
                    } else {
                        setDownloadStatus(TUIMessageBean.MSG_STATUS_UN_DOWNLOAD);
                    }
                }
            } else {
                setDownloadStatus(TUIMessageBean.MSG_STATUS_UN_DOWNLOAD);
            }
        }
        setDataPath(finalPath);
        setExtra(TUIChatService.getAppContext().getString(R.string.file_extra));
    }

    /**
     * 获取文件的保存路径
     * 
     * Get the save path of the file
     *
     * @return
     */
    public String getDataPath() {
        return dataPath;
    }

    /**
     * 设置文件的保存路径
     * 
     * Set the save path of the file
     *
     * @param dataPath
     */
    public void setDataPath(String dataPath) {
        this.dataPath = dataPath;
    }

    public String getUUID() {
        if (fileElem != null) {
            return fileElem.getUUID();
        }
        return "";
    }
    public String getFileName() {
        if (fileElem != null) {
            return fileElem.getFileName();
        }
        return "";
    }

    public int getFileSize() {
        if (fileElem != null) {
            return fileElem.getFileSize();
        }
        return 0;
    }

    public String getPath() {
        if (fileElem != null) {
            return fileElem.getPath();
        }
        return "";
    }

    public void downloadFile(String path, FileDownloadCallback callback) {
        if (fileElem != null) {
            fileElem.downloadFile(path, new V2TIMDownloadCallback() {
                @Override
                public void onProgress(V2TIMElem.V2ProgressInfo progressInfo) {
                    if (callback != null) {
                        callback.onProgress(progressInfo.getCurrentSize(), progressInfo.getTotalSize());
                    }
                }

                @Override
                public void onSuccess() {
                    if (callback != null) {
                        callback.onSuccess();
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    if (callback != null) {
                        callback.onError(code, desc);
                    }
                }
            });
        }
    }

    public interface FileDownloadCallback {
        void onProgress(long currentSize, long totalSize);

        void onSuccess();

        void onError(int code, String desc);
    }

    @Override
    public Class<? extends TUIReplyQuoteBean> getReplyQuoteBeanClass() {
        return FileReplyQuoteBean.class;
    }

}
