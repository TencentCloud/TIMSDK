import React, { useEffect } from "react"
import { useDispatch, useSelector } from "react-redux"
import { setUnreadCount } from "../../store/actions/conversation";
import timRenderInstance from "../../utils/timRenderInstance"

export const UnreadCount =  (): JSX.Element => {
    const { unreadCount } = useSelector((state: State.RootState) => state.conversation);
    const dispatch = useDispatch()
    const getAllUnreadCount = async () => {
        const res = await timRenderInstance.TIMConvGetTotalUnreadMessageCount({})
        const { json_param,code } = res.data || {};
        if(code === 0){
            const data = JSON.parse(json_param)
            const { conv_get_total_unread_message_count_result_unread_count } = data;
            console.log(conv_get_total_unread_message_count_result_unread_count)
            dispatch(setUnreadCount(conv_get_total_unread_message_count_result_unread_count))
        }
    }
    useEffect(()=>{
        getAllUnreadCount()
    },[])
    return (
        <>
        {
            unreadCount === 0 ? null : (
                <div className="unread" >
                    {
                        unreadCount > 99 ? '···': unreadCount
                    }
                </div>
            )
        }
        </>
    )
}