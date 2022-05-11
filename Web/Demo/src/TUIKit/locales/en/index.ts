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
  en: {
    取消: 'cancel',
    发送: 'send',
    系统通知: 'System notification',
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
