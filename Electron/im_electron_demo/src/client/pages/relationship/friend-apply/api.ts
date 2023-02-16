import timRenderInstance from "../../../utils/timRenderInstance";

interface FriendShipPendency {
  pendency_page_current_seq: number;
  pendency_page_pendency_info_array: {
    friend_add_pendency_info_add_source: string;
    friend_add_pendency_info_add_time: number;
    friend_add_pendency_info_add_wording: string;
    friend_add_pendency_info_idenitifer: string;
    friend_add_pendency_info_nick_name: string;
    friend_add_pendency_info_type: number;
  }[];
  pendency_page_start_time: number;
  pendency_page_unread_num: number;
}

const getUserInfoList = async (
  userIdList: Array<string>
): Promise<State.userProfile[]> => {
  const {
    data: { code, json_param },
  } = await timRenderInstance.TIMProfileGetUserProfileList({
    json_get_user_profile_list_param: {
      friendship_getprofilelist_param_identifier_array: userIdList,
    },
  });
  return JSON.parse(json_param);
};

export const LIMITE_SIZE = 100; 

export const getFriendShipPendencyList = async (params: {
  startSeq: number;
  startTime: number;
}): Promise<{
  applyList: Array<
    State.userProfile &
      FriendShipPendency["pendency_page_pendency_info_array"][number]
  >;
  pendency_page_current_seq: number;
  pendency_page_start_time: number;
  pendency_page_unread_num: number;
}> => {
  const { data } = await timRenderInstance.TIMFriendshipGetPendencyList({
    params: {
      friendship_get_pendency_list_param_type: 0,
      friendship_get_pendency_list_param_start_seq: params.startSeq,
      friendship_get_pendency_list_param_start_time: params.startTime,
      friendship_get_pendency_list_param_limited_size: LIMITE_SIZE,
    },
  });

  const { code, desc, json_params } = data;
  if (code === 0) {
    const result: FriendShipPendency = JSON.parse(json_params) || {};
    const { pendency_page_pendency_info_array: applys, ...others } = result;
    const userIds = applys.map((v) => v.friend_add_pendency_info_idenitifer);
    if (userIds.length) {
      const userInfos = await getUserInfoList(userIds || []);
      const applyList = userInfos.map((v) => {
        const apply = applys.find(
          (item) =>
            item.friend_add_pendency_info_idenitifer ===
            v.user_profile_identifier
        );
        return { ...apply, ...v };
      });
      // @ts-ignore
      return { applyList, ...others };
    }
  }
  return {} as any;
};

/**
 *
 * @param params
 * action: 0 同意 1 同意并添加 2 拒绝
 * @returns
 */
export const friendshipHandleFriendAddRequest = async (params: {
  userId: string;
  action: number;
}) => {
  const { data } = await timRenderInstance.TIMFriendshipHandleFriendAddRequest({
    params: {
      friend_respone_identifier: params.userId,
      friend_respone_action: params.action,
    },
  });
  const { code, desc } = data;
  if (code === 0) {
    return {};
  }
  throw new Error(desc);
};
