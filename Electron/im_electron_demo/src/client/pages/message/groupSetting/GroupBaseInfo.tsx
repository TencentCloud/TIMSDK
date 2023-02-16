import React, { useState } from "react";
import { useDialogRef } from "../../../utils/react-use/useDialog";
import { Avatar } from "../../../components/avatar/avatar";
import {
  EditGroupBaseInfoDialog,
  EditGroupBaseInfoRecordsType,
} from "./EditGroupBaseInfoDialog";
import { EditIcon } from "./EditIcon";
import "./group-base-info.scss";

const GROUP_TYPE_MAP = {
  0: "陌生人社交群(Public)",
  1: "好友工作群(Work)",
  2: "临时会议群(Meeting)",
  3: "直播群(AVChatRoom)",
  4: "直播群(AVChatRoom)",
};

export const GroupBaseInfo = (props: {
  groupAvatar: string;
  groupName: string;
  groupId: string;
  groupType: number;
  userIdentity: number;
  onRefresh: () => Promise<any>;
}): JSX.Element => {
  const {
    groupAvatar,
    groupId,
    groupName,
    userIdentity,
    groupType,
    onRefresh,
  } = props;

  const editDialog = useDialogRef<EditGroupBaseInfoRecordsType>();

  const canEdit =groupType === 1 || [2, 3].includes(userIdentity);

  return (
    <>
      <div className="group-base-info">
        <Avatar url={groupAvatar} groupID={groupId} />
        <div className="group-base-info--text">
          <div>
            <span className="group-base-info--text__name">{groupName}</span>
            {canEdit && (
              <EditIcon
                onClick={() =>
                  editDialog.current.open({
                    groupId,
                    groupName,
                    groupFaceUrl: groupAvatar,
                  })
                }
              />
            )}
          </div>
          <span className="group-base-info--text__type">
            {GROUP_TYPE_MAP[groupType] || ""}
          </span>
        </div>
      </div>
      <EditGroupBaseInfoDialog
        dialogRef={editDialog}
        onSuccess={() => {
          onRefresh();
        }}
      />
    </>
  );
};
