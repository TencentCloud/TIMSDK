import { DialogRef, useDialog } from "../../../utils/react-use/useDialog";
import { Drawer, H3 } from "tea-component";
import React from "react";

import "../scss/group-tool-drawer.scss";
import { GroupAccountecmentSetting } from "../groupAccountecmentSetting/GroupAccountecmentSetting";

export interface GroupAccountecmentSettingRecordsType {
  conversationInfo: State.conversationItem;
}

export const GroupAccountecmentSettingDrawer = (props: {
  onSuccess?: () => void;
  onClose?: () => void;
  popupContainer?: HTMLElement;
  dialogRef: DialogRef<GroupAccountecmentSettingRecordsType>;
}): JSX.Element => {
  const { onClose, dialogRef, popupContainer } = props;

  const [visible, setShowState, defaultForm] =
    useDialog<GroupAccountecmentSettingRecordsType>(dialogRef, {});

  const close = () => {
    setShowState(false);
    onClose();
  };

  return (
    <Drawer
      visible={visible}
      title={
        <div className="tool-drawer--title">
          <H3>群公告</H3>
          {/* <span className="tool-drawer--title__sub">{`最近修改: `}</span> */}
        </div>
      }
      className="tool-drawer"
      popupContainer={popupContainer}
      onClose={close}
    >
      <GroupAccountecmentSetting
        close={close}
        conversationInfo={defaultForm.conversationInfo}
      />
    </Drawer>
  );
};
