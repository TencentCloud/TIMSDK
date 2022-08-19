package com.tencent.qcloud.tuikit.tuisearch.bean;

import java.util.List;

public class TUISearchGroupResult {
    /**
     * 匹配到的群信息，或者是匹配到的群成员对应的群信息
     * 
     * The matched group information, or the group information corresponding to the matched group members
     */
    private GroupInfo groupInfo;
    /**
     * 群匹配字段, 详见 @TUISearchGroupMatchField
     *
     * @note
     * - 匹配命中群信息则 matchValue 为群匹配字段对应的值，不搜索群成员的匹配信息, matchMembers 为空；
     * - 反之，matchField 为 TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE， matchValue为空，没有群匹配信息; 需进一步解析 matchMembers 获取匹配到的群成员信息
     * 
     * 
     * Group match field, see details @TUISearchGroupMatchField
     * 
     * @note
     * - If the match hits group information, matchValue is the value corresponding to the group match field. Matching information of group members is not searched, and matchMembers is empty.
     * - On the contrary, matchField is TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE, matchValue is empty, and there is no group matching information; further analysis of matchMembers is required to obtain the matched group member information.
     */
    private int matchField;
    /**
     * 群匹配字段对应的值
     *
     * @note 当 matchField 为 SEARCH_FIELD_GROUP_NONE 时，该字段无效。
     * 
     * 
     * The value corresponding to the group match field
     * 
     * @note This field is invalid when matchField is SEARCH_FIELD_GROUP_NONE.
     */
    private String matchValue;
    /**
     * 匹配到的群成员信息
     * 
     * Matched group member information
     */
    private List<TUISearchGroupMemberMatchResult> matchMembers;

    public GroupInfo getGroupInfo() {
        return groupInfo;
    }

    public void setGroupInfo(GroupInfo groupInfo) {
        this.groupInfo = groupInfo;
    }

    public void setMatchField(int matchField) {
        this.matchField = matchField;
    }

    public int getMatchField() {
        return matchField;
    }

    public String getMatchValue() {
        return matchValue;
    }

    public void setMatchValue(String matchValue) {
        this.matchValue = matchValue;
    }

    public List<TUISearchGroupMemberMatchResult> getMatchMembers() {
        return matchMembers;
    }

    public void setMatchMembers(List<TUISearchGroupMemberMatchResult> matchMembers) {
        this.matchMembers = matchMembers;
    }

    public static final class TUISearchGroupMemberMatchResult {
        /**
         * 群成员匹配字段, 详见 @TUISearchGroupMemberMatchField
         * 
         * Group member matching field, see details @TUISearchGroupMemberMatchField
         */
        private int memberMatchField;
        /**
         * 群成员匹配字段对应的值
         * 
         * The value corresponding to the group member match field
         */
        private String memberMatchValue;

        public void setMemberMatchField(int memberMatchField) {
            this.memberMatchField = memberMatchField;
        }

        public int getMemberMatchField() {
            return memberMatchField;
        }

        public String getMemberMatchValue() {
            return memberMatchValue;
        }

        public void setMemberMatchValue(String memberMatchValue) {
            this.memberMatchValue = memberMatchValue;
        }
    }
}
