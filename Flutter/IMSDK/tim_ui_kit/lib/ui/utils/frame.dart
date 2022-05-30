// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'dart:ui';

class Frame {
  static var orginalCallback;

  static init() {
    orginalCallback = window.onReportTimings;
    window.onReportTimings = onReportTimings;
  }

  // 仅缓存最近 25 帧绘制耗时
  static const maxframes = 25;
  static final List<FrameTiming> lastFrames = [];
  // 基准 VSync 信号周期
  static const frameInterval =
      Duration(microseconds: Duration.microsecondsPerSecond ~/ 60);

  static void onReportTimings(List<FrameTiming> timings) {
    lastFrames.addAll(timings);
    // 仅保留 25 帧
    if (lastFrames.length > maxframes) {
      lastFrames.removeRange(0, lastFrames.length - maxframes);
    }
    // 如果有原始帧回调函数，则执行
    if (orginalCallback != null) {
      orginalCallback(timings);
    }
    print("fps: $fps");
  }

  static double get fps {
    int sum = 0;
    for (FrameTiming timing in lastFrames) {
      // 计算渲染耗时
      int duration = timing.timestampInMicroseconds(FramePhase.rasterFinish) -
          timing.timestampInMicroseconds(FramePhase.buildStart);
      // 判断耗时是否在 Vsync 信号周期内
      if (duration < frameInterval.inMicroseconds) {
        sum += 1;
      } else {
        // 有丢帧，向上取整
        int count = (duration / frameInterval.inMicroseconds).ceil();
        sum += count;
      }
    }
    return lastFrames.length / sum * 60;
  }

  static destroy() {
    window.onReportTimings = null;
  }
}
