package com.tencent.cloud.tuikit.roomkit.view.page.widget.ScheduleConference.SelectScheduleParticipant;

import java.io.Serializable;
import java.util.Objects;

public class User implements Serializable {
    public String userName;
    public String userId;
    public String avatarUrl;

    public User() {
    }

    @Override
    public boolean equals(Object object) {
        if (this == object) return true;
        if (object == null || !(object instanceof User)) return false;
        User user = (User) object;
        return Objects.equals(userId, user.userId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId);
    }
}
