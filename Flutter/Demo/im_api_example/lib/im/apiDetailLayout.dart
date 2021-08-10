import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:im_api_example/callbacks/callbacks.dart';
import 'package:im_api_example/entity/api_item_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:gradient_ui_widgets/gradient_ui_widgets.dart' as button;
import 'package:flutter/material.dart';
import 'package:im_api_example/provider/event.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class ApiDetailLayout extends StatelessWidget {
  final ApiItem pageData;
  ApiDetailLayout(this.pageData);
  final Gradient g1 = LinearGradient(
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
        padding: EdgeInsets.only(top: 10),
        child: ListView(
          children: [
            ApiCallCard(pageData),
            // InfoCard(pageData),
          ],
        ),
      ),
      floatingActionButton: button.GradientFloatingActionButton(
        onPressed: () {
          openCallback(context);
        },
        child: Icon(Icons.info_outline),
        shape: StadiumBorder(),
        gradient: g1,
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final ApiItem pageData;
  InfoCard(this.pageData);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 6.0,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            //设置shape，这里设置成了R角
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            clipBehavior: Clip.antiAlias,
            semanticContainer: true,
            child: Container(
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
  CodeArea({
    required this.codeFile,
  });
  @override
  State<StatefulWidget> createState() => CodeAreaState();
}

class CodeAreaState extends State<CodeArea> {
  String codeStr = '';

  @override
  void initState() {
    super.initState();
    this.loadFromAssets();
  }

  loadFromAssets() async {
    String fileContents = await rootBundle.loadString(widget.codeFile);
    this.setState(() {
      codeStr = fileContents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return this.codeStr.length > 0
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
      navigationBar:
          CupertinoNavigationBar(leading: Container(), middle: Text('收到的事件回调')),
      child: Container(
        child: Column(
          children: Provider.of<Event>(
            context,
            listen: true,
          ).events.map((e) => SDKResponse(e)).toList(),
        ),
      ),
    ));
  }
}

class ApiCallCard extends StatelessWidget {
  final ApiItem pageData;
  ApiCallCard(this.pageData);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 6.0,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            //设置shape，这里设置成了R角
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            clipBehavior: Clip.antiAlias,
            semanticContainer: true,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: pageData.detailRoute,
            ),
          ),
        )
      ],
    );
  }
}
