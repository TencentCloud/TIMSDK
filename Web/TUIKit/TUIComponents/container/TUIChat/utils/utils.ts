import { formatTime } from '../../../utils/date';
import { decodeText } from './decodeText';
import TIM from 'tim-js-sdk';

// 处理头像
export function handleAvatar(item: any) {
  let avatar = '';
  switch (item.type) {
    case TIM.TYPES.CONV_C2C:
      avatar = isUrl(item?.userProfile?.avatar) ? item?.userProfile?.avatar : 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png';
      break;
    case TIM.TYPES.CONV_GROUP:
      avatar = isUrl(item?.groupProfile?.avatar) ? item?.groupProfile?.avatar : 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/demo/TUIkit/web/img/constomer.svg';
      break;
    case TIM.TYPES.CONV_SYSTEM:
      avatar = isUrl(item?.groupProfile?.avatar) ? item?.groupProfile?.avatar : 'https://web.sdk.qcloud.com/component/TUIKit/assets/group_avatar.png';
      break;
  }
  return avatar;
}

// 处理昵称
export function handleName(item: any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  let name = '';
  switch (item.type) {
    case TIM.TYPES.CONV_C2C:
      name = item?.userProfile.nick || item?.userProfile?.userID || '';
      break;
    case TIM.TYPES.CONV_GROUP:
      name = item.groupProfile.name || item?.groupProfile?.groupID || '';
      break;
    case TIM.TYPES.CONV_SYSTEM:
      name = t('系统通知');
      break;
  }
  return name;
}
// Handle whether there is someone@
export function handleAt(item: any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  const List:any = [
    `[${t('TUIConversation.有人@我')}]`,
    `[${t('TUIConversation.@所有人')}]`,
    `[${t('TUIConversation.@所有人')}][${t('TUIConversation.有人@我')}]`,
  ];
  let showAtType = '';
  for (let index = 0 ; index < item.groupAtInfoList.length; index++) {
    if (item.groupAtInfoList[index].atTypeArray[0] && item.unreadCount > 0) {
      showAtType = List[item.groupAtInfoList[index].atTypeArray[0] - 1];
    }
  }
  return showAtType;
}
// Internal display of processing message box
export function handleShowLastMessage(item:any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  const { lastMessage } = item;
  const conversation = item;
  let showNick = '';
  let lastMessagePayload = '';
  // Judge the number of unread messages and display them only when the message is enabled without interruption.
  const showUnreadCount = conversation.unreadCount > 0 && conversation.messageRemindType === TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE ? t(`[${conversation.unreadCount > 99 ? '99+' : conversation.unreadCount}条]`) : '';
  // Determine the lastmessage sender of the group. Namecard / Nick / userid is displayed by priority
  if (conversation.type === TIM.TYPES.CONV_GROUP) {
    if (lastMessage.fromAccount === conversation.groupProfile.selfInfo.userID) {
      showNick = t('TUIConversation.我');
    } else {
      showNick = lastMessage.nameCard || lastMessage.nick || lastMessage.fromAccount;
    }
  }
  // Display content of lastmessage message body
  if (lastMessage.type === TIM.TYPES.MSG_TEXT) {
    lastMessagePayload = lastMessage.payload.text;
  } else {
    lastMessagePayload = lastMessage.messageForShow;
  }

  if (lastMessage.isRevoked) {
    lastMessagePayload = t('TUIChat.撤回了一条消息');
  }

  if (conversation.type === TIM.TYPES.CONV_GROUP && lastMessage.type === TIM.TYPES.MSG_GRP_TIP) {
    return lastMessagePayload;
  }
  // Specific display content of message box
  return `${showUnreadCount}${showNick ? `${showNick}:` : ''}${lastMessagePayload}`;
}
// 处理系统提示消息展示
export function handleTipMessageShowContext(message:any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  const options:any = {
    message,
    text: '',
  };
  let userName =  message.nick || message?.payload?.userIDList.join(',');
  if (message?.payload?.memberList?.length > 0) {
    userName = '';
    message?.payload?.memberList?.map((user:any) => {
      userName += `${user?.nick || user?.userID},`;
    });
    userName = userName.slice(0, -1);
  }
  switch (message.payload.operationType) {
    case TIM.TYPES.GRP_TIP_MBR_JOIN:
      options.text =  `${userName} ${t('message.tip.加入群组')}`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_QUIT:
      options.text =  `${t('message.tip.群成员')}：${userName} ${t('message.tip.退出群组')}`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_KICKED_OUT:
      options.text =  `${t('message.tip.群成员')}：${userName} ${t('message.tip.被')}${message.payload.operatorID}${t('message.tip.踢出群组')}`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_SET_ADMIN:
      options.text =  `${t('message.tip.群成员')}：${userName} ${t('message.tip.成为管理员')}`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_CANCELED_ADMIN:
      options.text =  `${t('message.tip.群成员')}：${userName} ${t('message.tip.被撤销管理员')}`;
      break;
    case TIM.TYPES.GRP_TIP_GRP_PROFILE_UPDATED:
      // options.text =  `${userName} 修改群组资料`;
      options.text =  handleTipGrpUpdated(message);
      break;
    case TIM.TYPES.GRP_TIP_MBR_PROFILE_UPDATED:
      for (const member of message.payload.memberList) {
        if (member.muteTime > 0) {
          options.text = `${t('message.tip.群成员')}：${member.userID}${t('message.tip.被禁言')}`;
        } else {
          options.text = `${t('message.tip.群成员')}：${member.userID}${t('message.tip.被取消禁言')}`;
        }
      }
      break;
    default:
      options.text = `[${t('message.tip.群提示消息')}]`;
      break;
  }
  return options;
}

