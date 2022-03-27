import { DialogRef, useDialog } from "../../../utils/react-use/useDialog";
import { Modal } from "tea-component";
import React from "react";
import { AddGroupMemberForm, FormValue } from "./AddGroupMemberForm";
import { inviteMemberGroup } from "../../../api";

export interface AddMemberRecordsType {
  groupId: string;
}

export const AddGroupMemberDialog = (props: {
  onSuccess?: () => void;
  dialogRef: DialogRef<AddMemberRecordsType>;
}): JSX.Element => {
  const { onSuccess, dialogRef } = props;

  const [visible, setShowState, defaultForm] = useDialog<AddMemberRecordsType>(
    dialogRef,
    {}
  );
  const onClose = () => setShowState(false);

  const onOk = async (formValue: FormValue) => {
    const { UID } = formValue;
    await inviteMemberGroup({groupId: defaultForm.groupId, UID})
  };

  const success = () => {
    onClose();
    onSuccess?.();
  };

  return (
    <Modal className="dialog" disableEscape visible={visible} onClose={onClose}>
      <Modal.Body>
        <AddGroupMemberForm onSubmit={onOk} onSuccess={success} />
      </Modal.Body>
    </Modal>
  );
};
