import 'package:example/i18n/i18n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:pretty_json/pretty_json.dart';

class SDKResponse extends StatelessWidget {
  final Map<String, dynamic>? response;
  final String commonStrText = imt("code=0 业务成功 code!=0 业务失败，请在腾讯云即时通信文档文档查看对应的错误码信息。\n");
  final String commonStr =
      "\/\/****************************************************************************************\n\/\/";
  String triggerText(type) => "$type 触发\n";
  SDKResponse(this.response);

  @override
  Widget build(BuildContext context) {
    String? triggerType = response?['type'];
    return response != null
        ? Row(
      children: [
        Expanded(
          child: SyntaxView(
            code: (response!['type'] != null
                ? ("\/\/****************************************************************************************\n \/\/ " + triggerText(triggerType))
                : (commonStr + commonStrText)) +
                prettyJson(response, indent: 2), // Code text
            syntax: Syntax.DART, // Language
            syntaxTheme: SyntaxTheme.monokaiSublime(), // Theme
            fontSize: 12.0, // Font size
            withZoom: false, // Enable/Disable zoom icon controls
            withLinesCount: true, // Enable/Disable line number
            expanded: false, // Enable/Disable container expansion
          ),
        )
      ],
    )
        : Container();
  }
}