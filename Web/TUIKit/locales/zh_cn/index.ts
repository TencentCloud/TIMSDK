/* eslint-disable @typescript-eslint/no-var-requires */
const TUIChat = require('./TUIChat.json');
const TUIConversation = require('./TUIConversation.json');
const TUIGroup = require('./TUIGroup.json');
const TUIProfile = require('./TUIProfile.json');
const TUIContact = require('./TUIContact.json');
const TUISearch = require('./TUISearch.json');

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
    关闭: '关闭',
    确定: '确定',
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
    TUISearch,
  },
};

export default messages;
