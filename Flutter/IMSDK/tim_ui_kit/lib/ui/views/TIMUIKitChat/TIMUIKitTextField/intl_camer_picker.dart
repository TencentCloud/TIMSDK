import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class IntlCameraPickerTextDelegate extends CameraPickerTextDelegate {
  /// Confirm string for the confirm button.
  /// 确认按钮的字段
  @override
  String get confirm => TIM_t('确认');

  /// Tips string above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字
  @override
  String get shootingTips => TIM_t('轻触拍照，长按摄像');

  /// Tips string above the shooting button before shooting.
  /// 拍摄前确认按钮上方的提示文字
  @override
  String get shootingWithRecordingTips => TIM_t('轻触拍照，长按摄像');

  /// Load failed string for item.
  /// 资源加载失败时的字段
  @override
  String get loadFailed => TIM_t('加载失败');

  /// Semantics fields.
  ///
  /// Fields below are only for semantics usage. For customizable these fields,
  /// head over to [EnglishCameraPickerTextDelegate] for better understanding.
  @override
  String get sActionManuallyFocusHint => TIM_t('手动聚焦');

  @override
  String get sActionPreviewHint => TIM_t('预览');

  @override
  String get sActionRecordHint => TIM_t('录像');

  @override
  String get sActionShootHint => TIM_t('拍照');

  @override
  String get sActionShootingButtonTooltip => TIM_t('拍照按钮');

  @override
  String get sActionStopRecordingHint => TIM_t('停止录像');

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) {
    switch (value) {
      case CameraLensDirection.front:
        return TIM_t('前置');
      case CameraLensDirection.back:
        return TIM_t('后置');
      case CameraLensDirection.external:
        return TIM_t('外置');
    }
  }

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    final option1 = sCameraLensDirectionLabel(value);
    return TIM_t_para("{{option1}} 画面预览", "$option1 画面预览")(option1: option1);
  }

  @override
  String sFlashModeLabel(FlashMode mode) {
    final String _modeString;
    switch (mode) {
      case FlashMode.off:
        _modeString = TIM_t('关闭');
        break;
      case FlashMode.auto:
        _modeString = TIM_t('自动');
        break;
      case FlashMode.always:
        _modeString = TIM_t('拍照时闪光');
        break;
      case FlashMode.torch:
        _modeString = TIM_t('始终闪光');
        break;
    }
    final option2 = _modeString;
    return TIM_t_para("闪光模式: {{option2}}", "闪光模式: $option2")(option2: option2);
  }

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) {
    final option3 = sCameraLensDirectionLabel(value);
    return TIM_t_para("切换至 {{option3}} 摄像头", "切换至 $option3 摄像头")(
        option3: option3);
  }
}
