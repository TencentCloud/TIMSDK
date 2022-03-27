import React from "react";

import withMemo from "../../../utils/componentWithMemo";

const GroupTipsElemItem = (props: any): JSX.Element => {

    const groupInfoChange = (item) => {

        // kTIMGroupTipChangeFlag_Unknown,      // 未知的修改
        // kTIMGroupTipChangeFlag_Name,         // 修改群组名称
        // kTIMGroupTipChangeFlag_Introduction, // 修改群简介
        // kTIMGroupTipChangeFlag_Notification, // 修改群公告
        // kTIMGroupTipChangeFlag_FaceUrl,      // 修改群头像URL
        // kTIMGroupTipChangeFlag_Owner,        // 修改群所有者
        // kTIMGroupTipChangeFlag_Custom,       // 修改群自定义信息
        // kTIMGroupTipChangeFlag_Attribute,    // 群属性变更 (新增)
        const changeDisplay = ['未知','群名称','群简介','群公告','群头像','群主','群自定义信息','群属性']
        const { group_tips_group_change_info_flag, group_tips_group_change_info_value } = item;
        return `将${changeDisplay[group_tips_group_change_info_flag]}修改为${group_tips_group_change_info_value}`
    }
    const inviteInfo = (item)=>{
        return item.group_member_info_nick_name || item.group_member_info_identifier;
    }
    const tips_6 = ()=>{
        const { group_tips_elem_op_user_info,group_tips_elem_group_change_info_array } = props;
        const { user_profile_nick_name,user_profile_identifier } = group_tips_elem_op_user_info;
        const res= []
        for(let i = 0;i<group_tips_elem_group_change_info_array?.length;i++){
            res.push(`${user_profile_nick_name||user_profile_identifier}${groupInfoChange(group_tips_elem_group_change_info_array[i])}`)
        }
        return res
    }
    const tips_1 = ()=>{
        const { group_tips_elem_op_user_info,group_tips_elem_changed_group_memberinfo_array } = props;
        const { user_profile_nick_name,user_profile_identifier } = group_tips_elem_op_user_info;
        const res= []
        for(let i = 0;i<group_tips_elem_changed_group_memberinfo_array?.length;i++){
            res.push(`${user_profile_nick_name||user_profile_identifier}邀请${inviteInfo(group_tips_elem_changed_group_memberinfo_array[i])}进入群聊`)
        }
        return res
    }
    const tips_2 = ()=>{
        const { group_tips_elem_op_user_info } = props;
        
        return [`${group_tips_elem_op_user_info.user_profile_nick_name||group_tips_elem_op_user_info.user_profile_identifier}退出群聊`]
    }
    const getChangeType = () => {
        const { group_tips_elem_tip_type } = props;
        let res = ['未适配'];
        switch (group_tips_elem_tip_type) {
            // kTIMGroupTip_None,              // 无效的群提示 0
            // kTIMGroupTip_Invite,            // 邀请加入提示 1
            // kTIMGroupTip_Quit,              // 退群提示 2
            // kTIMGroupTip_Kick,              // 踢人提示 3
            // kTIMGroupTip_SetAdmin,          // 设置管理员提示 4
            // kTIMGroupTip_CancelAdmin,       // 取消管理员提示 5
            // kTIMGroupTip_GroupInfoChange,   // 群信息修改提示 6
            // kTIMGroupTip_MemberInfoChange,  // 群成员信息修改提示 7
            case 0:
                break;
            case 1:
                res = tips_1()
                break;
            case 2:
                res = tips_2()
                break;
            case 3:
                break;
            case 4:
                break;
            case 5:
                break;
            case 6:
                res = tips_6()
                break;
            case 7:
                break;
            default:
                break;
        }
        return res;
    }

    const item = () => <span className="message-view__item--text text right-menu-item">
        {
            getChangeType().map((item,index)=>{
                return <div key={index}>{item}</div>
            })
        }
    </span>;
    // console.log('grouptips', props)
    return item();
};

export default withMemo(GroupTipsElemItem);