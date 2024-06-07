package com.tencent.cloud.tuikit.roomkit;

import java.io.Serializable;

public class ConferenceParams implements Serializable {
    private static final long serialVersionUID = 10001L;

    private boolean isMuteMicrophone = false;
    private boolean isOpenCamera     = false;
    private boolean isSoundOnSpeaker = true;

    private String  name;
    private boolean enableMicrophoneForAllUser = true;
    private boolean enableCameraForAllUser     = true;
    private boolean enableMessageForAllUser    = true;
    private boolean enableSeatControl          = false;

    public ConferenceParams(){}

    public boolean isMuteMicrophone() {
        return isMuteMicrophone;
    }

    public void setMuteMicrophone(boolean muteMicrophone) {
        isMuteMicrophone = muteMicrophone;
    }

    public boolean isOpenCamera() {
        return isOpenCamera;
    }

    public void setOpenCamera(boolean openCamera) {
        isOpenCamera = openCamera;
    }

    public boolean isSoundOnSpeaker() {
        return isSoundOnSpeaker;
    }

    public void setSoundOnSpeaker(boolean soundOnSpeaker) {
        isSoundOnSpeaker = soundOnSpeaker;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isEnableMicrophoneForAllUser() {
        return enableMicrophoneForAllUser;
    }

    public void setEnableMicrophoneForAllUser(boolean enableMicrophoneForAllUser) {
        this.enableMicrophoneForAllUser = enableMicrophoneForAllUser;
    }

    public boolean isEnableCameraForAllUser() {
        return enableCameraForAllUser;
    }

    public void setEnableCameraForAllUser(boolean enableCameraForAllUser) {
        this.enableCameraForAllUser = enableCameraForAllUser;
    }

    public boolean isEnableMessageForAllUser() {
        return enableMessageForAllUser;
    }

    public void setEnableMessageForAllUser(boolean enableMessageForAllUser) {
        this.enableMessageForAllUser = enableMessageForAllUser;
    }

    public boolean isEnableSeatControl() {
        return enableSeatControl;
    }

    public void setEnableSeatControl(boolean enableSeatControl) {
        this.enableSeatControl = enableSeatControl;
    }

    @Override
    public String toString() {
        return "ConferenceParams{" + "isMuteMicrophone=" + isMuteMicrophone + ", isOpenCamera=" + isOpenCamera
                + ", isSoundOnSpeaker=" + isSoundOnSpeaker + ", name='" + name + '\'' + ", enableMicrophoneForAllUser="
                + enableMicrophoneForAllUser + ", enableCameraForAllUser=" + enableCameraForAllUser
                + ", enableMessageForAllUser=" + enableMessageForAllUser + ", enableSeatControl=" + enableSeatControl
                + '}';
    }
}
