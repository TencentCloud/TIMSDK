package com.tencent.qcloud.tim.uikit.modules.search.groupinterface;

import com.tencent.imsdk.v2.V2TIMGroupInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;

import java.util.List;

public class TUISearchGroupResult {
    /**
     * 匹配到的群信息，或者是匹配到的群成员对应的群信息
     */
    private V2TIMGroupInfo groupInfo;
    /**
     * 群匹配字段, 详见 @TUISearchGroupMatchField
     *
     * @note
     * - 匹配命中群信息则 matchValue 为群匹配字段对应的值，不搜索群成员的匹配信息, matchMembers 为空；
     * - 反之，matchField 为 TUISearchGroupMatchField.SEARCH_FIELD_GROUP_NONE， matchValue为空，没有群匹配信息; 需进一步解析 matchMembers 获取匹配到的群成员信息
     */
    private int matchField;
    /**
     * 群匹配字段对应的值
     *
     * @note 当 matchField 为 SEARCH_FIELD_GROUP_NONE 时，该字段无效。
     */
    private String matchValue;
    /**
     * 匹配到的群成员信息
     */
    private List<TUISearchGroupMemberMatchResult> matchMembers;

    public V2TIMGroupInfo getGroupInfo() {
        return groupInfo;
    }

    public void setGroupInfo(V2TIMGroupInfo groupInfo) {
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
         * 群成员信息
         */
        private V2TIMGroupMemberFullInfo memberInfo;
        /**
         * 群成员匹配字段, 详见 @TUISearchGroupMemberMatchField
         */
        private int memberMatchField;
        /**
         * 群成员匹配字段对应的值
         */
        private String memberMatchValue;

        public V2TIMGroupMemberFullInfo getMemberInfo() {
            return memberInfo;
        }

        public void setMemberInfo(V2TIMGroupMemberFullInfo memberInfo) {
            this.memberInfo = memberInfo;
        }

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
