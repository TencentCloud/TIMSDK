import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:example/callbacks/callbacks.dart';
import 'package:example/entity/api_item_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:gradient_ui_widgets/gradient_ui_widgets.dart' as button;
import 'package:flutter/material.dart';
import 'package:example/provider/event.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:example/i18n/i18n_utils.dart';

class ApiDetailLayout extends StatelessWidget {
  final ApiItem pageData;
  const ApiDetailLayout(this.pageData, {Key? key}) : super(key: key);
  final Gradient g1 = const LinearGradient(
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
  );
  openCallback(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Callbacks(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${pageData.apiNameCN} ${pageData.apiName}'),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        child: ListView(
          children: [
            ApiCallCard(pageData: pageData),
            // InfoCard(pageData),
          ],
        ),
      ),
      floatingActionButton: button.GradientFloatingActionButton(
        onPressed: () {
          openCallback(context);
        },
        child: const Icon(Icons.info_outline),
        shape: const StadiumBorder(),
        gradient: g1,
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final ApiItem pageData;
   const InfoCard(this.pageData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 6.0,
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            //设置shape，这里设置成了R角
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            clipBehavior: Clip.antiAlias,
            semanticContainer: true,
            child: SizedBox(
              height: 300,
              child: CodeArea(
                codeFile: pageData.codeFile,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class CodeArea extends StatefulWidget {
  final String codeFile;
   const CodeArea({Key? key, 
    required this.codeFile,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => CodeAreaState();
}

class CodeAreaState extends State<CodeArea> {
  String codeStr = '';

  @override
  void initState() {
    super.initState();
    loadFromAssets();
  }

  loadFromAssets() async {
    String fileContents = await rootBundle.loadString(widget.codeFile);
    setState(() {
      codeStr = fileContents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return codeStr.isNotEmpty
        ? SyntaxView(
            code: codeStr,
            syntax: Syntax.DART,
            syntaxTheme: SyntaxTheme.monokaiSublime(),
            fontSize: 12.0,
            withZoom: false,
            withLinesCount: true,
            expanded: true,
          )
        : Center(
            child: Container(
              height: 30,
              width: 30,
              child: LoadingIndicator(
                indicatorType: Indicator.lineSpinFadeLoader,
                color: Colors.black26,
              ),
            ),
          );
  }
}

class SimpleModal extends StatelessWidget {
  const SimpleModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          leading: Container(), middle: Text(imt(imt("收到的事件回调")))),
      child: Column(
        children: Provider.of<Event>(
          context,
          listen: true,
        ).events.map((e) => SDKResponse(e)).toList(),
      ),
    ));
  }
}

class ApiCallCard extends StatefulWidget {
  const ApiCallCard({Key? key, required this.pageData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ApiCallCardState();

  final ApiItem pageData;
  // const ApiCallCard(this.pageData);
  // Future<Widget> getWidget() async {
  //   await pageData.detailRoute();
  //   return Container();
  // }
  // @override
  // Widget build(BuildContext context) {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Card(
  //           elevation: 6.0,
  //           margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
  //           //设置shape，这里设置成了R角
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(2)),
  //           ),
  //           clipBehavior: Clip.antiAlias,
  //           semanticContainer: true,
  //           child: Padding(
  //             padding: EdgeInsets.all(10),
  //             child:  getWidget(),
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }
}

class ApiCallCardState extends State<ApiCallCard> {
  @override
  void initState() {
    super.initState();
    // loadLib();
  }

  bool isload = false;
  // loadLib() async {
  //   // Object _f = await widget.pageData.detailRoute();
  //   setState(() {
  //     isload = true;
  //   });
  // }

  Widget getWidget() {
    print("渲染 ${widget.pageData.apiName}组件");
    return widget.pageData.libs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.pageData.detailRoute(),
        builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Row(
          children: [
            Expanded(
              child: Card(
                elevation: 6.0,
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                //设置shape，这里设置成了R角
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
                clipBehavior: Clip.antiAlias,
                semanticContainer: true,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: getWidget(),
                ),
              ),
            )
          ],
        );
      }
      return const CircularProgressIndicator();
    });
  }
}
