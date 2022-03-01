import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TIMUIKitChatController {
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

  /// 添加消息监听器
  setMessageListener({V2TimAdvancedMsgListener? listener}) {
    return model.initAdvanceListener(listener: listener);
  }

  /// 移除监听器
  removeMessageListener({V2TimAdvancedMsgListener? listener}) {
    return model.removeAdvanceListener(listener: listener);
  }

  /// 销毁
  dispose() {
    model.clear();
  }

  /// 清除历史记录
  clearHistory() {
    model.clearHistory();
  }
}
