import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:timuikit/utils/toast.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

//
class NoConnectivityPage extends StatefulWidget {
  const NoConnectivityPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NoConnectivityPageState();
}

class NoConnectivityPageState extends State<NoConnectivityPage> {
  final Connectivity _connectivity = Connectivity();
  bool hasNetwork = false;
  testConnectivity() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      Utils.toast(imt("当前无网络"));
      setState(() {
        hasNetwork = false;
      });
    } else {
      setState(() {
        hasNetwork = true;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return hasNetwork;
        },
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(imt("当前无网络"),
                style: const TextStyle(fontSize: 26, color: Colors.black45)),
            const Icon(Icons.wifi_off, size: 44, color: Colors.black45),
            TextButton(
              child: Text(imt("重试网络")),
              onPressed: testConnectivity, // 关闭对话框
            ),
          ],
        )));
  }
}
