import { Input } from "tea-component";
import React, { useEffect, useState } from "react";
import { modifyGroupMemberInfo } from "../../../api";
import { EditIcon } from "./EditIcon";
import "./group-name-card.scss";
import { ConfirmDialog, ConfirmDialogRecordsType } from "./ConfirmDialog";
import { useDialogRef } from "../../../utils/react-use/useDialog";

export const GroupNameCard = (props: {
  nameCard: string;
  userId: string;
  groupId: string;
  onRefresh: () => Promise<any>;
}): JSX.Element => {
  const { nameCard, groupId, userId, onRefresh } = props;

  const [input, setInput] = useState(nameCard);
  const [isEdit, setIsEdit] = useState(false);

  const dialogRef = useDialogRef<ConfirmDialogRecordsType>();

  const handleModify = async () => {
    await modifyGroupMemberInfo({
      groupId,
      userId,
      modifyGroupMemberParams: {
        group_modify_member_info_name_card: input,
      },
    });
  };

  useEffect(() => {
    setInput(nameCard);
  }, [nameCard]);

  return (
    <>
      <div className="group-name-card">
        <div className="group-name-card--title">
          <span className="group-name-card--title__text">我在本群的昵称</span>
          {!isEdit && <EditIcon onClick={() => setIsEdit(true)} />}
        </div>
        {isEdit ? (
          <Input
            className="group-name-card--input"
            size="full"
            placeholder="输入后昵称内容后按回车进行设置"
            value={input}
            onChange={(value) => {
              setInput(value);
            }}
            onBlur={() => {
              dialogRef.current.open({
                description: `是否将群昵称修改为`,
                modifyContent: input,
                onConfirm: handleModify,
              });
            }}
            onKeyDown={(e) => {
              if (e.which === 13) {
                dialogRef.current.open({
                  description: `是否将群昵称修改为`,
                  modifyContent: input,
                  onConfirm: handleModify,
                });
              }
            }}
          />
        ) : (
          <div>{input}</div>
        )}
      </div>
      <ConfirmDialog
        dialogRef={dialogRef}
        onSuccess={() => {
          onRefresh();
          setIsEdit(false);
        }}
      />
    </>
  );
};
