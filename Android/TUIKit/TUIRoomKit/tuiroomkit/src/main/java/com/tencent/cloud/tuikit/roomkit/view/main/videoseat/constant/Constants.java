package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.constant;

import androidx.annotation.IntDef;

public interface Constants {

    int SPEAKER_MODE_MEMBER_MIN_LIMIT = 3;

    int SPEAKER_MODE_NONE                = 0;
    int SPEAKER_MODE_SCREEN_SHARING      = 1;
    int SPEAKER_MODE_PERSONAL_VIDEO_SHOW = 2;
    int SPEAKER_MODE_SELECTED            = 3;

    @IntDef({SPEAKER_MODE_NONE, SPEAKER_MODE_SCREEN_SHARING, SPEAKER_MODE_PERSONAL_VIDEO_SHOW, SPEAKER_MODE_SELECTED})
    @interface SpeakerMode {
    }

    int TWO_PERSON_VIDEO_CONFERENCE_MEMBER_COUNT = 2;

    int VOLUME_CAN_HEARD_MIN_LIMIT = 10;
    int VOLUME_NO_SOUND            = 0;

    int ONE_PAGE_MEMBER_COUNT = 6;
}
