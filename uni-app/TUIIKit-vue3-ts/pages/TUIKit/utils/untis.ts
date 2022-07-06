import { formatTime } from './date.ts';
import { decodeText } from './decodeText';
import { bigEmojiList } from './emojiMap';
import TIM from 'tim-wx-sdk';
 // 处理头像
export function handleAvatar(item: any) {
  let avatar = '';
  if (item.type === TIM.TYPES.CONV_C2C) {
    avatar = item?.userProfile?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png';
  } else {
    avatar = item?.groupProfile?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/group_avatar.png';
  }
  return avatar;
};

// 处理昵称
export function handleName(item: any) {
  let name = '';
  switch (item.type) {
    case TIM.TYPES.CONV_C2C:
      name = item?.userProfile.nick || item?.userProfile?.userID || '';
      break;
    case TIM.TYPES.CONV_GROUP:
      name = item.groupProfile.name || item?.groupProfile?.groupID || '';
      break;
    case TIM.TYPES.CONV_SYSTEM:
      name = '系统通知';
      break;
  }
  return name;
};

// 处理系统提示消息展示
export function handleTipMessageShowContext(message:any) {
  const options:any = {
    message,
    text: '',
  };
  const userName = message.nick || message.payload.userIDList.join(',');
  switch (message.payload.operationType) {
    case TIM.TYPES.GRP_TIP_MBR_JOIN:
      options.text =  `群成员：${userName} 加入群组`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_QUIT:
      options.text =  `群成员：${userName} 退出群组`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_KICKED_OUT:
      options.text =  `群成员：${userName} 被 ${message.payload.operatorID} 踢出群组`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_SET_ADMIN:
      options.text =  `群成员：${userName} 成为管理员`;
      break;
    case TIM.TYPES.GRP_TIP_MBR_CANCELED_ADMIN:
      options.text =  `群成员：${userName} 被撤销管理员`;
      break;
    case TIM.TYPES.GRP_TIP_GRP_PROFILE_UPDATED:
      // options.text =  `${userName} 修改群组资料`;
      options.text =  handleTipGrpUpdated(message);
      break;
    case TIM.TYPES.GRP_TIP_MBR_PROFILE_UPDATED:
      for (const member of message.payload.memberList) {
        if (member.muteTime > 0) {
          // options.text =  `群成员：${member.userID}被禁言${member.muteTime}秒`;
          options.text = `群成员：${member.userID} 被禁言`;
        } else {
          options.text = `群成员：${member.userID} 被取消禁言`;
        }
      }
      break;
    default:
      options.text = `[群提示消息]`;
      break;
  }
  return options;
};

function handleTipGrpUpdated(message:any) {
  const { payload } = message;
  const { newGroupProfile } = payload;
  const { operatorID } = payload;
  let text = '';
  const name = Object.keys(newGroupProfile)[0];
  switch (name) {
    case 'ownerID':
      text = `${newGroupProfile[name]} 成为新的群主`;
      break;
    case 'groupName':
      text = `${operatorID} 修改群名为 ${newGroupProfile[name]}`;
      break;
    case 'notification':
      text = `${operatorID} 发布新公告`;
      break;
    default:
      break;
  }
  return text;
};

// 解析处理文本消息展示
export function handleTextMessageShowContext(item:any) {
  const options:any = {
    text: decodeText(item.payload),
  };
  return options;
};

// 解析处理表情消息展示
export function handleFaceMessageShowContext(item:any) {
  const face:any = {
    message: item,
    name: '',
    url: '',
  };
  const currentEmojiList = bigEmojiList.filter((emoItem:any) => emoItem.icon === item.payload.data);
	if(currentEmojiList.length > 0) {
		face.name = currentEmojiList[0].list[item.payload.index];
	}
	// 与native 互通兼容
	if (item.payload.data.indexOf('@2x') > 0) {
	  face.name = item.payload.data
	} else {
	  face.name = `${item.payload.data}@2x`
	}
  face.url = `https://web.sdk.qcloud.com/im/assets/face-elem/${face.name}.png`;
  return face;
};

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
};

// 解析处理图片消息展示
export function handleImageMessageShowContext(item:any) {
  return {
    progress: item?.status === 'unSend' && item.progress,
    info: item.payload.imageInfoArray,
    message: item,
  };
};

