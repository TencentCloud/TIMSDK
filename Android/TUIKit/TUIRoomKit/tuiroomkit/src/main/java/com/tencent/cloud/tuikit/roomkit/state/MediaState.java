package com.tencent.cloud.tuikit.roomkit.state;


import com.trtc.tuikit.common.livedata.LiveData;

import java.util.HashMap;
import java.util.Map;

public class MediaState {
    public LiveData<Boolean>              isSpeakerOpened = new LiveData<>(true);
    public LiveData<Boolean>              isCameraOpened  = new LiveData<>(false);
    public LiveData<Boolean>              isFrontCamera   = new LiveData<>(true);
    public LiveData<Map<String, Integer>> volumeInfos     = new LiveData<>(new HashMap<>());
}
