const constant = {
    FEAT_NATIVE_CODE: {
      NATIVE_VERSION: 1,
      ISTYPING_STATUS: 1,
      NOTTYPING_STATUS: 1,
      ISTYPING_ACTION: 14,
      NOTTYPING_ACTION: 0,
      FEAT_TYPING: 1
    },
    typeInputStatusIng: 'EIMAMSG_InputStatus_Ing',
    typeInputStatusEnd: 'EIMAMSG_InputStatus_End',
    messageType_text: {
      typeTIMCustomElem: 'TIMCustomElem',
    },
    businessID_text: {
      typeUserTyping: 'user_typing_status',
      typeEvaluation: 'evaluation',
      typeOrder: 'order',
      typeLink: 'text_link',
      typeCreate: 'group_create',
      typeConsultion: 'consultion',   
    },
    conversationType_text: {
      typeC2C: 'C2C',
      typeGroup: 'GROUP',
    },
    STRING_TEXT: {
      TYPETYPING: '对方正在输入...',
      TYPETEXT: '对本次服务的评价',
    },
    MESSAGE_ERROR_CODE: {
      DIRTY_WORDS: 80001,
      UPLOAD_FAIL: 6008,
      REQUESTOR_TIME: 2081,
      DISCONNECT_NETWORK: 2800,
      DIRTY_MEDIA: 80004,
    },
    TOASTTITLE_TEXT: {
      TITLEDIRTYWORDS: '您发送的消息包含违禁词汇!',
      TITLEUPLOADFAIL: '文件上传失败!',
      TITLECONNECTERROR: '网络已断开',
      TITLEDIRTYMEDIA: '您发送的消息包含违禁内容!',
      TITLERESENDSUCCESS: '重发成功',
    },
  };


  export default constant