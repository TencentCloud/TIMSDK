import React from "react";

import { GroupList as GroupListType } from "../../../../api";
import { GroupItem } from "./GroupItem";
import { EmptyResult } from '../../../../components/emptyResult'

import "./group-list.scss";

export const GroupList = (props: {
  value: GroupListType;
  onRefresh: () => Promise<GroupListType>;
}): JSX.Element => {
  const { value, onRefresh } = props;

  return (
    <div className="group-list">
      <EmptyResult isEmpty={!value?.length} contentText="暂无数据">
        {value?.map((v) => (
          <GroupItem
            key={v.group_base_info_group_id}
            groupId={v.group_base_info_group_id}
            groupAvatar={v.group_base_info_face_url}
            groupName={v.group_base_info_group_name}
            groupOwner={v.group_detial_info_owener_identifier}
            groupType={v.group_base_info_group_type}
            profile={v}
            onRefresh={onRefresh}
          />
        ))}
      </EmptyResult>
    </div>
  );
};
