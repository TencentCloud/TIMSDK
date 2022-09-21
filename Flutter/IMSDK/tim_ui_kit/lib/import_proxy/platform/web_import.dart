import 'package:tim_ui_kit/import_proxy/import_proxy.dart';

class WebImport implements ImportProxy {
  @override
  void getFlutterPluginRecord() {
    return;
  }
}

ImportProxy getImportProxy() => WebImport();
