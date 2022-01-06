import Flutter
import ImSDK_Plus

/* 
    onReciveMessage时防止线程进入过多而导致线程卡死的问题，
    而为Hydra封装的一个线程数量管理类
*/
//public class HydraThreadManager {
//    var limit: Int;
//    var queue: [Any] = [];
//    var bufferArr: [Any] = [];
//    var curThreadNum = 0;
//
//    init(limit: Int) {
//        self.limit = limit
//    }
//
//    public getThreadLimit() {
//
//    }
//
//    public addThread() {
//        self.curThreadNum ++
//        self.queue.append(prmise)
//
//    }
//
//}
