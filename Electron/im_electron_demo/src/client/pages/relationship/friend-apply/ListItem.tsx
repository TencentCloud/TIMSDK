import React from "react";
import { Avatar } from "../../../components/avatar/avatar";
import { friendshipHandleFriendAddRequest } from "./api";
import "./friend-apply.scss";

export const ListItem = (props: {
  faceUrl: string;
  userId: string;
  userName: string;
  depName: string;
  onRefresh: () => Promise<any>;
}) => {
  const { faceUrl, userId, userName, depName, onRefresh } = props;

  const handleApprove = async () => {
    try {
      await friendshipHandleFriendAddRequest({ userId: userId, action: 1 });
      await onRefresh();
    } catch (e) {
      console.log(e);
    }
  };

  const handleRefuse = async () => {
    try {
      await friendshipHandleFriendAddRequest({ userId: userId, action: 2 });
      await onRefresh();
    } catch (e) {
      console.log(e);
    }
  };

  return (
    <div className="friend-apply--list__item">
      <div className="item-left">
        <div className="item-left__avatar">
          <Avatar url={faceUrl} userID={userId} nickName={userName} />
        </div>
        <div className="item-left__info">
          <span className="item-left__info--name">{userName || userId}</span>
          {/* <span className="item-left__info--dep">{depName}</span> */}
        </div>
      </div>
      <div className="item-right">
        <span
          className="item-right__approve"
          onClick={() => handleApprove()}
        ></span>
        <span
          className="item-right__refuse"
          onClick={() => handleRefuse()}
        ></span>
      </div>
    </div>
  );
};
