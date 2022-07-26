import TUIMessage from '../components/message/index';
import Error from './error';

export function caculateTimeago(dateTimeStamp:number) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  const minute = 1000 * 60;      // 把分，时，天，周，半个月，一个月用毫秒表示
  const hour = minute * 60;
  const day = hour * 24;
  const week = day * 7;
  const now = new Date().getTime();   // 获取当前时间毫秒
  const diffValue = now - dateTimeStamp;// 时间差
  let result = '';

  if (diffValue < 0) {
    return;
  }
  const minC = diffValue / minute;  // 计算时间差的分，时，天，周，月
  const hourC = diffValue / hour;
  const dayC = diffValue / day;
  const weekC = diffValue / week;
  if (weekC >= 1 && weekC <= 4) {
    result = ` ${parseInt(`${weekC}`, 10)} ${t('time.周')}${t('time.前')}`;
  } else if (dayC >= 1 && dayC <= 6) {
    result = ` ${parseInt(`${dayC}`, 10)} ${t('time.天')}${t('time.前')}`;
  } else if (hourC >= 1 && hourC <= 23) {
    result = ` ${parseInt(`${hourC}`, 10)} ${t('time.小时')}${t('time.前')}`;
  } else if (minC >= 1 && minC <= 59) {
    result = ` ${parseInt(`${minC}`, 10)} ${t('time.分钟')}${t('time.前')}`;
  } else if (diffValue >= 0 && diffValue <= minute) {
    result = `${t('time.刚刚')}`;
  } else {
    const datetime = new Date();
    datetime.setTime(dateTimeStamp);
    const Nyear = datetime.getFullYear();
    const Nmonth = datetime.getMonth() + 1 < 10 ? `0${datetime.getMonth() + 1}` : datetime.getMonth() + 1;
    const Ndate = datetime.getDate() < 10 ? `0${datetime.getDate()}` : datetime.getDate();
    result = `${Nyear}-${Nmonth}-${Ndate}`;
  }
  return result;
}

// 解析处理系统消息
export function translateGroupSystemNotice(message:any) {
  const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
  const groupName = message.payload.groupProfile.name || message.payload.groupProfile.groupID;
  switch (message.payload.operationType) {
    case 1:
      return `${message.payload.operatorID} ${t('message.tip.申请加入群组')}：${groupName}`;
    case 2:
      return `${t('message.tip.成功加入群组')}：${groupName}`;
    case 3:
      return `${t('message.tip.申请加入群组')}：${groupName} ${t('message.tip.被拒绝')}`;
    case 4:
      return `${t('message.tip.你被管理员')}${message.payload.operatorID} ${t('message.tip.踢出群组')}：${groupName}`;
    case 5:
      return `${t('message.tip.群')}：${groupName} ${t('message.tip.被')} ${message.payload.operatorID} ${t('message.tip.解散')}`;
    case 6:
      return `${message.payload.operatorID} ${t('message.tip.创建群')}：${groupName}`;
    case 7:
      return `${message.payload.operatorID} ${t('message.tip.邀请你加群')}：${groupName}`;
    case 8:
      return `${t('message.tip.你退出群组')}：${groupName}`;
    case 9:
      return `${t('message.tip.你被')}${message.payload.operatorID} ${t('message.tip.设置为群')}：${groupName} ${t('message.tip.的管理员')}`;
    case 10:
      return `${t('message.tip.你被')}${message.payload.operatorID} ${t('message.tip.撤销群')}：${groupName} ${t('message.tip.的管理员身份')}`;
    case 12:
      return `${message.payload.operatorID} ${t('message.tip.邀请你加群')}：${groupName}`;
    case 13:
      return `${message.payload.operatorID} ${t('message.tip.同意加群')}：${groupName}`;
    case 14:
      return `${message.payload.operatorID} ${t('message.tip.拒接加群')}：${groupName}`;
    case 255:
      return `${t('message.tip.自定义群系统通知')}: ${message.payload.userDefinedField}`;
  }
}


// Different styles of handling H5 and web error prompts
export function handleErrorPrompts(error: any, type:any) {
  console.log(error);
  if (type.isH5) {
    TUIMessage({ message: Error[error.code] || error, isH5: true });
  } else {
    TUIMessage({ message: Error[error.code] || error, isH5: false });
  }
}
