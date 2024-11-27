package com.tencent.qcloud.tuikit.tuimultimediaplugin;

public class TUIMultimediaConstants {
    public static final String RECORD_TYPE_KEY = "record_type";
    public static final String PARAM_NAME_RECORD_CONFIG = "recordConfig";
    public static final String PARAM_NAME_RECORD_TYPE = "recordType";
    public static final String PARAM_NAME_EDIT_FILE_PATH = "editFilePath";
    public static final String PARAM_NAME_EDITED_FILE_PATH = "editedFilePath";
    public static final String PARAM_NAME_EDIT_FILE_RATIO = "recordFileRatio";
    public static final String PARAM_NAME_IS_RECODE_FILE = "isRecordFile";

    public static final int RECORD_TYPE_VIDEO = 0;
    public static final int RECORD_TYPE_PHOTO = 1;

    public enum VideoQuality {
        LOW(1),
        MEDIUM(2),
        HIGH(3);

        private final int value;

        VideoQuality(int value) {
            this.value = value;
        }

        public static VideoQuality fromInteger(int value) {
            for (VideoQuality code : VideoQuality.values()) {
                if (value == code.getValue()) {
                    return code;
                }
            }
            return LOW;
        }

        public int getValue() {
            return value;
        }
    }
}
