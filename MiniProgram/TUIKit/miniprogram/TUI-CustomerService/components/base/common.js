export function caculateTimeago(dateTimeStamp) {
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
    result = ` ${parseInt(weekC, 10)}周前`;
  } else if (dayC >= 1 && dayC <= 6) {
    result = ` ${parseInt(dayC, 10)}天前`;
  } else if (hourC >= 1 && hourC <= 23) {
    result = ` ${parseInt(hourC, 10)}小时前`;
  } else if (minC >= 1 && minC <= 59) {
    result = ` ${parseInt(minC, 10)}分钟前`;
  } else if (diffValue >= 0 && diffValue <= minute) {
    result = '刚刚';
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
