import TimRender from "../../../im_electron_sdk/dist/renderer";
// import TimRender from "im_electron_sdk/dist/renderer";
const timRenderInstance = new TimRender();
const TimBaseManager = {
  TIMGroupCreate: () => {
    return timRenderInstance.TIMGroupCreate({
      params:
      {
        "create_group_param_add_option": 2,
        "create_group_param_group_name": "FFFFFFF",
        "create_group_param_group_type": 1,
        // create_group_param_custom_info: [{
        //   group_info_custom_string_info_key: 'group_info',
        //   group_info_custom_string_info_value: 'test value 1'
        // },
        // {
        //   group_info_custom_string_info_key: 'custom_public',
        //   group_info_custom_string_info_value: 'custom public value'
        // }],
        // "create_group_param_face_url": "http://oaim.crbank.com.cn:30003/emoji/qunioc.png",
        "create_group_param_group_member_array": [{ "group_member_info_member_role": 1, "group_member_info_identifier": "3708" }],
        // "create_group_param_introduction": "12312",
        // "create_group_param_notification": "121212"
      },
      data: "ssss"
    });
  },
  TIMGroupDelete: (groupId) => {
    return timRenderInstance.TIMGroupDelete({
      groupId,
      data: "ssss"
    });
  },
  async TIMMsgSendMessageReadReceipts(){
    const data = await timRenderInstance.TIMMsgGetMsgList({
         conv_id: "@TGS#2N7OQRSHS",
         conv_type: 2,
         params: {
             msg_getmsglist_param_last_msg: null,
             msg_getmsglist_param_count: 100
         }
     })
     var d = JSON.parse(data.data.json_params);
     return timRenderInstance.TIMMsgSendMessageReadReceipts({
       json_msg_array:JSON.stringify([
         d[0]
       ]),
     }); 
   },
   async TIMMsgGetMessageReadReceipts(){
 
     const data = await timRenderInstance.TIMMsgGetMsgList({
       conv_id: "@TGS#_im_discuss_Zice8DNTw3REtfSs",
       conv_type: 2,
       params: {
           msg_getmsglist_param_last_msg: null,
           msg_getmsglist_param_count: 100
       }
   })
   var d = JSON.parse(data.data.json_params);
    console.log(d[0])
     return timRenderInstance.TIMMsgGetMessageReadReceipts({
       json_msg_array:JSON.stringify([
        d[0]
       ]),
       user_data:"12"
     }); 
   },
   async TIMMsgGetGroupMessageReadMemberList(){
     const data = await timRenderInstance.TIMMsgGetMsgList({
       conv_id: "@TGS#2N7OQRSHS",
       conv_type: 2,
       params: {
           msg_getmsglist_param_last_msg: null,
           msg_getmsglist_param_count: 100
       }
   })
   const arr = JSON.parse(data.data.json_params);
     return timRenderInstance.TIMMsgGetGroupMessageReadMemberList({
       json_msg:JSON.stringify(arr[0]),
       filter: 0,
       next_seq: 0,
       count: 10,
     }); 
   },
   
  TIMGroupGetJoinedGroupList: () => {
    return timRenderInstance.TIMGroupGetJoinedGroupList();
  },
  TIMGroupGetGroupInfoList: () => {
    return timRenderInstance.TIMGroupGetGroupInfoList({
      groupIds: ["@TGS#2F7WEKLHX"],
      data: 'test data'
    })
  },
  TIMGroupModifyGroupInfo: () => {
    return timRenderInstance.TIMGroupModifyGroupInfo({
      params: {
        group_modify_info_param_group_id: "@TGS#a5X7C5HH2",
        group_modify_info_param_group_name: "modified group name",
        group_modify_info_param_modify_flag: 2,
        group_modify_info_param_notification: "modified notifaction"
      },
      data: 'test data'
    })
  },
  TIMGroupGetMemberInfoList: (id,seq) => {
    return timRenderInstance.TIMGroupGetMemberInfoList({
      params: {
        group_get_members_info_list_param_group_id: "@TGS#_im_discuss_6iQBFthZWrmRdcYS",
        group_get_members_info_list_param_next_seq: seq,
      }
    })
  },
  TIMGroupModifyMemberInfo: () => {
    return timRenderInstance.TIMGroupModifyMemberInfo({
      params: {
        group_modify_member_info_group_id: "@TGS#1UHQ3OKHC",
        group_modify_member_info_identifier: '109442',
        group_modify_member_info_modify_flag: 8,
        group_modify_member_info_name_card: 'Modified Name card 1111'
      },
      data: 'test data'
    })
  },
  TIMGroupGetPendencyList: () => {
    return timRenderInstance.TIMGroupGetPendencyList({
      params: {
        group_pendency_option_start_time: 0,
        group_pendency_option_max_limited: 0,
      },
      data: 'test data'
    })
  },
  TIMGroupReportPendencyReaded: () => {
    return timRenderInstance.TIMGroupReportPendencyReaded({
      timeStamp: 0,
      data: 'test data'
    })
  },
  TIMGroupHandlePendency: () => {
    return timRenderInstance.TIMGroupHandlePendency({
      params: {
        startTime: 0,
        maxLimited: 0,
      },
      data: 'test data'
    })
  },
  TIMGroupInitGroupAttributes: (groupId) => {
    console.log(groupId);
    return timRenderInstance.TIMGroupInitGroupAttributes({
      groupId,
      attributes: [{
        group_atrribute_key: 'attribute1',
        group_atrribute_value: 'hello'
      }],
      data: 'test data'
    })
  },
  TIMGroupSetGroupAttributes: (groupId) => {
    return timRenderInstance.TIMGroupSetGroupAttributes({
      groupId,
      attributes: [{
        group_atrribute_key: 'attribute2',
        group_atrribute_value: 'hello22'
      }],
      data: 'test data'
    })
  },
  TIMGroupDeleteGroupAttributes: (groupId) => {
    return timRenderInstance.TIMGroupDeleteGroupAttributes({
      groupId,
      attributesKey: ["attribute1"],
      data: 'test data'
    })
  },
  TIMGroupGetGroupAttributes: (groupId) => {
    return timRenderInstance.TIMGroupGetGroupAttributes({
      groupId,
      attributesKey: ["attribute1"],
      data: 'test data'
    })
  },
  TIMSetGroupAttributeChangedCallback: (cbk) => {
    return timRenderInstance.TIMSetGroupAttributeChangedCallback({
      callback: (...args) => {
        const [[data, user_data]] = args;
        cbk(JSON.stringify({
          data, user_data
        }))
      },
      data: 'test data'
    })
  },
  TIMGroupJoin: () => {
    return timRenderInstance.TIMGroupJoin({
      groupId: '@TGS#2WPDHLWH6',
      helloMsg: 'hello',
      data: 'test data'
    })
  },
  TIMGroupQuit: () => {
    return timRenderInstance.TIMGroupQuit({
      groupId: '@TGS#1UEDUNNHW',
      data: 'test data'
    })
  },
  TIMGroupGetOnlineMemberCount: () => {
    return timRenderInstance.TIMGroupGetOnlineMemberCount({
      groupId: '@TGS#a4LPQ6HHW',
      data: 'test data'
    })
  },
  TIMGroupSearchGroups: () => {
    return timRenderInstance.TIMGroupSearchGroups({
      searchParams: {
        group_search_params_keyword_list: ['test'],
        group_search_params_field_list: [2]
      },
      data: 'test data'
    })
  },
  TIMGroupSearchGroupMembers: () => {
    return timRenderInstance.TIMGroupSearchGroupMembers({
      searchParams: {
        group_search_member_params_groupid_list: ['@TGS#1CT'],
        group_search_member_params_keyword_list: ['327'],
        group_search_member_params_field_list: [1,2,4,8]
      },
      data: 'test data'
    })
  },
  TIMGroupInviteMember: () => {
    return timRenderInstance.TIMGroupInviteMember({
      params: {
        group_invite_member_param_group_id: "@TGS#1I2TQ6HHE",
        group_invite_member_param_identifier_array: ['940928'],
      },
      data: 'test data'
    })
  },
  TIMGroupDeleteMember: () => {
    return timRenderInstance.TIMGroupDeleteMember({
      params: {
        group_delete_member_param_group_id: "@TGS#1I2TQ6HHE",
        group_delete_member_param_identifier_array: ['940928'],
      },
      data: 'test data'
    })
  },
  TIMSetGroupTipsEventCallback: (cbk) => {
    return timRenderInstance.TIMSetGroupTipsEventCallback({
      callback: (...args) => {
        const [[data, user_data]] = args;
        cbk(JSON.stringify({
          data, user_data
        }))
      },
      data: 'test data'
    })
  }
}

export default TimBaseManager;