import { Checkbox, message } from "tea-component";
import React from "react";
import { getConversionList, modifyGroupInfo } from "../../../api";

import "./group-all-mute.scss";
import {
  updateCurrentSelectedConversation,
  updateConversationList,
} from "../../../store/actions/conversation";
import { useDispatch, useSelector } from "react-redux";

export const GroupAllMute = (props: {
  muteFlag: boolean;
  groupId: string;
  userIdentity: number;
  groupType: number;
  onRefresh: () => Promise<any>;
}): JSX.Element => {
  const { muteFlag, groupId, userIdentity, onRefresh } = props;

  const dispatch = useDispatch();

  const { currentSelectedConversation } = useSelector(
    (state: State.RootState) => state.conversation
  );

  const updateConversation = async () => {
    const response = await getConversionList();
    dispatch(updateConversationList(response));
    if (response.length) {
      const currentConversationItem = response.find(
        (v) => v.conv_id === currentSelectedConversation.conv_id
      );
      if (currentConversationItem) {
        dispatch(updateCurrentSelectedConversation(currentConversationItem));
      }
    }
  };

  const handleChange = async (value: boolean) => {
    try {
      await modifyGroupInfo({
        groupId,
        modifyParams: { group_modify_info_param_is_shutup_all: value },
      });
      message.success({ content: value ? "全体禁言" : "取消全体禁言" });
      await updateConversation();
      await onRefresh();
    } catch (e) {
      console.log(e);
    }
  };

  // useEffect(() => {
  //   setValue(muteFlag);
  // }, [muteFlag]);

  /**
   * 只有群主或者管理员可以进行全员禁言。
   * 用户身份类型 memberRoleMap
   * 群类型  groupTypeMap
   */
  const canEdit = [2, 3].includes(userIdentity);

  return (
    <div className="group-all-mute">
      <Checkbox value={muteFlag} onChange={handleChange} disabled={!canEdit}>
        全员禁言
      </Checkbox>
    </div>
  );
};
