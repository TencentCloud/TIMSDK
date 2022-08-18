import 'package:flutter/material.dart';
import 'package:example/provider/event.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:provider/provider.dart';
import 'package:example/i18n/i18n_utils.dart';

class Callbacks extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CallbackState();
}

class CallbackState extends State<Callbacks> {
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> list =
        Provider.of<Event>(context, listen: true).events;

    return Scaffold(
      appBar: AppBar(
        title: Text(imt("事件回调")),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<Event>(context, listen: false).clearEvents();
            },
            icon: Icon(
              Icons.delete_forever_outlined,
            ),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  primary: true,
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    return SDKResponse(list[index]);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
