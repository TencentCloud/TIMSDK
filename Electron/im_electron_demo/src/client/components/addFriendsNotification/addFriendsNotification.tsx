import React from "react";
import { friendshipHandleFriendAddRequest } from "../../pages/relationship/friend-apply/api";
import { Button } from "tea-component/lib/button/Button";
import { useMessageDirect } from "../../utils/react-use/useDirectMsgPage";
import timRenderInstance from "../../utils/timRenderInstance";

export const AddFriendsNotification = ({ userID,onClick }) => {
    const accept= async () => {
       await friendshipHandleFriendAddRequest({ userId: userID, action: 1 });
       onClick(userID,true)
    }
    const reject = async () => {
        await friendshipHandleFriendAddRequest({ userId: userID, action: 2 });
        onClick(userID,false)
    }
    const style = { marginRight: 5 };
    return (
        <div>
            <Button type="primary" style={style} onClick={accept}>同意</Button><Button type="error" onClick={reject}>拒绝</Button>
        </div>
    )
}