package com.tencent.cloud.tuikit.roomkit.videoseat.ui.utils;

import android.text.TextUtils;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.tencent.cloud.tuikit.roomkit.videoseat.Constants;
import com.tencent.cloud.tuikit.roomkit.videoseat.viewmodel.UserEntity;

import java.text.Collator;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

/**
 * 排序的优先级：
 * 1、屏幕分享用户；(演讲者模式-屏幕分享)
 * 2、房间内有三人以上用户，有且仅有一个视频用户，视频用户；（演讲者模式-个人视频秀）
 * 3、房主；
 * 4、本人；
 * 5、比较 userName（中文用拼音）；
 * 6、userName 一样，比较 userId；
 */
public class UserListSorter {
    private UserSortComparator mUserSortComparator;

    public UserListSorter() {
        mUserSortComparator = new UserSortComparator();
    }

    public void sortList(List<UserEntity> userList) {
        Collections.sort(userList, mUserSortComparator);
        advanceSingleVideoUserForSpeaker(userList);
    }

    public boolean sortForCameraStateChangedIfNeeded(List<UserEntity> userList, UserEntity userEntity) {
        if (userList.size() < Constants.SPEAKER_MODE_MEMBER_MIN_LIMIT) {
            return false;
        }
        if (isSpeakerOfScreenSharing(userList)) {
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
         * 排序的优先级：
         * 1、屏幕分享用户；
         * 2、房主；
         * 3、本人；
         * 4、比较 userName（中文用拼音）；
         * 5、userName 一样，比较 userId；
         */
        @Override
        public int compare(UserEntity o1, UserEntity o2) {
            if (o1 == null || o2 == null) {
                return -1;
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
