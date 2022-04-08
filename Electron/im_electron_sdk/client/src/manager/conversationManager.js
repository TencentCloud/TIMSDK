import TimRender from "../../../im_electron_sdk/dist/renderer";
// import TimRender from "im_electron_sdk/dist/renderer";
const timRenderInstance = new TimRender();
const ConversationManager = {
    TIMConvCreate(){
        return timRenderInstance.TIMConvCreate({
            convId:"test",
            convType:1,
            userData:'222',
        })
    },
    TIMConvDelete(){
        return timRenderInstance.TIMConvDelete({
            convId:"test",
            convType:1,
            userData:'222',
        })
    },
    TIMConvGetConvList(){
        return timRenderInstance.TIMConvGetConvList({
            userData:'22TIMConvGetConvList2',
        })
    },
    TIMConvSetDraft(){
        return timRenderInstance.TIMConvSetDraft({
            convId:"admin",
            convType:1,
            draftParam: {
                draft_edit_time: (Date.now() / 1000) + 60 * 60 * 24, 
                draft_msg: {
                    message_elem_array: [
                        {
                            "elem_type" : 0,
                            "text_elem_content" : "this draft"
                        }
                    ]
                },
                draft_user_define: "",
            },
        })
        
    },
    TIMConvCancelDraft(){
        return timRenderInstance.TIMConvCancelDraft({
            convId:"test",
            convType:1,
        })
    },
    TIMConvGetConvInfo(){
        return timRenderInstance.TIMConvGetConvInfo({
            json_get_conv_list_param:[{
                "get_conversation_list_param_conv_id":'6789',
                "get_conversation_list_param_conv_type": 1
            }],
            user_data:'TIMConvGetConvInfo', 
        })
    },
    TIMConvPinConversation(){
        return timRenderInstance.TIMConvPinConversation({
            convId:'6789',
            convType:1,
            isPinged:true,
            user_data:'TIMConvGetConvInfo', 
        })
    },
    TIMConvGetTotalUnreadMessageCount(){
        return timRenderInstance.TIMConvGetTotalUnreadMessageCount({
            user_data:'TIMConvGetTotalUnreadMessageCount', 
        })
    },
    TIMSetConvTotalUnreadMessageCountChangedCallback(callback){
        return timRenderInstance.TIMSetConvTotalUnreadMessageCountChangedCallback({
            user_data:"TIMSetConvTotalUnreadMessageCountChangedCallback",
            callback:(...data)=>{
                console.log(data)
                callback(JSON.stringify({data}))
            }
        })
    },
    TIMSetConvEventCallback:(callback)=>{
        return timRenderInstance.TIMSetConvEventCallback({
            user_data:"TIMSetConvEventCallback",
            callback:(...data)=>{
                callback(JSON.stringify({data}))
                // console.log(data,'TIMSetConvEventCallback');
            }
        })
    }
}
export default ConversationManager;