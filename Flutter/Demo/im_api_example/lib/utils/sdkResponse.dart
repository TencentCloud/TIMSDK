import 'package:flutter/material.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:pretty_json/pretty_json.dart';

class SDKResponse extends StatelessWidget {
  final Map<String, dynamic>? response;
  final String commonStr =
      "\/\/****************************************************************************************\n\/\/ code=0 业务成功 code!=0 业务失败，请在腾讯云即时通信文档\n\/\/ 信文档查看对应的错误码信息。\n";
  SDKResponse(this.response);

  @override
  Widget build(BuildContext context) {
    return response != null
        ? Row(
            children: [
              Expanded(
                child: SyntaxView(
                  code: (response!['type'] != null
                          ? "\/\/****************************************************************************************\n \/\/ ${response!['type']}触发\n"
                          : commonStr) +
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
