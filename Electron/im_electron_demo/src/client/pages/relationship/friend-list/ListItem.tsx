import React, { useState } from "react";
import { Button, PopConfirm } from "tea-component";
import { Avatar } from "../../../components/avatar/avatar";
import { AvatarWithProfile } from "../../../components/avatarWithProfile";

import { addFriendsToBlackList, deleteFriend } from '../../../api';
import { useMessageDirect } from "../../../utils/react-use/useDirectMsgPage";
import "./friend-list.scss";

export const ListItem = (props: {
  userId: string;
  userName: string;
  friendProfile: State.userProfile;
  onRefresh: () => Promise<any>;
}) => {
  const { userId, userName, onRefresh, friendProfile } = props;
  const { user_profile_face_url, user_profile_role, user_profile_nick_name, user_profile_add_permission, user_profile_identifier, user_profile_gender, user_profile_self_signature } = friendProfile;
  const directToMsgPage = useMessageDirect();
  const handleDelete = async (close: () => any) => {
    try {
      await deleteFriend(userId);
      close();
      onRefresh();
    } catch (e) {
      console.log(e);
    }
  };


    const profile = {
      userId: user_profile_identifier,
      nickName: user_profile_nick_name,
      faceUrl: user_profile_face_url,
      gender: user_profile_gender,
      signature: user_profile_self_signature,
      role: user_profile_role,
      addPermission: user_profile_add_permission
  }

  const addToBlackList = async (close) => {
    try {
      await addFriendsToBlackList([userId]);
      close();
      onRefresh();
    } catch (e) {
      console.log(e)
    }
  }
  const toMessage = ()=>{
    directToMsgPage({
      convType: 1,
      profile: friendProfile,
    });
  }
  return (
    <div className="friend-list--content__item" >
      <div className="item-left" onClick={toMessage}>
        <div className="item-left__avatar">
          <AvatarWithProfile profile={profile} />
        </div>
        <div className="item-left__info">
          <span className="item-left__info--name">{userName || userId}</span>
          {/* <span className="item-left__info--dep">{depName}</span> */}
        </div>
      </div>
      <div className="item-right">
        <PopConfirm
          title="确认要删除该好友吗?"
          footer={(close) => (
            <>
              <Button type="link" onClick={(e) => {
                e.stopPropagation();
                handleDelete(close);
              } }>
                确认
              </Button>
              <Button type="text" onClick={close}>
                取消
              </Button>
            </>
          )}
        >
          <Button type="link" className="item-right__btn">
            删除
          </Button>
        </PopConfirm>
        <PopConfirm
          title="确认要将该好友加入到黑名单吗?"
          footer={(close) => (
            <>
              <Button type="link" onClick={(e) => {
                e.stopPropagation();
                addToBlackList(close);
              }}>
                确认
              </Button>
              <Button type="text" onClick={close}>
                取消
              </Button>
            </>
          )}
        >
          <Button type="link" className="item-right__btn">
            加入黑名单
          </Button>
        </PopConfirm>
      </div>
    </div>
  );
};