// 解析处理视频消息展示
export function handleVideoMessageShowContext(item:any) {
  return {
    progress: item?.status === 'unSend' && item?.progress,
    url: item?.payload?.videoUrl,
    snapshotUrl: item?.payload?.snapshotUrl,
    message: item,
  };
};

// 解析处理语音消息展示
export function handleAudioMessageShowContext(item:any) {
  return {
    progress: item?.status === 'unSend' && item.progress,
    url: item.payload.url,
    message: item,
    second: item.payload.second,
  };
};

// 解析处理文件消息展示
export function handleFileMessageShowContext(item:any) {
  let size = '';
  if (item.payload.fileSize >= 1024 * 1024) {
    size = `${(item.payload.fileSize / (1024 * 1024)).toFixed(2)} Mb`;
  } else if (item.payload.fileSize >= 1024) {
    size = `${(item.payload.fileSize / 1024).toFixed(2)} Kb`;
  } else {
    size = `${(item.payload.fileSize).toFixed(2)}B`;
  };
  return {
    progress: item?.status === 'unSend' && item.progress,
    url: item.payload.fileUrl,
    message: item,
    name: item.payload.fileName,
    size,
  };
};

// 解析处理合并消息展示
export function handleMergerMessageShowContext(item:any) {
  return { message: item, ...item.payload };
};

// 解析音视频通话消息
export function extractCallingInfoFromMessage(message:any) {
  let callingmessage:any = {};
  let objectData:any = {};
  try {
    callingmessage = JSON.parse(message.payload.data);
  } catch (error) {
    callingmessage = {};
  }
  if (callingmessage.businessID !== 1) {
    return '';
  }
  try {
    objectData = JSON.parse(callingmessage.data);
  } catch (error) {
    objectData = {};
  }
  switch (callingmessage.actionType) {
    case 1: {
      if (objectData.call_end >= 0 && !callingmessage.groupID) {
        return `通话时长 ：${formatTime(objectData.call_end)}`;
      }
      if (callingmessage.groupID) {
        return `结束群聊`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToAudio') {
        return `切换语音通话`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToVideo') {
        return `切换视频通话`;
      }
      return `发起通话`;
    }
    case 2:
      return `取消通话`;
    case 3:
      if (objectData.data && objectData.data.cmd === 'switchToAudio') {
        return `切换语音通话`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToVideo') {
        return `切换视频通话`;
      }
      return `已接听`;
    case 4:
      return `拒绝通话`;
    case 5:
      if (objectData.data && objectData.data.cmd === 'switchToAudio') {
        return `切换语音通话`;
      }
      if (objectData.data && objectData.data.cmd === 'switchToVideo') {
        return `切换视频通话`;
      }
      return `无应答`;
    default:
      return '';
  }
};

// 解析处理自定义消息展示
export function handleCustomMessageShowContext(item:any) {
  return {
    message: item,
    custom: extractCallingInfoFromMessage(item) || item?.payload?.extension || `[自定义消息]`,
  };
};

// 解析处理系统消息
export function translateGroupSystemNotice(message:any) {
  const groupName = message.payload.groupProfile?.name || message.payload.groupProfile?.groupID;
  switch (message.payload.operationType) {
    case 1:
      return `${message.payload.operatorID} 申请加入群组：${groupName}`;
    case 2:
      return `成功加入群组：${groupName}`;
    case 3:
      return `申请加入群组：${groupName} 被拒绝`;
    case 4:
      return `你被管理员 ${message.payload.operatorID} 踢出群组：${groupName}`;
    case 5:
      return `群：${groupName} 被 ${message.payload.operatorID} 解散`;
    case 6:
      return `${message.payload.operatorID} 创建群：${groupName}`;
    case 7:
      return `${message.payload.operatorID} 邀请你加群：${groupName}`;
    case 8:
      return `你退出群组：${groupName}`;
    case 9:
      return `你被${message.payload.operatorID} 设置为群：${groupName} 的管理员`;
    case 10:
      return `你被 ${message.payload.operatorID} 撤销群：${groupName} 的管理员身份`;
    case 12:
      return `${message.payload.operatorID} 邀请你加群：${groupName}`;
    case 13:
      return `${message.payload.operatorID} 同意加群 ：${groupName}`;
    case 14:
      return `${message.payload.operatorID} 拒接加群 ：${groupName}`;
    case 255:
      return `自定义群系统通知: ${message.payload.userDefinedField}`;
  }
};
