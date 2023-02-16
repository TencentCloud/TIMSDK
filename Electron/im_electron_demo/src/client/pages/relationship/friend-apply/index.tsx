import React, { useEffect, useState } from "react";
import { ListItem } from "./ListItem";
import { debounce, differenceBy } from "lodash";
import { getFriendShipPendencyList, LIMITE_SIZE } from "./api";
import "./friend-apply.scss";
import { Table } from "tea-component";
import { isWin } from "../../../utils/tools";
import { RelationShipItemLoader } from "../../../components/skeleton";
import { DelayLoading } from "../../../components/delayLoading";
import { EmptyResult } from "../../../components/emptyResult";

const { scrollable } = Table.addons;

export const FriendApply = () => {
  const getHeight = () => window.innerHeight - 77 - (isWin() ? 30 : 0);

  const [height, setHeight ] = useState(getHeight());
  const [friendApplyList, setFriendApplyList] = useState([]);
  const [startSeq, setStartSeq] = useState(0);
  const [startTime, setStartTime] = useState(0);
  const [preSeq, setPreSeq] = useState(0);
  const [preTime, setPreTime] = useState(0);
  const [loading, setLoading] = useState(true);

  const getFriendApplyList = async (seq: number, time: number) => {
    setLoading(true);
    try {
      const res = await getFriendShipPendencyList({
        startSeq: seq,
        startTime: time,
      });
      const { pendency_page_current_seq = 0, pendency_page_start_time = 0, applyList = [] } = res;
      setFriendApplyList((pre) => differenceBy([...pre, ...applyList]));
      setPreSeq(startSeq);
      setPreTime(startTime);
      setStartSeq(pendency_page_current_seq);
      setStartTime(pendency_page_start_time);
    } catch (e) {
      console.log(e);
    }
    // setTimeout(() => {
      setLoading(false);
    // }, 1000)
  };

  
  const onScrollBottom = () => {
    if (loading || startSeq === 0 || startTime === 0 ) {
      return;
    }
    getFriendApplyList(startSeq, startTime)
  };

  const refreshList = async (seq: number, time: number) => {
    setLoading(true);
    try {
      const res = await getFriendShipPendencyList({
        startSeq: seq,
        startTime: time,
      });
      const { applyList = [] } = res;
      setFriendApplyList(pre => [...pre.slice(0,pre.length - LIMITE_SIZE), ...applyList]);
    } catch (e) {
      console.log(e);
    }
    setLoading(false);
  };

  useEffect(() => {
    window.addEventListener('resize', debounce(() => {
      setHeight(getHeight());
    }, 30));
    getFriendApplyList(0, 0);
  }, []);

  const columns = [
    {
      header: "",
      key: "friendApply",
      render: (record: any) => {
        return (
          <ListItem
            key={record.friend_add_pendency_info_idenitifer}
            userId={record.friend_add_pendency_info_idenitifer}
            userName={record.user_profile_nick_name}
            faceUrl={record.user_profile_face_url}
            depName={record.friend_add_pendency_info_add_source}
            onRefresh={() => refreshList(startSeq, startTime)}
          />
        );
      },
    },
  ];

  return (
    <div className="friend-apply">
      <div className="friend-apply--title">
        <span className="friend-apply--title__icon"></span>
        <span className="friend-apply--title__text">好友申请</span>
      </div>
      <div className="friend-apply--list">
        <DelayLoading delay={100} minDuration={400} isLoading={loading} fallback={<RelationShipItemLoader />}>
            <EmptyResult isEmpty={friendApplyList.length === 0} contentText="暂无好友申请">
              <Table
                hideHeader
                disableHoverHighlight
                className="friend-list--table"
                bordered={false}
                columns={columns}
                records={friendApplyList}
                addons={[
                  scrollable({
                    virtualizedOptions: {
                      height,
                      itemHeight: 60,
                      onScrollBottom,
                    },
                  }),
                ]}
              />
          </EmptyResult>
        </DelayLoading>
      </div>
    </div>
  );
};
