import { DialogRef, useDialog } from "../../../../utils/react-use/useDialog";
import { Modal } from "tea-component";
import React from "react";
import { CreateGroupForm, FormValue } from "./CreateGroupForm";
import { sendMsg, createGroup } from "../../../../api";

export interface CreateGroupRecordType {
  userId: string;
}

export const CreateGroupDialog = (props: {
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
    const res = await createGroup(formData);
    const currentGroupId = res.create_group_result_groupid;
    await sendMsg({
      convId: currentGroupId,
      convType: 2,
      messageElementArray: [
        {
          elem_type: 3,
          custom_elem_data: JSON.stringify({
            businessID: "group_create",
            content: "创建群组",
            opUser: defaultForm.userId,
            version: 4,
          }),
        },
      ],
      userId: defaultForm.userId,
    });
  };

  return (
    <Modal
      className="dialog"
      disableEscape
      visible={visible}
      onClose={onClose}
      caption="创建群聊"
    >
      <Modal.Body>
        <CreateGroupForm
          onSubmit={onSubmit}
          onSuccess={success}
          onClose={onClose}
        />
      </Modal.Body>
    </Modal>
  );
};
