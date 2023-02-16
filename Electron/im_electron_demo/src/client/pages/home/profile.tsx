import React, { useEffect, useState } from "react"
import { useDispatch, useSelector } from "react-redux";
import timRenderInstance from "../../utils/timRenderInstance";
import { setUserInfo } from '../../store/actions/user';
import { AvatarWithProfile } from "../../components/avatarWithProfile";
import { useHistory } from "react-router-dom";
import { EditProfile } from "./editProfile";
import { isWin } from "../../utils/tools";
export const Profile = (): JSX.Element => {
    const dispatch = useDispatch();
    const history = useHistory()
    const profile = useSelector((state: State.RootState) => state.userInfo);
    const { userId } = profile;
    const getSelfInfo = async () => {
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
            dispatch(setUserInfo({
                userId,
                faceUrl,
                nickName,
                role,
                signature,
                gender,
                addPermission
            }));
        }
    }
    useEffect(() => {
        if (userId) {
            console.log('获取个人信息')
            getSelfInfo()
        } else {
            history.replace('/')
        }
    }, []);

    return (
        <div className={`userinfo-avatar ${isWin()?'':'ismac'}`}>
           <AvatarWithProfile profile={profile}/>
        </div>
    )
}

