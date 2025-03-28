package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.viewmodel;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.view.main.videoseat.constant.Constants;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Sort by priority:
 * 1. Selected user;
 * 2. Screen sharing users; (speaker mode-screen sharing)
 * 3. There are more than three users in the room, and there is only one video user, video user; (speaker mode - personal video show)
 * 4. Room owner;
 * 5. Myself;
 * 6. User has camera and audio;
 * 7. User has camera;
 * 8. User has audio;
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

    private static class UserSortComparator implements Comparator<UserEntity> {
        private static final int LESSER  = -1;
        private static final int EQUAL   = 0;
        private static final int GREATER = 1;

        /**
         * Sorting priority:
         * 1. Selected user;
         * 2. Screen sharing user;
         * 3. Room owner;
         * 4. Myself;
         * 5. User has camera and audio;
         * 6. User has camera;
         * 7. User has audio;
         */
        @Override
        public int compare(UserEntity o1, UserEntity o2) {
            if (o1 == null || o2 == null) {
                return EQUAL;
            }
            if (o1.isSelected()) {
                return LESSER;
            }
            if (o2.isSelected()) {
                return GREATER;
            }
            if (o1.isScreenShareAvailable()) {
                return LESSER;
            }
            if (o2.isScreenShareAvailable()) {
                return GREATER;
            }
            if (o1.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                return LESSER;
            }
            if (o2.getRole() == TUIRoomDefine.Role.ROOM_OWNER) {
                return GREATER;
            }
            if (o1.isSelf()) {
                return LESSER;
            }
            if (o2.isSelf()) {
                return GREATER;
            }
            if (o1.isCameraAvailable() != o2.isCameraAvailable()) {
                return o1.isCameraAvailable() ? LESSER : GREATER;
            }
            if (o1.isAudioAvailable() != o2.isAudioAvailable()) {
                return o1.isAudioAvailable() ? LESSER : GREATER;
            }
            return EQUAL;
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
