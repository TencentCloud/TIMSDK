import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      Utils.toast('当前无网络');
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
            const Text('当前无网络',
                style: TextStyle(fontSize: 26, color: Colors.black45)),
            const Icon(Icons.wifi_off, size: 44, color: Colors.black45),
            TextButton(
              child: const Text("重试网络"),
              onPressed: testConnectivity, // 关闭对话框
            ),
          ],
        )));
  }
}
