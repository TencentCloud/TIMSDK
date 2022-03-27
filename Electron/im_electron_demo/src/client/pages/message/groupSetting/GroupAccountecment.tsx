import { Input } from "tea-component";
import React, { useEffect, useState } from "react";
import { modifyGroupInfo } from "../../../api";
import { EditIcon } from "./EditIcon";
import "./group-accountecment.scss";
import { ConfirmDialog, ConfirmDialogRecordsType } from "./ConfirmDialog";
import { useDialogRef } from "../../../utils/react-use/useDialog";

export const GroupAccountecment = (props: {
  accountecment: string;
  groupId: string;
  userIdentity: number;
  groupType: number;
  onRefresh: () => Promise<any>;
}): JSX.Element => {
  const { accountecment, groupId, userIdentity, groupType, onRefresh } = props;

  const [input, setInput] = useState(accountecment);
  const [isEdit, setIsEdit] = useState(false);

  const dialogRef = useDialogRef<ConfirmDialogRecordsType>();

  const handleModify = async () => {
    await modifyGroupInfo({
      groupId,
      modifyParams: {
        group_modify_info_param_notification: input,
      },
    });
  };

  useEffect(() => {
    setInput(accountecment);
  }, [accountecment]);

  /**
   * 当前不是修改状态，才出现修改按钮
   * 对于公开群、聊天室和直播大群，只有群主或者管理员可以修改群简介。
   * 对于私有群，任何人可修改群简介。
   * 用户身份类型 memberRoleMap
   * 群类型  groupTypeMap
   */
  const canEdit = !isEdit && (groupType === 1 || [2, 3].includes(userIdentity));

  return (
    <>
      <div className="group-accountecment">
        <div className="group-accountecment--title">
          <span className="group-accountecment--title__text">群公告</span>
          {canEdit && <EditIcon onClick={() => setIsEdit(true)} />}
        </div>
        {isEdit ? (
          <Input
            className="group-accountecment--input"
            size="full"
            placeholder="输入后群公告后按回车进行设置"
            value={input}
            onChange={(value) => {
              setInput(value);
            }}
            onBlur={() => {
              dialogRef.current.open({
                description: `是否将群公告修改为`,
                modifyContent: input,
                onConfirm: handleModify,
              });
            }}
            onKeyDown={(e) => {
              if (e.which === 13) {
                dialogRef.current.open({
                  description: `是否将群公告修改为`,
                  modifyContent: input,
                  onConfirm: handleModify,
                });
              }
            }}
          />
        ) : (
          <div className="group-accountecment--info">{input || ""}</div>
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
