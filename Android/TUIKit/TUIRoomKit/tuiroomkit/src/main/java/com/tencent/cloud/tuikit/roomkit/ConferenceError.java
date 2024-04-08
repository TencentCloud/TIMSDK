package com.tencent.cloud.tuikit.roomkit;

public enum ConferenceError {
    SUCCESS(0),
    FAILED(-1),
    CONFERENCE_ID_NOT_EXIST(-2100),
    CONFERENCE_ID_INVALID(-2105),
    CONFERENCE_ID_OCCUPIED(-2106),
    CONFERENCE_NAME_INVALID(-2107);

    int mValue;

    ConferenceError(int value) {
        mValue = value;
    }

    public static ConferenceError fromInt(int value) {
        for (ConferenceError error : ConferenceError.values()) {
            if (error.mValue == value) {
                return error;
            }
        }
        return FAILED;
    }
}
