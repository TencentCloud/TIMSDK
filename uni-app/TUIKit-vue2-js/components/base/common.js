export function caculateTimeago(dateTimeStamp) {
  const minute = 1000 * 60; // 把分，时，天，周，半个月，一个月用毫秒表示

  const hour = minute * 60;
  const day = hour * 24;
  const week = day * 7;
  const now = new Date().getTime(); // 获取当前时间毫秒

  const diffValue = now - dateTimeStamp; // 时间差

  let result = '';

  if (diffValue < 0) {
    return;
  }

  const minC = diffValue / minute; // 计算时间差的分，时，天，周，月

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
export function formateTime(secondTime) {
  const time = secondTime;
  let newTime;
  let hour;
  let minite;
  let seconds;
  if (time >= 3600) {
    hour = parseInt(time / 3600) < 10 ? `0${parseInt(time / 3600)}` : parseInt(time / 3600);
    minite = parseInt(time % 60 / 60) < 10 ? `0${parseInt(time % 60 / 60)}` : parseInt(time % 60 / 60);
    seconds = time % 3600 < 10 ? `0${time % 3600}` : time % 3600;
    if (seconds > 60) {
      minite = parseInt(seconds / 60) < 10 ? `0${parseInt(seconds / 60)}` : parseInt(seconds / 60);
      seconds = seconds % 60 < 10 ? `0${seconds % 60}` : seconds % 60;
    }
    newTime = `${hour}:${minite}:${seconds}`;
  } else if (time >= 60 && time < 3600) {
    minite = parseInt(time / 60) < 10 ? `0${parseInt(time / 60)}` : parseInt(time / 60);
    seconds = time % 60 < 10 ? `0${time % 60}` : time % 60;
    newTime = `00:${minite}:${seconds}`;
  } else if (time < 60) {
    seconds = time < 10 ? `0${time}` : time;
    newTime = `00:00:${seconds}`;
  }
  return newTime;
}
