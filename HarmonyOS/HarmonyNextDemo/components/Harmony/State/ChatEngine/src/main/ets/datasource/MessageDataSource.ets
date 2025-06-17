import CommonDataSource from './CommonDataSource';
import { MessageInfo } from '../pages/MessageListState';
import ArrayList from '@ohos.util.ArrayList';

/**
 * 消息数据源
 * 扩展通用数据源，增加消息特有的功能
 */
export default class MessageDataSource extends CommonDataSource<MessageInfo> {
  isFinished = false;
  nextSeq = 0;
  scroller?: Scroller;

  /**
   * 添加数据
   * @param dataList 要添加的数据列表
   * @param replaceIfPresent 如果存在是否替换
   */
  addData(dataList: MessageInfo[] | ArrayList<MessageInfo>, replaceIfPresent?: boolean): void {
    super.addData(dataList, replaceIfPresent);
    if (this.isAtEnd()) {
      this.scrollToEnd();
    }
  }

  /**
   * 检查是否在列表底部
   * @returns 是否在底部
   */
  isAtEnd() {
    return this.scroller?.isAtEnd();
  }

  /**
   * 设置滚动控制器
   * @param scroller 滚动控制器
   */
  setScroller(scroller: Scroller) {
    this.scroller = scroller;
  }

  /**
   * 滚动到列表底部
   */
  scrollToEnd() {
    this.scroller?.scrollEdge(Edge.End);
  }

  /**
   * 滚动到列表顶部
   */
  scrollToStart() {
    this.scroller?.scrollEdge(Edge.Start);
  }

  /**
   * 滚动到指定消息
   * @param message 目标消息
   */
  scrollToMessage(message?: MessageInfo) {
    if (!message) {
      return;
    }
    let index = this.getIndex(message);
    this.scroller?.scrollToIndex(index, false);
  }
  
  /**
   * 获取消息列表，用于兼容直接访问 messageList 的代码
   * @returns 消息列表
   */
  get messageList(): MessageInfo[] {
    const result: MessageInfo[] = [];
    for (let i = 0; i < this.totalCount(); i++) {
      const message = this.getData(i);
      if (message) {
        result.push(message);
      }
    }
    return result;
  }
  
  /**
   * 获取数据源中的所有数据作为数组
   * @returns 数据数组
   */
  getDataArray(): MessageInfo[] {
    return this.messageList;
  }
}