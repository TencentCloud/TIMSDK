import TIM from 'tim-js-sdk/tim-js-friendship'

export function translateGroupSystemNotice(message) {
  const groupName = message.payload.groupProfile.name || message.payload.groupProfile.groupID
  switch (message.payload.operationType) {
    case 1:
      return `${message.payload.operatorID} 申请加入群组：${groupName}`
    case 2:
      return `成功加入群组：${groupName}`
    case 3:
      return `申请加入群组：${groupName}被拒绝`
    case 4:
      return `你被管理员${message.payload.operatorID}踢出群组：${groupName}`
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
    case 12:
      return `${message.payload.operatorID}邀请你加群：${groupName}`
    case 13:
      return `${message.payload.operatorID}同意加群：${groupName}`
    case 14:
      return `${message.payload.operatorID}拒接加群：${groupName}`
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
export function filterCallingMessage(currentMessageList) {
  currentMessageList.forEach((item) => {
    if (item.callType) {   // 对于自己伪造的消息不需要解析
      return
    }
    if (item.type === TIM.TYPES.MSG_MERGER && item.payload.downloadKey !== '') {
      let promise = window.tim.downloadMergerMessage(item)
      promise.then(function(imResponse) {
        // 下载成功后，SDK会更新 message.payload.messageList 等信息
        item = imResponse
      }).catch(function(imError) {
        // 下载失败
        console.warn('downloadMergerMessage error:', imError)
      })
    }
    if(item.type === TIM.TYPES.MSG_CUSTOM) {
      let payloadData = {}
      try {
        payloadData = JSON.parse(item.payload.data)
      }catch (e) {
        payloadData = {}
      }
      if(payloadData.businessID === 1) {
        if(item.conversationType === TIM.TYPES.CONV_GROUP) {
          if(payloadData.actionType === 5) {
            item.nick = payloadData.inviteeList ? payloadData.inviteeList.join(','):item.from
          }
          let _text = window.trtcCalling.extractCallingInfoFromMessage(item)
          let group_text = `${_text}`
          item.type = TIM.TYPES.MSG_GRP_TIP
          let customData = {
            operationType: 256,
            text: group_text,
            userIDList: []
          }
          item.payload = customData//JSON.stringify(customData)
        }
        if(item.conversationType === TIM.TYPES.CONV_C2C) {
          let c2c_text = window.trtcCalling.extractCallingInfoFromMessage(item)
          let customData = {
            text: c2c_text
          }
          item.payload = customData//JSON.stringify(customData)
        }
      }
    }

  })
}

