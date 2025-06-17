/**
 * 观察者接口
 * 相当于Kotlin中的 fun interface Observer { fun onNotification(data: Any) }
 */
export interface Observer {
  onNotification(data: Map<string, Object>): void;
}

/**
 * 观察者包装器接口，用于包装回调函数
 */
class ObserverWrapper implements Observer {
  private callback: (data: Object) => void;

  constructor(callback: (data: Object) => void) {
    this.callback = callback;
  }

  onNotification(data: Map<string, Object>): void {
    this.callback(data);
  }
}

/**
 * 通知中心
 * 直接基于原始Kotlin实现，不依赖鸿蒙的emitter
 * 使用Map数据结构存储通知名称和观察者列表
 */
export class NotificationCenter {
  private static instance: NotificationCenter;
  // 使用Map存储通知名称和对应的观察者列表
  // 相当于Kotlin中的 private val observers = ConcurrentHashMap<String, MutableList<Observer>>()
  private observers: Map<string, Array<Observer>> = new Map();

  /**
   * 获取单例实例
   */
  public static getInstance(): NotificationCenter {
    if (!NotificationCenter.instance) {
      NotificationCenter.instance = new NotificationCenter();
    }
    return NotificationCenter.instance;
  }

  /**
   * 添加观察者
   * @param name 通知名称
   * @param observer 观察者对象
   * @param callback 回调函数
   */
  public addObserver(name: string, observer: Object, callback: (data: Object) => void): void {
    // 创建一个Observer对象包装回调函数
    const observerWrapper = new ObserverWrapper(callback);

    // 获取或创建观察者列表
    let observers = this.observers.get(name);
    if (!observers) {
      observers = [];
      this.observers.set(name, observers);
    }

    // 添加观察者到列表中
    if (!observers.includes(observerWrapper)) {
      observers.push(observerWrapper);
    }
  }

  /**
   * 移除观察者
   * 相当于Kotlin中的 fun removeObserver(name: String, observer: Observer)
   * @param name 通知名称
   * @param observer 要移除的观察者
   */
  public removeObserver(name: string, observer: Observer): void {
    const observers = this.observers.get(name);
    if (observers) {
      // 过滤掉要移除的观察者
      const index = observers.indexOf(observer);
      if (index !== -1) {
        observers.splice(index, 1);
      }

      // 如果列表为空，则移除整个条目
      if (observers.length === 0) {
        this.observers.delete(name);
      }
    }
  }

  /**
   * 发布通知
   * 相当于Kotlin中的 fun post(name: String, data: Any)
   * @param name 通知名称
   * @param data 要发送的数据，可以是任意类型
   */
  public post<T>(name: string, data: T): void {
    const observers = this.observers.get(name);
    if (observers) {
      // 创建一个副本避免并发修改问题
      const observersCopy = [...observers];
      for (const observer of observersCopy) {
        try {
          // 直接传递原始数据，不做任何转换
          observer.onNotification(data as Map<string, Object>);
        } catch (error) {
          console.error(`[NotificationCenter] 向${name}的观察者发送通知时出错:`, error);
        }
      }
    }
  }

  /**
   * 检查是否有观察者
   * @param name 通知名称
   * @returns 是否有观察者
   */
  public hasObservers(name: string): boolean {
    const observers = this.observers.get(name);
    return observers !== undefined && observers.length > 0;
  }

  /**
   * 移除所有观察者
   * @param name 通知名称
   */
  public removeAllObservers(name: string): void {
    this.observers.delete(name);
  }
}

// 导出单例实例
export default NotificationCenter.getInstance(); 