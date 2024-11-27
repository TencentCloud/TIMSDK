package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data;

import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.ugc.TXRecordCommon;

public class RecordInfo {

    public TUIMultimediaData<RecordStatus> tuiDataRecordStatus = new TUIMultimediaData<>(RecordStatus.IDLE);
    public TUIMultimediaData<Float> tuiDataRecordProcess = new TUIMultimediaData<>(0.0f);
    public TUIMultimediaData<Integer> tuiDataAspectRatio = new TUIMultimediaData<>(TXRecordCommon.VIDEO_ASPECT_RATIO_9_16);
    public TUIMultimediaData<Boolean> tuiDataIsFontCamera = new TUIMultimediaData<>(false);
    public TUIMultimediaData<Boolean> tuiDataIsFlashOn = new TUIMultimediaData<>(false);
    public TUIMultimediaData<Boolean> tuiDataShowBeautyView = new TUIMultimediaData<>(false);
    public RecordResult recordResult = new RecordResult();
    public BeautyInfo beautyInfo;
    public int recodeType = TUIMultimediaConstants.RECORD_TYPE_VIDEO;

    public enum RecordStatus {
        IDLE, STOP, RECORDING,TAKE_PHOTOING
    }

    static public class RecordResult {

        public String path;
        public int type;
        public boolean isSuccess;
        public int code;
    }
}
