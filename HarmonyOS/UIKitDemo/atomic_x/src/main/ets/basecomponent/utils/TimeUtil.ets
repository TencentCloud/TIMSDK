export default class TimeUtil {
  public static minuteDiffTimestamp = 60 * 1000;

  public static formatRelativeTime(timestamp: number): string {
    if (Number.isNaN(timestamp)) {
      return '刚刚';
    }
    const now = Date.now();
    const diff = now - timestamp;

    const minute = 60 * 1000;
    const hour = 60 * minute;
    const day = 24 * hour;

    if (diff < minute) {
      return '刚刚';
    } else if (diff < hour) {
      return `${Math.floor(diff / minute)}分钟前`;
    } else if (diff < day) {
      return `${Math.floor(diff / hour)}小时前`;
    } else {
      return `${Math.floor(diff / day)}天前`;
    }
  }
}
