import React, { useEffect, useRef } from "react"
import { useMessageDirect } from "../../utils/react-use/useDirectMsgPage";
import { Button } from "tea-component"
import { Avatar } from "../avatar/avatar"
import timRenderInstance from "../../utils/timRenderInstance";

import './index.scss';

type Props = {
    callback: Function,
    profile: State.userInfo
}
export const ProfilePannel = (props: Props): JSX.Element => {
    const { callback, profile } = props;
    const { userId, faceUrl, nickName, gender, signature, addPermission } = profile
    const sendMsg = useMessageDirect()
    const refPopup = useRef(null)
    const sendMessage = async () => {

        const data = await timRenderInstance.TIMProfileGetUserProfileList({
            json_get_user_profile_list_param: {
                friendship_getprofilelist_param_identifier_array: [userId]
            }
        })
        const { code, json_param } = data.data;

        if (code === 0) {
            sendMsg({
                profile: JSON.parse(json_param)[0],
                convType: 1,
            })
            callback()
        }
    }
    useEffect(() => {
        document.addEventListener('click', handlePopupClick);
        return () => {
            document.removeEventListener('click', handlePopupClick);
        }
    }, []);

    const handlePopupClick = (e) => {
        if (!refPopup.current) return
        if (!refPopup.current.contains(e.target as Node) && refPopup.current !== e.target) {
            callback()
        }
    }
    const getGender = (gender) => {
        const arr = ['未知', '男', '女']
        return arr[Number(gender)] || arr[0]
    }
    const getAddPermission = (addPermission) => {
        const arr = ['未知', '允许任何人添加好友', '添加好友需要验证', '拒绝任何人添加好友']
        return arr[Number(addPermission)] || arr[0]
    }

    return <div className="userinfo-avatar--panel" ref={refPopup}>
        <div className="card-content">
            <div className="main-info">
                <div className="info-item">
                    <Avatar nickName={nickName} userID={userId} url={faceUrl} />
                    <div className="nickname">{nickName || userId}</div>
                </div>
                {/* <div className="info-btn" onClick={handleAvatarClick}><Icon type="setting" /></div> */}
            </div>
            <div className="info-bar">
                <span className="info-key">ID</span>
                <span className="info-val nickname">{userId}</span>
            </div>
            <div className="info-bar">
                <span className="info-key">昵称</span>
                <span className="info-val">{nickName || '未设置'}</span>
            </div>
            <div className="info-bar">
                <span className="info-key">性别</span>
                <span className="info-val">{getGender(gender)}</span>
            </div>
            <div className="info-bar">
                <span className="info-key">签名</span>
                <span className="info-val">{signature || '未设置'}</span>
            </div>
            <div className="info-bar">
                <span className="info-key">加好友选项</span>
                <span className="info-val">{getAddPermission(addPermission)}</span>
            </div>
            <div className="info-bar">
                <Button
                    type="primary"
                    onClick={sendMessage}
                    style={{ width: '100%' }}
                >
                    发消息
                </Button>
            </div>
        </div>
    </div>
}