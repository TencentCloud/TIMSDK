package com.tencent.qcloud.tuikit.tuichat.bean;

import com.tencent.imsdk.v2.V2TIMDownloadCallback;
import com.tencent.imsdk.v2.V2TIMElem;
import com.tencent.imsdk.v2.V2TIMFileElem;
import com.tencent.imsdk.v2.V2TIMMessage;

public class FileElemBean {
    private V2TIMFileElem fileElem;

    public void setFileElem(V2TIMFileElem fileElem) {
        this.fileElem = fileElem;
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

    public static FileElemBean createFileElemBean(MessageInfo messageInfo) {
        FileElemBean fileElemBean = null;
        if (messageInfo != null) {
            V2TIMMessage message = messageInfo.getTimMessage();
            if (message != null) {
                if (message.getElemType() == V2TIMMessage.V2TIM_ELEM_TYPE_FILE) {
                    fileElemBean = new FileElemBean();
                    V2TIMFileElem fileElem = message.getFileElem();
                    fileElemBean.setFileElem(fileElem);
                }
            }
        }
        return fileElemBean;
    }
}
