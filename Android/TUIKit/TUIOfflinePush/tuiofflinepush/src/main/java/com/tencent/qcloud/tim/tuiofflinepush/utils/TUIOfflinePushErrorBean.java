package com.tencent.qcloud.tim.tuiofflinepush.utils;

public class TUIOfflinePushErrorBean {
    public long errorCode;
    public String ErrorDescription;

    public long getErrorCode() {
        return errorCode;
    }

    public String getErrorDescription() {
        return ErrorDescription;
    }

    public void setErrorCode(long errorCode) {
        this.errorCode = errorCode;
    }

    public void setErrorDescription(String errorDescription) {
        ErrorDescription = errorDescription;
    }
}
