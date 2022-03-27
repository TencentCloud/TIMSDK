import { DialogRef, useDialog } from "../../../utils/react-use/useDialog";
import { Drawer, H3 } from "tea-component";
import React from "react";

import "../scss/group-tool-drawer.scss";
import { GroupSetting } from "../groupSetting/GroupSetting";

export interface GroupSettingRecordsType {
  conversationInfo: State.conversationItem;
}

export const GroupSettingDrawer = (props: {
  onSuccess?: () => void;
  onClose?: () => void;
  popupContainer?: HTMLElement;
  dialogRef: DialogRef<GroupSettingRecordsType>;
  visible: boolean;
}): JSX.Element => {
  const { onClose, dialogRef, popupContainer } = props;

  const [visible, setShowState, defaultForm] =
    useDialog<GroupSettingRecordsType>(dialogRef, {});

  const memberNum =
    defaultForm.conversationInfo?.conv_profile?.group_detial_info_member_num ||
    0;

  const close = () => {
    setShowState(false);
    onClose?.();
  };

  return (
    <Drawer
      visible={visible}
      title={
        <div className="tool-drawer--title">
          <H3>设置</H3>
          <span className="tool-drawer--title__sub">{`群成员 | ${memberNum}`}</span>
        </div>
      }
      className="tool-drawer"
      popupContainer={popupContainer}
      onClose={close}
    >
      <GroupSetting
        close={close}
        conversationInfo={defaultForm.conversationInfo}
      />
    </Drawer>
  );
};
