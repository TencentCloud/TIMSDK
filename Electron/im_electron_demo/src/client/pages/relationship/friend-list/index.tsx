import React, { useState, useEffect } from "react";
import { debounce } from "lodash";
import { Button } from "tea-component";
import useAsyncRetryFunc from "../../../utils/react-use/useAsyncRetryFunc";
import { useDialogRef } from "../../../utils/react-use/useDialog";
import { getFriendList } from '../../../api';;
import { ListItem } from "./ListItem";
import "./friend-list.scss";
import { Table } from "tea-component";
import { isWin } from "../../../utils/tools";

import { RelationShipItemLoader } from "../../../components/skeleton";
import { DelayLoading } from "../../../components/delayLoading";
import { EmptyResult } from "../../../components/emptyResult";
import { AddFriendDialog } from "./AddFriendModal";

const { scrollable } = Table.addons;

export const FriendList = () => {
  const getHeight = () => window.innerHeight - 77 - (isWin() ? 30 : 0);
  const [height, setHeight ] = useState(getHeight());

  const addFriendDialogRef = useDialogRef();
  const { value, loading, retry } = useAsyncRetryFunc(async () => {
    return await getFriendList();
  }, []);
  const friendList = value || [];
  const columns = [
    {
      header: "",
      key: "friend",
      render: (record: any) => {
        return (
          <ListItem
          key={record.friend_profile_identifier}
          userId={record.friend_profile_identifier}
          userName={record.friend_profile_user_profile.user_profile_nick_name}
          friendProfile={record.friend_profile_user_profile}
          onRefresh={retry}
        />
        );
      },
    },
  ];

  const addFriend = () => {
    addFriendDialogRef.current.open()
  };

  const onSucess =() => {

  }

  useEffect(() => {
    window.addEventListener('resize', debounce(() => {
      setHeight(getHeight());
    }, 30));
  }, []);

  return (
    <div className="friend-list">
      <div className="friend-list--title">
        <div>
          <span className="friend-list--title__icon"></span>
          <span className="friend-list--title__text">好友列表</span>
        </div>
        <Button className="friend-list--title__btn title--right__button" type="primary" onClick={addFriend}>添加好友</Button>
      </div>
      <div className="friend-list--content">
        <DelayLoading delay={100} minDuration={400} isLoading={loading} fallback={<RelationShipItemLoader />}>
          <EmptyResult isEmpty={friendList.length === 0} contentText="暂无好友">
            <Table
              hideHeader
              disableHoverHighlight
              className="friend-list--table"
              bordered={false}
              columns={columns}
              records={friendList}
              addons={[
                scrollable({
                  virtualizedOptions: {
                    height,
                    itemHeight: 60,
                    // onScrollBottom,
                  },
                }),
              ]}
            />
          </EmptyResult>
        </DelayLoading>
      </div>
      <AddFriendDialog
        dialogRef={addFriendDialogRef}
        onSuccess={onSucess}
      />
    </div>
  );
};
