import { emojiMap, emojiUrl } from './emojiMap';

/** 传入message.element（群系统消息SystemMessage，群提示消息GroupTip除外）
 * content = {
 *  type: 'TIMTextElem',
 *  content: {
 *    text: 'AAA[龇牙]AAA[龇牙]AAA[龇牙AAA]'
 *  }
 *}
 **/

// 群提示消息的含义 (opType)
const GROUP_TIP_TYPE = {
  MEMBER_JOIN: 1,
  MEMBER_QUIT: 2,
  MEMBER_KICKED_OUT: 3,
  MEMBER_SET_ADMIN: 4, // 被设置为管理员
  MEMBER_CANCELED_ADMIN: 5, // 被取消管理员
  GROUP_INFO_MODIFIED: 6, // 修改群资料，转让群组为该类型，msgBody.msgGroupNewInfo.ownerAccount表示新群主的ID
  MEMBER_INFO_MODIFIED: 7, // 修改群成员信息
};

// 解析小程序text, 表情信息也是[嘻嘻]文本
export function parseText(message) {
  const renderDom = [];
  let temp = message.payload.text;
  let left = -1;
  let right = -1;
  while (temp !== '') {
    left = temp.indexOf('[');
    right = temp.indexOf(']');
    switch (left) {
      case 0:
        if (right === -1) {
          renderDom.push({
            name: 'span',
            text: temp,
          });
          temp = '';
        } else {
          const _emoji = temp.slice(0, right + 1);
          if (emojiMap[_emoji]) {
            renderDom.push({
              name: 'img',
              src: emojiUrl + emojiMap[_emoji],
            });
            temp = temp.substring(right + 1);
          } else {
            renderDom.push({
              name: 'span',
              text: '[',
            });
            temp = temp.slice(1);
          }
        }
        break;
      case -1:
        renderDom.push({
          name: 'span',
          text: temp,
        });
        temp = '';
        break;
      default:
        renderDom.push({
          name: 'span',
          text: temp.slice(0, left),
        });
        temp = temp.substring(left);
        break;
    }
  }
  return renderDom;
}
// 解析群系统消息
export function parseGroupSystemNotice(message) {
  const { payload } = message;
  const groupName =    payload.groupProfile.name || payload.groupProfile.groupID;
  const { groupID } = payload.groupProfile;
  let text;
  switch (payload.operationType) {
    case 1:
      text = `${payload.operatorID} 申请加入群组：${groupName}（群ID:${groupID})`;
      break;
    case 2:
      text = `成功加入群组：${groupName} （群ID:${groupID})`;
      break;
    case 3:
      text = `申请加入群组：${groupName} （群ID:${groupID})被拒绝`;
      break;
    case 4:
      text = `被管理员${payload.operatorID}踢出群组：${groupName}（群ID:${groupID})`;
      break;
    case 5:
      text = `群：${groupName} （群ID:${groupID})已被${payload.operatorID}解散`;
      break;
    case 6:
      text = `我（用户ID:${payload.operatorID}）成功创建群聊:${groupName}（群ID:${groupID})`;
      break;
    case 7:
      text = `用户ID：${payload.operatorID}邀请你加群：${groupName}（群ID:${groupID})`;
      break;
    case 8:
      text = `你退出群组：${groupName}（群ID:${groupID})`;
      break;
    case 9:
      text = `你被${payload.operatorID}设置为群：${groupName}（群ID:${groupID})的管理员`;
      break;
    case 10:
      text = `你被${payload.operatorID}撤销群：${groupName} （群ID:${groupID})的管理员身份`;
      break;
    case 255:
      text = `自定义群系统通知: ${payload.userDefinedField}`;
      break;
  }
  return text;
}
// 解析群提示消息
export function parseGroupTip(message) {
  const { payload } = message;
  const userName = message.nick || payload.userIDList.join(',');
  let tip;
  let user;
  switch (payload.operationType) {
    case GROUP_TIP_TYPE.MEMBER_JOIN:
      tip = `${userName} 加入群聊`;
      break;
    case GROUP_TIP_TYPE.MEMBER_QUIT:
      tip = `群成员退群：${userName}`;
      break;
    case GROUP_TIP_TYPE.MEMBER_KICKED_OUT:
      tip = `群成员被踢：${userName}`;
      break;
    case GROUP_TIP_TYPE.MEMBER_SET_ADMIN:
      tip = `${payload.operatorID}将 ${userName}设置为管理员`;
      break;
    case GROUP_TIP_TYPE.MEMBER_CANCELED_ADMIN:
      tip = `${payload.operatorID}将 ${userName}取消作为管理员`;
      break;
    case GROUP_TIP_TYPE.GROUP_INFO_MODIFIED:
      tip = '群资料修改';
      break;
    case GROUP_TIP_TYPE.MEMBER_INFO_MODIFIED:
      for (const member of payload.memberList) {
        if (member.muteTime > 0) {
          tip = `群成员：${member.userID}被禁言${member.muteTime}秒`;
        } else {
          tip = `群成员：${member.userID}被取消禁言`;
        }
      }
      break;
    case 256:
      user = message.nick || message.from;
      if (payload.text === '无应答') {
        user = payload.userIDList.join(',');
      }
      tip = payload.text === '结束群聊' ? '结束群聊' : `"${user}" ${payload.text}`;
      break;
  }
  return [{
    name: 'groupTip',
    text: tip,
  }];
}

// 解析图片消息
export function parseImage(message) {
  const renderDom = [{
    name: 'image',
    // 这里默认渲染的是 1080P 的图片
    src: message.payload.imageInfoArray[0].url,
  }];
  return renderDom;
}
// 解析视频消息
export function parseVideo(message) {
  const renderDom = [{
    name: 'video',
    src: message.payload.videoUrl,
  }];
  return renderDom;
}
// 解析语音消息
export function parseAudio(message) {
  const renderDom = [{
    name: 'audio',
    src: message.payload.url,
    second: message.payload.second === 0 ? 1 : message.payload.second,
  }];
  return renderDom;
}