function handleTipGrpUpdated(message:any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  const { payload } = message;
  const { newGroupProfile } = payload;
  const { operatorID } = payload;
  let text = '';
  const name = Object.keys(newGroupProfile)[0];
  switch (name) {
    case 'muteAllMembers':
      if (newGroupProfile[name]) {
        text = `${t('message.tip.管理员')} ${operatorID} ${t('message.tip.开启全员禁言')}`;
      } else {
        text = `${t('message.tip.管理员')} ${operatorID} ${t('message.tip.取消全员禁言')}`;
      }
      break;
    case 'ownerID':
      text = `${newGroupProfile[name]} ${t('message.tip.成为新的群主')}`;
      break;
    case 'groupName':
      text = `${operatorID} ${t('message.tip.修改群名为')} ${newGroupProfile[name]}`;
      break;
    case 'notification':
      text = `${operatorID} ${t('message.tip.发布新公告')}`;
      break;
    default:
      break;
  }
  return text;
}

// 解析处理文本消息展示
export function handleTextMessageShowContext(item:any) {
  const options:any = {
    text: decodeText(item.payload),
  };
  return options;
}

// 解析处理位置消息展示
export function handleFaceMessageShowContext(item:any) {
  const face:any = {
    message: item,
    name: '',
    url: '',
  };
  face.name = item.payload.data;
  if (item.payload.data.indexOf('@2x') < 0) {
    face.name = `${face.name}@2x`;
  }
  face.url = `https://web.sdk.qcloud.com/im/assets/face-elem/${face.name}.png`;
  return face;
}

// 解析处理位置消息展示
export function handleLocationMessageShowContext(item:any) {
  const location:any = {
    lon: '',
    lat: '',
    href: '',
    url: '',
    description: '',
    message: item,
  };
  location.lon = item.payload.longitude.toFixed(6);
  location.lat = item.payload.latitude.toFixed(6);
  location.href = 'https://map.qq.com/?type=marker&isopeninfowin=1&markertype=1&'
        + `pointx=${location.lon}&pointy=${location.lat}&name=${item.payload.description}`;
  location.url = 'https://apis.map.qq.com/ws/staticmap/v2/?'
        + `center=${location.lat},${location.lon}&zoom=10&size=300*150&maptype=roadmap&`
        + `markers=size:large|color:0xFFCCFF|label:k|${location.lat},${location.lon}&`
        + 'key=UBNBZ-PTP3P-TE7DB-LHRTI-Y4YLE-VWBBD';
  location.description = item.payload.description;
  return location;
}

// 解析处理图片消息展示
export function handleImageMessageShowContext(item:any) {
  return {
    progress: item?.status === 'unSend' && item.progress,
    url: item.payload.imageInfoArray[1].url,
    message: item,
  };
}

// 解析处理视频消息展示
export function handleVideoMessageShowContext(item:any) {
  return {
    progress: item?.status === 'unSend' && item?.progress,
    url: item?.payload?.videoUrl,
    snapshotUrl: item?.payload?.snapshotUrl,
    message: item,
  };
}

// 解析处理语音消息展示
export function handleAudioMessageShowContext(item:any) {
  return {
    progress: item?.status === 'unSend' && item.progress,
    url: item.payload.url,
    message: item,
    second: item.payload.second,
  };
}

// 解析处理文件消息展示
export function handleFileMessageShowContext(item:any) {
  let size = '';
  if (item.payload.fileSize >= 1024 * 1024) {
    size = `${(item.payload.fileSize / (1024 * 1024)).toFixed(2)} Mb`;
  } else if (item.payload.fileSize >= 1024) {
    size = `${(item.payload.fileSize / 1024).toFixed(2)} Kb`;
  } else {
    size = `${(item.payload.fileSize).toFixed(2)}B`;
  }
  return {
    progress: item?.status === 'unSend' && item.progress,
    url: item.payload.fileUrl,
    message: item,
    name: item.payload.fileName,
    size,
  };
}

// 解析处理合并消息展示
export function handleMergerMessageShowContext(item:any) {
  return { message: item, ...item.payload };
}

