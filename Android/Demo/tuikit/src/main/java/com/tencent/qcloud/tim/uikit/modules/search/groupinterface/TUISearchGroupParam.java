package com.tencent.qcloud.tim.uikit.modules.search.groupinterface;

import java.util.List;

public class TUISearchGroupParam {
    /// 群搜索匹配字段
    public static final class TUISearchGroupMatchField {
        public static final int SEARCH_FIELD_GROUP_ID = 0x01;
        public static final int SEARCH_FIELD_GROUP_NAME = 0x01 << 1;
        public static final int SEARCH_FIELD_GROUP_NONE = 0x01 << 2;
    }

    /// 群搜索时匹配群成员字段
    public static final class TUISearchGroupMemberMatchField {
        public static final int SEARCH_FIELD_MEMBER_USER_ID = 0x01;
        public static final int SEARCH_FIELD_MEMBER_NICK_NAME = 0x01 << 1;
        public static final int SEARCH_FIELD_MEMBER_REMARK = 0x01 << 2;
        public static final int SEARCH_FIELD_MEMBER_NAME_CARD = 0x01 << 3;
        public static final int SEARCH_FIELD_MEMBER_NONE = 0x01 << 4;
    }

    private boolean isSearchGroupID;

    private boolean isSearchGroupName;

    private boolean isSearchMemberUserID;

    private boolean isSearchMemberNickName;

    private boolean isSearchMemberRemark;

    private boolean isSearchMemberNameCard;

    public boolean isSearchGroupID() {
        return isSearchGroupID;
    }

    public void setSearchGroupID(boolean searchGroupID) {
        isSearchGroupID = searchGroupID;
    }

    public boolean isSearchGroupName() {
        return isSearchGroupName;
    }

    public void setSearchGroupName(boolean searchGroupName) {
        isSearchGroupName = searchGroupName;
    }

    public boolean isSearchMemberUserID() {
        return isSearchMemberUserID;
    }

    public void setSearchMemberUserID(boolean searchMemberUserID) {
        isSearchMemberUserID = searchMemberUserID;
    }

    public boolean isSearchMemberNickName() {
        return isSearchMemberNickName;
    }

    public void setSearchMemberNickName(boolean searchMemberNickName) {
        isSearchMemberNickName = searchMemberNickName;
    }

    public boolean isSearchMemberRemark() {
        return isSearchMemberRemark;
    }

    public void setSearchMemberRemark(boolean searchMemberRemark) {
        isSearchMemberRemark = searchMemberRemark;
    }

    public boolean isSearchMemberNameCard() {
        return isSearchMemberNameCard;
    }

    public void setSearchMemberNameCard(boolean searchMemberNameCard) {
        isSearchMemberNameCard = searchMemberNameCard;
    }

    /**
     * 搜索关键字列表，最多支持 5 个
     */
    private List<String> keywordList;

    public void setKeywordList(List<String> keywordList) {
        this.keywordList = keywordList;
    }

    public List<String> getKeywordList() {
        return keywordList;
    }

}
