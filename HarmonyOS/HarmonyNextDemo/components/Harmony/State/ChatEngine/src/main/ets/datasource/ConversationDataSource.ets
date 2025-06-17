import { ConversationInfo } from '../pages/ConversationListState';
import CommonDataSource from './CommonDataSource';

export default class ConversationDataSource extends CommonDataSource<ConversationInfo> {
  static readonly BADGE_MAX_UNREAD_COUNT = 99;
  isFinished = false;
  nextSeq = 0;

  constructor() {
    super();
    this.setComparator((o1, o2) => {
      if (!o1 || !o2) {
        return 0;
      }
      if (o1.isPinned && !o2.isPinned) {
        return -1;
      } else if (!o1.isPinned && o2.isPinned) {
        return 1;
      }

      if (!o1.orderKey || !o2.orderKey) {
        return 0;
      }
      return o2.orderKey - o1.orderKey;
    });
  }
}