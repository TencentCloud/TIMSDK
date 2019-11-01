export function translateGroupSystemNotice(message) {
  const groupName = message.payload.groupProfile.groupName || message.payload.groupProfile.groupID
  switch (message.payload.operationType) {
    case 1:
      return `${message.payload.operatorID} 申请加入群组：${groupName}`
    case 2:
      return `成功加入群组：${groupName}`
    case 3:
      return `申请加入群组：${groupName}被拒绝`
    case 4:
      return `被管理员${message.payload.operatorID}踢出群组：${groupName}`
    case 5:
      return `群：${groupName} 已被${message.payload.operatorID}解散`
    case 6:
      return `${message.payload.operatorID}创建群：${groupName}`
    case 7:
      return `${message.payload.operatorID}邀请你加群：${groupName}`
    case 8:
      return `你退出群组：${groupName}`
    case 9:
      return `你被${message.payload.operatorID}设置为群：${groupName}的管理员`
    case 10:
      return `你被${message.payload.operatorID}撤销群：${groupName}的管理员身份`
    case 255:
      return '自定义群系统通知: ' + message.payload.userDefinedField
  }
}

export const errorMap = {
  500: '服务器错误',
  602: '用户名或密码不合法',
  610: '用户名格式错误',
  612: '用户已存在',
  620: '用户不存在',
  621: '密码错误'
}