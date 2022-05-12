/* eslint-disable @typescript-eslint/no-var-requires */
const TUIChat = require('./TUIChat.json');
const TUIConversation = require('./TUIConversation.json');
const TUIGroup = require('./TUIGroup.json');
const TUIProfile = require('./TUIProfile.json');
const TUIContact = require('./TUIContact.json');

const message = require('./message.json');
const component = require('./component.json');
const time = require('./time.json');

const Words = require('./words.json');
const Evaluate = require('./evaluate.json');

const messages = {
  zh_cn: {
    取消: '取消',
    发送: '发送',
    系统通知: '系统通知',
    TUIChat,
    TUIConversation,
    TUIGroup,
    TUIProfile,
    TUIContact,
    message,
    component,
    time,
    Evaluate,
    Words,
  },
};

export default messages;
