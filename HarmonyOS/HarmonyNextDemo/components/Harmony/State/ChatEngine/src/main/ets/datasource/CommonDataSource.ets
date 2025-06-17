import CommonData from './CommonData';
import { ArrayList, HashMap } from '@kit.ArkTS';

export default class CommonDataSource<T extends CommonData> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private comparator?: ((o1: T, o2: T) => number);
  protected dataSet: ArrayList<T> = new ArrayList();

  setComparator(comparator: (o1: T, o2: T) => number) {
    this.comparator = comparator;
  }

  totalCount(): number {
    return this.dataSet.length;
  }

  isEmpty() {
    return this.dataSet.length === 0;
  }

  getData(index: number): T | null {
    if (index < 0 || this.dataSet.length <= index) {
      return null;
    }
    return this.dataSet[index];
  }

  getIndex(data: T | string) {
    if (typeof data === "string") {
      let index = -1;
      this.dataSet.forEach((item, i) => {
        if (item.ID === data) {
          index = i!;
          return;
        }
      });
      return index;
    }
    return this.dataSet.getIndexOf(data);
  }

  setData(dataList: T[] | ArrayList<T>) {
    this.dataSet = new ArrayList();
    if (!dataList || dataList.length === 0) {
      return;
    }
    dataList.forEach((item: T) => this.dataSet.add(item));
    this.sortDataSet();
    this.notifyDataReload();
  }

  private sortDataSet() {
    if (this.comparator) {
      this.dataSet.sort(this.comparator);
    }
  }

  addData(dataList: T[] | ArrayList<T>, replaceIfPresent = false) {
    if (!dataList || dataList.length === 0) {
      return;
    }
    let index = this.totalCount();
    this.insertData(index, dataList, replaceIfPresent);
  }

  insertData(index: number, dataList: T[] | ArrayList<T>, replaceIfPresent = false) {
    if (!dataList || dataList.length === 0) {
      return;
    }
    if (index < 0 || index > this.dataSet.length) {
      return;
    }
    let addList: ArrayList<T> = new ArrayList();
    let changeData: ArrayList<T> = new ArrayList();
    dataList.forEach((item: T) => addList.add(item));
    if (replaceIfPresent) {
      changeData = this.getReplaceData(dataList);
      changeData.forEach((item) => {
        addList.remove(item);
      });
    }
    this.addAndChangeData(index, addList, changeData);
  }

  private getReplaceData(dataList: ArrayList<T> | T[]) {
    let changeData: ArrayList<T> = new ArrayList();
    this.dataSet.forEach((present) => {
      dataList.forEach((item: T) => {
        if (item.ID === present.ID) {
          changeData.add(item);
        }
      });
    });
    return changeData;
  }

  changedData(dataList: T[] | ArrayList<T>, addIfNotPresent = false) {
    if (!dataList || dataList.length === 0) {
      return;
    }
    if (addIfNotPresent) {
      this.addData(dataList, true);
    } else {
      let changeData = this.getReplaceData(dataList);
      this.addAndChangeData(0, [], changeData);
    }
  }

  private addAndChangeData(addIndex: number, addData: T[] | ArrayList<T>, changeData: ArrayList<T>) {
    addData.forEach((item: T) => {
      this.dataSet.insert(item, addIndex);
      addIndex++;
    });

    let changeMap: HashMap<T, number> = new HashMap();
    changeData.forEach((item: T) => {
      for (let i = 0; i < this.totalCount(); i++) {
        let present: T = this.dataSet[i];
        if (item.ID === present.ID) {
          this.dataSet[i!] = item;
          changeMap.set(item, i);
        }
      }
    });
    this.sortDataSet();
    addData.forEach((item: T) => {
      let index = this.dataSet.getIndexOf(item);
      this.notifyDataAdd(index);
    });

    let minRefreshIndex = Number.MAX_VALUE;
    let maxRefreshIndex = Number.MIN_VALUE;

    changeData.forEach((item: T) => {
      let newIndex = this.dataSet.getIndexOf(item);
      let oldIndex = changeMap.get(item);
      if (newIndex === oldIndex) {
        this.notifyDataChange(newIndex);
      } else {
        minRefreshIndex = Math.min(minRefreshIndex, oldIndex, newIndex);
        maxRefreshIndex = Math.max(maxRefreshIndex, oldIndex, newIndex);
      }
    });
    for (let i = minRefreshIndex; i <= maxRefreshIndex; i++) {
      this.notifyDataChange(i);
    }
  }

  deleteData(dataList: T[] | ArrayList<T>) {
    if (!dataList || dataList.length === 0) {
      return;
    }
    dataList.forEach((item: T) => {
      let index = this.dataSet.getIndexOf(item);
      if (index === -1) {
        return;
      }
      this.dataSet.removeByIndex(index);
      this.notifyDataDelete(index);
    })
  }

  deleteDataByID(dataList: string[] | ArrayList<string>) {
    if (!dataList || dataList.length === 0) {
      return;
    }
    dataList.forEach((item: string) => {
      for (let i = 0; i < this.dataSet.length; i++) {
        let present: T = this.dataSet[i];
        if (present.ID === item) {
          this.dataSet.removeByIndex(i);
          this.notifyDataDelete(i);
          break
        }
      }
    });
  }

  deleteDataByIndex(index: number) {
    if (index < 0 || index > this.totalCount()) {
      return;
    }
    this.dataSet.removeByIndex(index);
    this.notifyDataDelete(index);
  }

  clear() {
    this.dataSet.clear();
  }

  lastData(): T | undefined {
    if (this.dataSet?.length > 0) {
      return this.dataSet[this.dataSet.length - 1];
    }
    return undefined;
  }

  firstData(): T | undefined {
    if (this.dataSet?.length > 0) {
      return this.dataSet[0];
    }
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}
