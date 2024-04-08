package com.tencent.qcloud.tuikit.tuisearch.bean;

import java.util.List;

public class TUISearchGroupResult {
    /**
     * The matched group information, or the group information corresponding to the matched group members
     */
    private GroupInfo groupInfo;
    /**
     * Group match field, see details @TUISearchGroupMatchField
     *
     * @note
     * - If the match hits group information, matchValue is the value corresponding to the group match field. Matching information of group members is not
     * searched, and matchMembers is empty.
     * - On the contrary, matchField is TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE, matchValue is empty, and there is no group matching information;
     * further analysis of matchMembers is required to obtain the matched group member information.
     */
    private int matchField;
    /**
     * The value corresponding to the group match field
     *
     * @note This field is invalid when matchField is SEARCH_FIELD_GROUP_NONE.
     */
    private String matchValue;
    /**
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
         * Group member matching field, see details @TUISearchGroupMemberMatchField
         */
        private int memberMatchField;
        /**
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
