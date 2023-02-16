import React from "react";
import { useDialogRef } from "../../../utils/react-use/useDialog";
import { Avatar } from "../../../components/avatar/avatar";
import "./group-member.scss";
import {
  GroupMemberListDrawer,
  GroupMemberListDrawerRecordsType,
} from "./MemberListDrawer";
import {
  AddMemberRecordsType,
  AddGroupMemberDialog,
} from "./AddGroupMemberDialog";
import {
  DeleteGroupMemberDialog,
  DeleteMemberRecordsType,
} from "./DeleteGroupMember";
import { getGroupMemberList } from "../../../api";
import useAsyncRetryFunc from "../../../utils/react-use/useAsyncRetryFunc";

export const GroupMember = (props: {
  onRefresh: () => Promise<any>;
  userIdentity: number;
  userId: string;
  groupId: string;
  groupType: number;
  groupAddOption: number;
  memberCount: number
}): JSX.Element => {
  const {
    groupId,
    groupType,
    userIdentity,
    memberCount
  } = props;

  // 获取群成员列表
  const { value, loading, retry } = useAsyncRetryFunc(async () => {
      return await getGroupMemberList({
        groupId,
        nextSeq: 0,
      })
  }, []);
  const userList: any = value?.group_get_memeber_info_list_result_info_array || [];

  const popupContainer = document.getElementById("messageInfo");

  const dialogRef = useDialogRef<GroupMemberListDrawerRecordsType>();

  const addMemberDialogRef = useDialogRef<AddMemberRecordsType>();

  const deleteMemberDialogRef = useDialogRef<DeleteMemberRecordsType>();

  const memberList = userList?.filter(
    (item) => ![2, 3].includes(item.group_member_info_member_role)
  );

  // 可拉人进群条件为 群类型不为直播群且当前群没有设置禁止加入
  const canInviteMember = [0, 1, 2].includes(groupType);

  /**
   * 对于私有群：只有创建者可删除群组成员。
   * 对于公开群和聊天室：只有管理员和群主可以踢人。
   * 对于直播大群：不能踢人
   * 用户身份类型 memberRoleMap
   * 群类型  groupTypeMap
   */
  const canDeleteMember =
    (groupType === 1 && userIdentity === 3) ||
    ([0, 2].includes(groupType) && [2, 3].includes(userIdentity));

  return (
    <>
      <div className="group-member">
        <div className="group-member--title">
          <span>群成员</span>
          {userList.length ? (
            <span
              className="group-member--title__right"
              onClick={() => dialogRef.current.open({ groupId })}
            >
              <span style={{ marginRight: "4px" }}>{memberCount}人</span>
              <a>查看</a>
            </span>
          ) : (
            <></>
          )}
        </div>
        <div className="group-member--avatar">
          {userList?.slice(0, 15)?.map((v, index) => (
            <Avatar
              key={`${v.group_member_info_face_url}-${index}`}
              url={v.group_member_info_face_url}
              nickName={v.group_member_info_nick_name}
              userID={v.group_member_info_identifier}
            />
          ))}
          {canInviteMember && (
            <span
              className="group-member--add"
              onClick={() => addMemberDialogRef.current.open({ groupId })}
            ></span>
          )}
          {canDeleteMember && memberList.length ? (
            <span
              className="group-member--delete"
              onClick={() =>
                deleteMemberDialogRef.current.open({
                  groupId,
                  userList: memberList,
                })
              }
            ></span>
          ) : (
            <></>
          )}
        </div>
      </div>

      <GroupMemberListDrawer
        popupContainer={popupContainer}
        dialogRef={dialogRef}
      />
      <DeleteGroupMemberDialog
        dialogRef={deleteMemberDialogRef}
        onSuccess={() => retry()}
      />
      <AddGroupMemberDialog
        dialogRef={addMemberDialogRef}
        onSuccess={() => retry()}
      />
    </>
  );
};
