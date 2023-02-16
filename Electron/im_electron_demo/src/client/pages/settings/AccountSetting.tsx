import React, { useEffect, useState } from 'react';
import { useDispatch } from 'react-redux';
import { Button, Checkbox } from 'tea-component';
import { useHistory } from "react-router-dom";

import timRenderInstance from '../../utils/timRenderInstance';
import { setIsLogInAction, userLogout, } from '../../store/actions/login';
import { clearConversation } from '../../store/actions/conversation';
import { clearHistory } from '../../store/actions/message';
import { updateHistoryMessageToStore } from '../../utils/LocalStoreInstance';
import { setUserInfo } from '../../store/actions/user';
import { Avatar } from '../../components/avatar/avatar';


export const AccountSetting = (): JSX.Element => {
    const history = useHistory();
    const dispatch = useDispatch();
    const [selfUserInfo, setSelfUserInfo] = useState({

    })
    const [commRecvOpt,setCommRecvOpt] = useState(false);
    const [c2cRes,setC2cRes] = useState([]);
    const [groupRes,setGroupRes] = useState([]);
    
    const logOutHandler = async () => {
        await timRenderInstance.TIMLogout();
        updateHistoryMessageToStore();
        dispatch(userLogout());
        history.replace('/login');
        dispatch(setIsLogInAction(false));
        dispatch(clearConversation())
        dispatch(clearHistory())
    };

    const getSelfInfo = async () => {
        const d = await timRenderInstance.TIMGetLoginUserID();
        const userId = d.data.json_param;
        const { data: { code, json_param } } = await timRenderInstance.TIMProfileGetUserProfileList({
            json_get_user_profile_list_param: {
                friendship_getprofilelist_param_identifier_array: [userId]
            },
            hide_tips: true
        });

        if (code === 0) {
            const {
                user_profile_role: role,
                user_profile_face_url: faceUrl,
                user_profile_nick_name: nickName,
                user_profile_identifier: userId,
                user_profile_gender: gender,
                user_profile_self_signature: signature,
                user_profile_add_permission: addPermission
            } = JSON.parse(json_param)[0];
            setSelfUserInfo({
                userId,
                faceUrl,
                nickName,
                role,
                signature,
                gender,
                addPermission
            })
        }
    }
    const getCommRecType = async ()=>{
        const { data: { code, json_param }  } = await timRenderInstance.TIMConvGetConvList({});
        let res = true;;
        const list = JSON.parse(json_param);
        for(let i = 0;i<list.length;i++){
            const { conv_recv_opt } = list[i];
            if(conv_recv_opt != 2){
                res = false;
                break;
            }
        }
        groupIds(list);
        setCommRecvOpt(res);
    }
    const groupIds = (list)=>{
        const c2cRes = [];
        const groupRes = [];
   
        
        for(let i = 0;i<list.length;i++){
            const { conv_type,conv_id } = list[i]
            if(conv_type===1){
                // c2c
                c2cRes.push(conv_id)
            }
            if(conv_type === 2){
                // group
                groupRes.push(conv_id)
            }
        }
        setC2cRes(c2cRes)
        setGroupRes(groupRes)
    }
    const hasInfo = () => {
        return Object.keys(selfUserInfo).length > 0
    }
    const getShowInfo = () => {
        const {

            userId,
            faceUrl,
            nickName,
            role,
            signature,
            gender,
            addPermission
        } = selfUserInfo as any;
        return {

            userId,
            faceUrl,
            nickName,
            role,
            signature,
            gender,
            addPermission
        }
    }
    const groupArray = (count,array) => {
        const array_copy = JSON.parse(JSON.stringify(array));
        const res = [];
        res.push(array_copy.splice(0,count));
        console.log(res)
        if(array_copy.length){
            const left = groupArray(count,array_copy);
            for(let j = 0;j<left.length;j++){
                res.push(left[j])
            }
        }
        return res;
    }
    const commRecvOptValueChange = async (isRecv)=>{
        let isSet = false;
        if(isRecv){
            isSet = true;
        }
        const cg = groupArray(30,c2cRes);
        for(let i = 0;i<cg.length;i++){
            await timRenderInstance.TIMMsgSetC2CReceiveMessageOpt({
                params: cg[i],
                opt: isSet ? 2 : 0,
                hide_tips:true
            })
        }
        for(let i = 0;i<groupRes.length;i++){
            await timRenderInstance.TIMMsgSetGroupReceiveMessageOpt({
                group_id: groupRes[i],
                opt: isSet ? 2 : 0,
                hide_tips:true
            })
        }
        
        setCommRecvOpt(isRecv);
    }
    useEffect(() => {
        getSelfInfo();
        getCommRecType();
    }, [])
    return (
        <div className="connect">
            <header className="connect-header">
                <span className="connect-header--logo"></span>
                <span className="connect-header--text">账号设置</span>
            </header>
            <section className="connet-section">
                {/* <div className="connect-desc">
                    <p>
                        简单接入，稳定必答、覆盖全球的即时通信云服务
                    </p>
                </div> */}
                {/* <Button onClick={logOutHandler} style={{ fontSize: "16px",width:"200px",height:"40px",margin: "auto",marginLeft:"30%",marginTop:"20%" }}>退出登录</Button> */}
                <div>
                    <div>账号信息：</div>
                    {
                        hasInfo() ? (
                            <div className='info-panel'>
                                <div className='info-avatar'><Avatar url={getShowInfo().faceUrl} userID={getShowInfo().userId}></Avatar></div>
                                <div className='info-name'>{ getShowInfo().nickName || getShowInfo().userId }</div>
                                <div className='info-out'><Button onClick={logOutHandler} style={{ fontSize: "16px", width: "200px", height: "40px", margin: "auto" }}>退出登录</Button></div>
                            </div>
                        ) : null
                    }
                </div>
                <div>
                    <div>消息：</div>
                    <div  className='info-panel'>
                        <Checkbox value={commRecvOpt} onChange={commRecvOptValueChange}>PC端在线时移动端不接受离线推送</Checkbox>
                    </div>
                </div>
            </section>
        </div>
    )
}