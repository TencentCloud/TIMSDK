class OptimizeUtils {
  static throttle(Function func, int milliseconds) {
    bool enable = true;
    return (val) {
      if (enable == true) {
        enable = false;
        Future.delayed(Duration(milliseconds: milliseconds), () {
          enable = true;
          func();
        });
      }
    };
  }
}
