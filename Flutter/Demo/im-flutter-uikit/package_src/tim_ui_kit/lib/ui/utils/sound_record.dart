import 'dart:async';

import 'package:flutter_plugin_record/const/play_state.dart';
import 'package:flutter_plugin_record/const/response.dart';
import 'package:flutter_plugin_record/index.dart';

typedef PlayStateListener = void Function(PlayState playState);
typedef SoundInterruptListener = void Function();
typedef ResponseListener = void Function(RecordResponse recordResponse);

class SoundPlayer {
  static final FlutterPluginRecord _recorder = FlutterPluginRecord();
  static SoundInterruptListener? _soundInterruptListener;
  static bool isInited = false;

  static initSoundPlayer() {
    if (!isInited) {
      _recorder.init();
      isInited = true;
    }
  }

  static play({required String url}) {
    _recorder.stopPlay();
    if (_soundInterruptListener != null) {
      _soundInterruptListener!();
    }
    _recorder.playByPath(url, 'url');
  }

  static stop() {
    _recorder.stopPlay();
  }

  static dispose() {
    _recorder.dispose();
  }

  static StreamSubscription<PlayState> playStateListener(
          {required PlayStateListener listener}) =>
      _recorder.responsePlayStateController.listen(listener);

  static setSoundInterruptListener(SoundInterruptListener listener) {
    _soundInterruptListener = listener;
  }

  static removeSoundInterruptListener() {
    _soundInterruptListener = null;
  }

  static StreamSubscription<RecordResponse> responseListener(
          ResponseListener listener) =>
      _recorder.response.listen(listener);

  static StreamSubscription<RecordResponse> responseFromAmplitudeListener(
          ResponseListener listener) =>
      _recorder.responseFromAmplitude.listen(listener);

  static startRecord() {
    _recorder.start();
  }

  static stopRecord() {
    _recorder.stop();
  }
}
