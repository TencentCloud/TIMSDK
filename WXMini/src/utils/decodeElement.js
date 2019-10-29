import { emojiMap, emojiUrl } from './emojiMap'
/** 传入message.element（群系统消息SystemMessage，群提示消息GroupTip除外）
 * content = {
 *  type: 'TIMTextElem',
 *  content: {
 *    text: 'AAA[龇牙]AAA[龇牙]AAA[龇牙AAA]'
 *  }
 *}
 **/
const GROUP_SYSTEM_NOTICE_TYPE = {
  JOIN_GROUP_REQUEST: 1, // 申请加群请求（只有管理员会收到）
  JOIN_GROUP_ACCEPT: 2, // 申请加群被同意（只有申请人能够收到）
  JOIN_GROUP_REFUSE: 3, // 申请加群被拒绝（只有申请人能够收到）
  KICKED_OUT: 4, // 被管理员踢出群(只有被踢者接收到)
  GROUP_DISMISSED: 5, // 群被解散(全员接收)
  GROUP_CREATED: 6, // 创建群(创建者接收, 不展示)
  INVITED_JOIN_GROUP_REQUEST: 7, // 邀请加群(被邀请者接收)。对于被邀请者，表示被邀请进群。
  QUIT: 8, // 主动退群(主动退出者接收, 不展示)
  SET_ADMIN: 9, // 设置管理员(被设置者接收)
  CANCELED_ADMIN: 10, // 取消管理员(被取消者接收)
  REVOKE: 11, // 群已被回收(全员接收, 不展示)
  INVITED_JOIN_GROUP_REQUEST_AGREE: 12, // 邀请加群(被邀请者需同意)
  READED: 15, // 群消息已读同步
  CUSTOM: 255 // 用户自定义通知(默认全员接收)
}

// 群提示消息的含义 (opType)
const GROUP_TIP_TYPE = {
  MEMBER_JOIN: 1,
  MEMBER_QUIT: 2,
  MEMBER_KICKED_OUT: 3,
  MEMBER_SET_ADMIN: 4, // 被设置为管理员
  MEMBER_CANCELED_ADMIN: 5, // 被取消管理员
  GROUP_INFO_MODIFIED: 6, // 修改群资料，转让群组为该类型，msgBody.msgGroupNewInfo.ownerAccount表示新群主的ID
  MEMBER_INFO_MODIFIED: 7 // 修改群成员信息
}

function parseText (message) {
  let renderDom = []
  let temp = message.payload.text
  let left = -1
  let right = -1
  while (temp !== '') {
    left = temp.indexOf('[')
    right = temp.indexOf(']')
    switch (left) {
      case 0:
        if (right === -1) {
          renderDom.push({
            name: 'span',
            text: temp
          })
          temp = ''
        } else {
          let _emoji = temp.slice(0, right + 1)
          if (emojiMap[_emoji]) {
            renderDom.push({
              name: 'img',
              src: emojiUrl + emojiMap[_emoji]
            })
            temp = temp.substring(right + 1)
          } else {
            renderDom.push({
              name: 'span',
              text: '['
            })
            temp = temp.slice(1)
          }
        }
        break
      case -1:
        renderDom.push({
          name: 'span',
          text: temp
        })
        temp = ''
        break
      default:
        renderDom.push({
          name: 'span',
          text: temp.slice(0, left)
        })
        temp = temp.substring(left)
        break
    }
  }
  return renderDom
}
function parseGroupSystemNotice (message) {
  const payload = message.payload
  const groupName =
    payload.groupProfile.groupName || payload.groupProfile.groupID
  let text
  switch (payload.operationType) {
    case GROUP_SYSTEM_NOTICE_TYPE.JOIN_GROUP_REQUEST:
      text = `${payload.operatorID} 申请加入群组：${groupName}`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.JOIN_GROUP_ACCEPT:
      text = `成功加入群组：${groupName}`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.JOIN_GROUP_REFUSE:
      text = `申请加入群组：${groupName}被拒绝`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.KICKED_OUT:
      text = `被管理员${payload.operatorID}踢出群组：${groupName}`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.GROUP_DISMISSED:
      text = `群：${groupName} 已被${payload.operatorID}解散`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.GROUP_CREATED:
      text = `${payload.operatorID}创建群：${groupName}`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.INVITED_JOIN_GROUP_REQUEST:
      text = `${payload.operatorID}邀请你加群：${groupName}`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.QUIT:
      text = `你退出群组：${groupName}`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.SET_ADMIN:
      text = `你被${payload.operatorID}设置为群：${groupName}的管理员`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.CANCELED_ADMIN:
      text = `你被${payload.operatorID}撤销群：${groupName}的管理员身份`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.REVOKE:
      text = `群：${groupName}被${payload.operatorID}回收`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.INVITED_JOIN_GROUP_REQUEST_AGREE:
      text = `${payload.operatorID}同意入群：${groupName}邀请`
      break
    case GROUP_SYSTEM_NOTICE_TYPE.CUSTOM:
      text = `自定义群系统通知：${payload.userDefinedField}`
  }
  return [{
    name: 'system',
    text: text
  }]
}
function parseGroupTip (message) {
  const payload = message.payload
  let tip
  switch (payload.operationType) {
    case GROUP_TIP_TYPE.MEMBER_JOIN:
      tip = `新成员加入：${payload.userIDList.join(',')}`
      break
    case GROUP_TIP_TYPE.MEMBER_QUIT:
      tip = `群成员退群：${payload.userIDList.join(',')}`
      break
    case GROUP_TIP_TYPE.MEMBER_KICKED_OUT:
      tip = `群成员被踢：${payload.userIDList.join(',')}`
      break
    case GROUP_TIP_TYPE.MEMBER_SET_ADMIN:
      tip = `${payload.operatorID}将${payload.userIDList.join(',')}设置为管理员`
      break
    case GROUP_TIP_TYPE.MEMBER_CANCELED_ADMIN:
      tip = `${payload.operatorID}将${payload.userIDList.join(',')}取消作为管理员`
      break
    case GROUP_TIP_TYPE.GROUP_INFO_MODIFIED:
      tip = '群资料修改'
      break
    case GROUP_TIP_TYPE.MEMBER_INFO_MODIFIED:
      tip = '群成员资料修改'
      break
  }
  return [{
    name: 'groupTip',
    text: tip
  }]
}
export function decodeElement (message) {
  // renderDom是最终渲染的
  switch (message.type) {
    case 'TIMTextElem':
      return parseText(message)
    case 'TIMGroupSystemNoticeElem':
      return parseGroupSystemNotice(message)
    case 'TIMGroupTipElem':
      return parseGroupTip(message)
    default:
      return []
  }
}
