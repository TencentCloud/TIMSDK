package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data;

public enum BeautyInnerType {
    BEAUTY_NONE(0),
    BEAUTY_SMOOTH(10),
    BEAUTY_NATURAL(11),
    BEAUTY_PITU(12),
    BEAUTY_WHITE(13),
    BEAUTY_RUDDY(14),
    BEAUTY_FILTER(20);

    private final int mValue;

    BeautyInnerType(int value) {
        this.mValue = value;
    }

    public static BeautyInnerType fromInteger(int x) {
        for (BeautyInnerType type : BeautyInnerType.values()) {
            if (type.mValue == x) {
                return type;
            }
        }
        return BEAUTY_NONE;
    }
}