// 解析音视频通话消息
export function extractCallingInfoFromMessage(message:any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  let callingmessage:any = {};
  let objectData:any = {};
  try {
    callingmessage = JSONToString(message.payload.data);
  } catch (error) {
    callingmessage = {};
  }
  if (callingmessage.businessID !== 1) {
    return '';
  }
  try {
    objectData = JSONToString(callingmessage.data);
  } catch (error) {
    objectData = {};
  }
  switch (callingmessage.actionType) {
    case 1: {
      if (objectData.call_end >= 0 && !callingmessage.groupID) {
        return `${t('message.custom.通话时长')}：${formatTime(objectData.call_end)}`;
      }
      if (callingmessage.groupID) {
        return `${t('message.custom.结束群聊')}`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToAudio') {
        return `${t('message.custom.切换语音通话')}`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToVideo') {
        return `${t('message.custom.切换视频通话')}`;
      }
      return `${t('message.custom.发起通话')}`;
    }
    case 2:
      return `${t('message.custom.取消通话')}`;
    case 3:
      if (objectData.data && objectData.data.cmd === 'switchToAudio') {
        return `${t('message.custom.切换语音通话')}`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToVideo') {
        return `${t('message.custom.切换视频通话')}`;
      }
      return `${t('message.custom.已接听')}`;
    case 4:
      return `${t('message.custom.拒绝通话')}`;
    case 5:
      if (objectData.data && objectData.data.cmd === 'switchToAudio') {
        return `${t('message.custom.切换语音通话')}`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToVideo') {
        return `${t('message.custom.切换视频通话')}`;
      }
      return `${t('message.custom.无应答')}`;
    default:
      return '';
  }
}

// 解析处理自定义消息展示
export function handleCustomMessageShowContext(item:any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  return {
    message: item,
    custom: extractCallingInfoFromMessage(item) || item?.payload?.extension || `[${t('message.custom.自定义消息')}]`,
  };
}

// 解析处理系统消息
export function translateGroupSystemNotice(message:any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  const groupName = message.payload.groupProfile.name || message.payload.groupProfile.groupID;
  switch (message.payload.operationType) {
    case 1:
      return `${message.payload.operatorID} ${t('message.tip.申请加入群组')}：${groupName}`;
    case 2:
      return `${t('message.tip.成功加入群组')}：${groupName}`;
    case 3:
      return `${t('message.tip.申请加入群组')}：${groupName} ${t('message.tip.被拒绝')}`;
    case 4:
      return `${t('message.tip.你被管理员')}${message.payload.operatorID} ${t('message.tip.踢出群组')}：${groupName}`;
    case 5:
      return `${t('message.tip.群')}：${groupName} ${t('message.tip.被')} ${message.payload.operatorID} ${t('message.tip.解散')}`;
    case 6:
      return `${message.payload.operatorID} ${t('message.tip.创建群')}：${groupName}`;
    case 7:
      return `${message.payload.operatorID} ${t('message.tip.邀请你加群')}：${groupName}`;
    case 8:
      return `${t('message.tip.你退出群组')}：${groupName}`;
    case 9:
      return `${t('message.tip.你被')}${message.payload.operatorID} ${t('message.tip.设置为群')}：${groupName} ${t('message.tip.的管理员')}`;
    case 10:
      return `${t('message.tip.你被')}${message.payload.operatorID} ${t('message.tip.撤销群')}：${groupName} ${t('message.tip.的管理员身份')}`;
    case 12:
      return `${message.payload.operatorID} ${t('message.tip.邀请你加群')}：${groupName}`;
    case 13:
      return `${message.payload.operatorID} ${t('message.tip.同意加群')}：${groupName}`;
    case 14:
      return `${message.payload.operatorID} ${t('message.tip.拒接加群')}：${groupName}`;
    case 255:
      return `${t('message.tip.自定义群系统通知')}: ${message.payload.userDefinedField}`;
  }
}

// 图片加载完成
export function getImgLoad(container:any, className:string, callback:any) {
  const images = container?.querySelectorAll(`.${className}`) || [];
  const promiseList = Array.prototype.slice.call(images).map((node:any) => new Promise((resolve:any, reject:any) => {
    const loadImg = new Image();
    loadImg.src = node.src;
    loadImg.onload = () => {
      resolve(node);
    };
  }));

  Promise.all(promiseList).then(() => {
    callback && callback();
  })
    .catch((e) => {
      console.error('网络异常', e);
    });
}

// 判断是否为地址
export function isUrl(url:string) {
  return /^(https?:\/\/(([a-zA-Z0-9]+-?)+[a-zA-Z0-9]+\.)+[a-zA-Z]+)(:\d+)?(\/.*)?(\?.*)?(#.*)?$/.test(url);
}

// 处理自定义消息固定字段
export function handleOptions(businessID: string, version: number, other: any) {
  return {
    businessID,
    version,
    ...other,
  };
}

// 判断是否为JSON 字符串
export function isJSON(str:string) {
  // eslint-disable-next-line no-useless-escape
  if (/^[\],:{}\s]*$/.test(str.replace(/\\["\\\/bfnrtu]/g, '@').
    // eslint-disable-next-line no-useless-escape
    replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
    replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {
    return true;
  }
  return false;
}

// 判断是否为JSON 字符串
export function JSONToString(str:string) {
  if (!isJSON(str)) {
    return str;
  }
  return JSON.parse(str);
}
