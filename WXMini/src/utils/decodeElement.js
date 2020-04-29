import { emojiMap, emojiUrl } from './emojiMap'
import { formatDuration, isJSON } from './index'
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
  MEMBER_INFO_MODIFIED: 7 // 修改群成员信息
}

// 解析小程序text, 表情信息也是[嘻嘻]文本
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
// 解析群系统消息
function parseGroupSystemNotice (message) {
  const payload = message.payload
  const groupName =
    payload.groupProfile.name || payload.groupProfile.groupID
  let text
  switch (payload.operationType) {
    case 1:
      text = `${payload.operatorID} 申请加入群组：${groupName}`
      break
    case 2:
      text = `成功加入群组：${groupName}`
      break
    case 3:
      text = `申请加入群组：${groupName}被拒绝`
      break
    case 4:
      text = `被管理员${payload.operatorID}踢出群组：${groupName}`
      break
    case 5:
      text = `群：${groupName} 已被${payload.operatorID}解散`
      break
    case 6:
      text = `${payload.operatorID}创建群：${groupName}`
      break
    case 7:
      text = `${payload.operatorID}邀请你加群：${groupName}`
      break
    case 8:
      text = `你退出群组：${groupName}`
      break
    case 9:
      text = `你被${payload.operatorID}设置为群：${groupName}的管理员`
      break
    case 10:
      text = `你被${payload.operatorID}撤销群：${groupName}的管理员身份`
      break
    case 255:
      text = '自定义群系统通知: ' + payload.userDefinedField
      break
  }
  return [{
    name: 'system',
    text: text
  }]
}
// 解析群提示消息
function parseGroupTip (message) {
  const payload = message.payload
  const userName = message.nick || payload.userIDList.join(',')
  let tip
  switch (payload.operationType) {
    case GROUP_TIP_TYPE.MEMBER_JOIN:
      tip = `新成员加入：${userName}`
      break
    case GROUP_TIP_TYPE.MEMBER_QUIT:
      tip = `群成员退群：${userName}`
      break
    case GROUP_TIP_TYPE.MEMBER_KICKED_OUT:
      tip = `群成员被踢：${userName}`
      break
    case GROUP_TIP_TYPE.MEMBER_SET_ADMIN:
      tip = `${payload.operatorID}将 ${userName}设置为管理员`
      break
    case GROUP_TIP_TYPE.MEMBER_CANCELED_ADMIN:
      tip = `${payload.operatorID}将 ${userName}取消作为管理员`
      break
    case GROUP_TIP_TYPE.GROUP_INFO_MODIFIED:
      tip = '群资料修改'
      break
    case GROUP_TIP_TYPE.MEMBER_INFO_MODIFIED:
      for (let member of payload.memberList) {
        if (member.muteTime > 0) {
          tip = `群成员：${member.userID}被禁言${member.muteTime}秒`
        } else {
          tip = `群成员：${member.userID}被取消禁言`
        }
      }
      break
  }
  return [{
    name: 'groupTip',
    text: tip
  }]
}
// 解析自定义消息
function parseCustom (message) {
  let data = message.payload.data
  if (isJSON(data)) {
    data = JSON.parse(data)
    if (data.hasOwnProperty('version') && data.version === 3) {
      let tip
      const time = formatDuration(data.duration)
      switch (data.action) {
        case -2:
          tip = '异常挂断'
          break
        case 0:
          tip = '请求通话'
          break
        case 1:
          tip = '取消通话'
          break
        case 2:
          tip = '拒绝通话'
          break
        case 3:
          tip = '无应答'
          break
        case 4:
          tip = '开始通话'
          break
        case 5:
          if (data.duration === 0) {
            tip = '结束通话'
          } else {
            tip = `结束通话，通话时长${time}`
          }
          break
        case 6:
          tip = '正在通话中'
          break
      }
      return [{
        name: 'videoCall',
        text: tip
      }]
    }
  }
  return [{
    name: 'custom',
    text: data
  }]
}
// 解析message element
export function decodeElement (message) {
  // renderDom是最终渲染的
  switch (message.type) {
    case 'TIMTextElem':
      return parseText(message)
    case 'TIMGroupSystemNoticeElem':
      return parseGroupSystemNotice(message)
    case 'TIMGroupTipElem':
      return parseGroupTip(message)
    case 'TIMCustomElem':
      return parseCustom(message)
    default:
      return []
  }
}
