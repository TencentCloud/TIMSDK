import { DialogRef, useDialog } from "../../../utils/react-use/useDialog";
import { message, Modal } from "tea-component";
import React from "react";
import { AddFriendForm, FormValue } from "./AddFriendForm";
import { addFriends } from "../../../api";

export interface CreateGroupRecordType {
  userId: string;
}

export const AddFriendDialog = (props: {
  onSuccess?: () => void;
  dialogRef: DialogRef<CreateGroupRecordType>;
}): JSX.Element => {
  const { onSuccess, dialogRef } = props;

  const [visible, setShowState, defaultForm] = useDialog<CreateGroupRecordType>(
    dialogRef,
    {}
  );

  const onClose = () => setShowState(false);

  const success = () => {
    onSuccess();
    onClose();
  };

  const onSubmit = async (formData: FormValue) => {
      try {
        const res = await addFriends(formData);
        message.success({
            content: "好友请求已发送"
        })
      } catch (e) {
        message.error({
            content: "好友请求发送失败"
        })
      }
  };

  return (
    <Modal
      className="dialog"
      disableEscape
      visible={visible}
      onClose={onClose}
      caption="添加好友"
    >
      <Modal.Body>
        <AddFriendForm
          onSubmit={onSubmit}
          onSuccess={success}
          onClose={onClose}
        />
      </Modal.Body>
    </Modal>
  );
};
