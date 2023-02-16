import { DialogRef, useDialog } from "../../../utils/react-use/useDialog";
import { Modal, Button } from "tea-component";
import React, { useState } from "react";
import { EditGroupBaseInfoForm, FormValue } from "./EditGroupBaseInfoForm";
import { modifyGroupInfo } from "../../../api";

export interface EditGroupBaseInfoRecordsType {
  groupId: string;
  groupName: string;
  groupFaceUrl: string;
}

export const EditGroupBaseInfoDialog = (props: {
  onSuccess?: () => void;
  dialogRef: DialogRef<EditGroupBaseInfoRecordsType>;
}): JSX.Element => {
  const { onSuccess, dialogRef } = props;

  const [visible, setShowState, defaultForm] =
    useDialog<EditGroupBaseInfoRecordsType>(dialogRef, {});
  const onClose = () => setShowState(false);

  const onOk = async (formValue: FormValue) => {
    const { groupName, groupFaceUrl } = formValue;
    const params: any = {};
    if(groupName !== defaultForm.groupName) {
      params.group_modify_info_param_group_name = groupName;
    }
    if(groupFaceUrl !== defaultForm.groupFaceUrl) {
      params. group_modify_info_param_face_url = groupFaceUrl;
    }
    await modifyGroupInfo({
      groupId: defaultForm.groupId,
      modifyParams: params,
    });
  };

  const success = () => {
    onClose();
    onSuccess?.();
  };

  return (
    <Modal className="dialog" disableEscape visible={visible} onClose={onClose}>
      <Modal.Body>
        <EditGroupBaseInfoForm
          initialValues={defaultForm}
          onSubmit={onOk}
          onSuccess={success}
        />
      </Modal.Body>
    </Modal>
  );
};
