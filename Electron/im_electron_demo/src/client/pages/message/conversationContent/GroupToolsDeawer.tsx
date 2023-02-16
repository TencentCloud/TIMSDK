import { Drawer, H3 } from "tea-component";
import React, { useEffect } from "react";

import "../scss/group-tool-drawer.scss";
import { GroupSetting } from "../groupSetting/GroupSetting";
import { GroupAccountecmentSetting } from "../groupAccountecmentSetting/GroupAccountecmentSetting";
import { useSelector } from "react-redux";

export interface GroupToolsgRecordsType {
  conversationInfo: State.conversationItem;
  toolId: string;
}

export const GroupToolsDrawer = (props: {
  onSuccess?: () => void;
  onClose?: () => void;
  popupContainer?: HTMLElement;
  visible: boolean;
  conversationInfo: State.conversationItem;
  toolId: string;
}): JSX.Element => {
  const { onClose, popupContainer, visible, conversationInfo, toolId } = props;

  const { currentSelectedConversation } = useSelector(
    (state: State.RootState) => state.conversation
  );

  const close = () => {
    onClose?.();
  };

  const getTitleAndSubTitle = (toolsId: string) => {
    let title = "";
    let subTitle = "";
    const memberNum =
      conversationInfo?.conv_profile?.group_detial_info_member_num || 0;
    switch (toolsId) {
      case "setting":
        title = "设置";
        subTitle = `群成员 | ${memberNum}`;
        break;
      case "announcement":
        title = "群公告";
        break;
    }

    return { title, subTitle };
  };

  const { title, subTitle } = getTitleAndSubTitle(toolId);

  useEffect(() => {
    if (visible) {
      close();
    }
  }, [currentSelectedConversation.conv_id]);

  return (
    <Drawer
      visible={visible}
      title={
        <div className="tool-drawer--title">
          <H3>{title}</H3>
          <span className="tool-drawer--title__sub">{subTitle}</span>
        </div>
      }
      outerClickClosable={false}
      className="tool-drawer"
      popupContainer={popupContainer}
      onClose={close}
    >
      {toolId === "setting" && (
        <GroupSetting close={close} conversationInfo={conversationInfo} />
      )}
      {toolId === "announcement" && (
        <GroupAccountecmentSetting
          close={close}
          conversationInfo={conversationInfo}
        />
      )}
    </Drawer>
  );
};
