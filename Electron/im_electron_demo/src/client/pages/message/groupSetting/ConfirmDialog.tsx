import { DialogRef, useDialog } from "../../../utils/react-use/useDialog";
import { Button, Modal } from "tea-component";
import React, { useState } from "react";

export interface ConfirmDialogRecordsType {
  description: React.ReactNode;
  modifyContent: string;
  onConfirm: () => void;
}

export const ConfirmDialog = (props: {
  onSuccess?: () => void;
  dialogRef: DialogRef<ConfirmDialogRecordsType>;
}): JSX.Element => {
  const { onSuccess, dialogRef } = props;

  const [visible, setShowState, defaultForm] =
    useDialog<ConfirmDialogRecordsType>(dialogRef, {});
  const [loading, setLoading] = useState(false);
  const onClose = () => setShowState(false);

  const success = () => {
    onClose();
    onSuccess?.();
  };

  const onOk = async () => {
    setLoading(true);
    try {
      await defaultForm.onConfirm();
      success();
    } catch (e) {
      console.log(e);
    }
    setLoading(false);
  };

  return (
    <Modal className="dialog" disableEscape visible={visible} onClose={onClose}>
      <Modal.Body>
        <Modal.Message
          description={
            <>
              <span>{defaultForm.description}</span>
              <span style={{ fontWeight: "bold", color: "#000000" }}>
                {defaultForm.modifyContent}
              </span>
            </>
          }
        />
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={onClose} disabled={loading}>
          取消
        </Button>
        <Button type="primary" onClick={onOk} loading={loading}>
          确认
        </Button>
      </Modal.Footer>
    </Modal>
  );
};
