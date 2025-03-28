package com.tencent.cloud.tuikit.roomkit.state;

import android.text.TextUtils;

import androidx.annotation.Nullable;

import com.trtc.tuikit.common.livedata.LiveListData;

public class ASRState {
    public LiveListData<SpeechToText> speechToTexts = new LiveListData<>();

    public static class SpeechToText {
        public String  roundId     = "";
        public String  userId      = "";
        public String  userName    = "";
        public String  avatarUrl   = "";
        public String  text        = "";
        public long    startTimeMs = 0L;
        public long    endTimeMs   = 0L;
        public boolean isSpeechEnd = false;

        @Override
        public boolean equals(@Nullable Object obj) {
            if (obj instanceof SpeechToText) {
                return TextUtils.equals(this.roundId, ((SpeechToText) obj).roundId);
            }
            return false;
        }
    }

    public static final String ASR_TYPE_SUBTITLE      = "subtitle";
    public static final String ASR_TYPE_TRANSCRIPTION = "transcription";
}
