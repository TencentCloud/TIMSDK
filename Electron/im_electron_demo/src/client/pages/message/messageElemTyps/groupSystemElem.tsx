import React from "react";

import withMemo from "../../../utils/componentWithMemo";

const GroupSysElm = (props: any): JSX.Element => {
    // kTIMGroupReport_None,         // 未知类型
    // kTIMGroupReport_AddRequest,   // 申请加群(只有管理员会接收到)
    // kTIMGroupReport_AddAccept,    // 申请加群被同意(只有申请人自己接收到)
    // kTIMGroupReport_AddRefuse,    // 申请加群被拒绝(只有申请人自己接收到)
    // kTIMGroupReport_BeKicked,     // 被管理员踢出群(只有被踢者接收到)
    // kTIMGroupReport_Delete,       // 群被解散(全员接收)
    // kTIMGroupReport_Create,       // 创建群(创建者接收, 不展示)
    // kTIMGroupReport_Invite,       // 邀请加群(被邀请者接收)
    // kTIMGroupReport_Quit,         // 主动退群(主动退出者接收, 不展示)
    // kTIMGroupReport_GrantAdmin,   // 设置管理员(被设置者接收)
    // kTIMGroupReport_CancelAdmin,  // 取消管理员(被取消者接收)
    // kTIMGroupReport_GroupRecycle, // 群已被回收(全员接收, 不展示)
    // kTIMGroupReport_InviteReq,    // 邀请加群(只有被邀请者会接收到)
    // kTIMGroupReport_InviteAccept, // 邀请加群被同意(只有发出邀请者会接收到)
    // kTIMGroupReport_InviteRefuse, // 邀请加群被拒绝(只有发出邀请者会接收到)
    // kTIMGroupReport_ReadReport,   // 已读上报多终端同步通知(只有上报人自己收到)
    // kTIMGroupReport_UserDefine,   // 用户自定义通知(默认全员接收)
    const opType = ["","有人申请加群","申请加群被同意","申请加群被拒绝","被管理员踢出群","群被解散","创建群","您被邀请加群","主动退群","被设置管理员","被取消管理员","群已被回收","邀请加群","邀请加群被同意","邀请加群被拒绝","已读上报多终端同步通知","用户自定义通知"]
    const getOpUser = () => {

    }
    const getOpType = () => {
        return opType[props.group_report_elem_report_type]
    }
    const item = (props) => {
        
        return (
                <div className="message-view__item--group-sys" >
                    {
                        getOpType()
                    }
                </div>
        )
    };
   
    return item(props);
}

export default withMemo(GroupSysElm)