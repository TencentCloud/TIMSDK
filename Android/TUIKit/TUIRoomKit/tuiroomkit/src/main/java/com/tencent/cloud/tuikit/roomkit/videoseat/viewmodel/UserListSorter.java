package com.tencent.cloud.tuikit.roomkit.videoseat.viewmodel;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.videoseat.Constants;

import java.text.Collator;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

/**
 * Sort by priority:
 * 1. Screen sharing users; (speaker mode-screen sharing)
 * 2. There are more than three users in the room, and there is only one video user, video user; (speaker mode - personal video show)
 * 3. Room owner;
 * 4. Myself;
 * 5. Compare userName (Pinyin for Chinese);
 * 6. UserName is the same, compare userId;
 */
public class UserListSorter {
    private UserSortComparator mUserSortComparator;

    public UserListSorter() {
        mUserSortComparator = new UserSortComparator();
    }

    public void sortList(List<UserEntity> userList) {
        Collections.sort(userList, mUserSortComparator);
        if (isSpeakerOfSelected(userList)) {
            return;
        }
        advanceSingleVideoUserForSpeaker(userList);
    }

    public boolean sortForCameraStateChangedIfNeeded(List<UserEntity> userList, UserEntity userEntity) {
        if (userList.size() < Constants.SPEAKER_MODE_MEMBER_MIN_LIMIT) {
            return false;
        }
        if (isSpeakerOfScreenSharing(userList)) {
            return false;
        }
        if (isSpeakerOfSelected(userList)) {
            return false;
        }
        if (sortForPersonalVideoShowOnIfNeeded(userList)) {
            return true;
        }
        if (sortForPersonalVideoShowOffIfNeeded(userList, userEntity)) {
            return true;
        }
        return false;
    }

    public int insertUser(List<UserEntity> userList, UserEntity userEntity) {
        userList.add(userEntity);
        sortList(userList);
        return userList.indexOf(userEntity);
    }

    public int removeUser(List<UserEntity> userList, UserEntity userEntity) {
        int index = userList.indexOf(userEntity);
        userList.remove(index);
        return index;
    }

    public boolean isSpeakerOfScreenSharing(List<UserEntity> userList) {
        if (userList.isEmpty()) {
            return false;
        }
        return userList.get(0).isScreenShareAvailable();
    }

    public boolean isSpeakerOfSelected(List<UserEntity> userList) {
        if (userList.isEmpty()) {
            return false;
        }
        return userList.get(0).isSelected();
    }

    public boolean isSpeakerOfPersonalVideoShow(List<UserEntity> userList) {
        if (userList.size() < Constants.SPEAKER_MODE_MEMBER_MIN_LIMIT) {
            return false;
        }
        int videoUserNum = getTotalVideoUser(userList);
        return videoUserNum == 1;
    }

    private class UserSortComparator implements Comparator<UserEntity> {
        private Collator mChineseCollator;

        public UserSortComparator() {
            mChineseCollator = Collator.getInstance(Locale.CHINESE);
        }

        /**
         * Sorting priority:
         * 1. selected user;
         * 2. Screen sharing user;
         * 3. Room owner;
         * 4. Myself;
         * 5. Compare userName (Pinyin for Chinese);
         * 6. UserName is the same, compare userId;
         */
        @Override
        public int compare(UserEntity o1, UserEntity o2) {
            if (o1 == null || o2 == null) {
                return -1;
            }
            if (o1.isSelected()) {
                return -1;
            }
            if (o2.isSelected()) {
                return 1;
            }
            if (o1.isScreenShareAvailable()) {
                return -1;
            }
            if (o2.isScreenShareAvailable()) {
                return 1;
            }
            if (o1.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                return -1;
            }
            if (o2.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                return 1;
            }
            if (o1.isSelf()) {
                return -1;
            }
            if (o2.isSelf()) {
                return 1;
            }

            if (TextUtils.isEmpty(o1.getUserName()) || TextUtils.isEmpty(o2.getUserName())) {
                return -1;
            }
            if (o1.getUserName().equals(o2.getUserName())) {
                return o1.getUserId().compareTo(o2.getUserId());
            }
            return mChineseCollator.compare(o1.getUserName(), o2.getUserName());
        }
    }

    private void advanceSingleVideoUserForSpeaker(List<UserEntity> userList) {
        if (userList.size() < Constants.SPEAKER_MODE_MEMBER_MIN_LIMIT) {
            return;
        }
        if (!isSingleVideoAvailable(userList)) {
            return;
        }
        int firstVideoOnIndex = getFirstVideoAvailableIndex(userList);
        UserEntity firstVideoOnEntity = userList.remove(firstVideoOnIndex);
        userList.add(0, firstVideoOnEntity);
    }

    private boolean isSingleVideoAvailable(List<UserEntity> userList) {
        int videoOnCount = 0;
        for (UserEntity item : userList) {
            if (item.isVideoAvailable()) {
                videoOnCount++;
                if (videoOnCount > 1) {
                    return false;
                }
            }
        }
        return videoOnCount == 1;
    }

    private int getFirstVideoAvailableIndex(List<UserEntity> userList) {
        int size = userList.size();
        for (int i = 0; i < size; i++) {
            if (userList.get(i).isVideoAvailable()) {
                return i;
            }
        }
        return -1;
    }

    private int getTotalVideoUser(List<UserEntity> userList) {
        int total = 0;
        for (UserEntity item : userList) {
            if (item.isVideoAvailable()) {
                total++;
            }
        }
        return total;
    }

    private boolean sortForPersonalVideoShowOnIfNeeded(List<UserEntity> userList) {
        int totalVideoUser = getTotalVideoUser(userList);
        if (totalVideoUser == 1) {
            advanceSingleVideoUserForSpeaker(userList);
            return true;
        }
        return false;
    }

    private boolean sortForPersonalVideoShowOffIfNeeded(List<UserEntity> userList, UserEntity userEntity) {
        int totalVideoUser = getTotalVideoUser(userList);
        if ((userEntity.isVideoAvailable() && totalVideoUser == 2) || (!userEntity.isVideoAvailable()
                && totalVideoUser == 0)) {
            Collections.sort(userList, mUserSortComparator);
            return true;
        }
        return false;
    }
}
