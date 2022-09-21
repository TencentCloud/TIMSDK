import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tencent_im_base/base_widgets/tim_stateless_widget.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/common/utils.dart';

class LinkTextMarkdown extends TIMStatelessWidget {
  /// Callback for when link is tapped
  final void Function(String)? onLinkTap;

  /// message text
  final String messageText;

  /// text style for default words
  final TextStyle? style;

  const LinkTextMarkdown(
      {Key? key, required this.messageText, this.onLinkTap, this.style})
      : super(key: key);

  @override
  Widget timBuild(BuildContext context) {
    return MarkdownBody(
      data: messageText,
      styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
              textTheme: TextTheme(
                  bodyText2: style ?? const TextStyle(fontSize: 16.0))))
          .copyWith(
        a: TextStyle(color: LinkUtils.hexToColor("015fff")),
      ),
      onTapLink: (
        String link,
        String? href,
        String title,
      ) {
        if (onLinkTap != null) {
          onLinkTap!(link);
        } else {
          LinkUtils.launchURL(context, link);
        }
      },
    );
  }
}

class LinkText extends TIMStatelessWidget {
  /// Callback for when link is tapped
  final void Function(String)? onLinkTap;

  /// message text
  final String messageText;

  /// text style for default words
  final TextStyle? style;

  const LinkText(
      {Key? key, required this.messageText, this.onLinkTap, this.style})
      : super(key: key);

  List<InlineSpan> _getContentSpan(String text, BuildContext context) {
    List<InlineSpan> _contentList = [];

    Iterable<RegExpMatch> matches = LinkUtils.urlReg.allMatches(text);

    int index = 0;
    for (RegExpMatch match in matches) {
      String c = text.substring(match.start, match.end);
      if (match.start == index) {
        index = match.end;
      }
      if (index < match.start) {
        String a = text.substring(index + 1, match.start);
        index = match.end;
        _contentList.add(
          TextSpan(text: a),
        );
      }

      if (LinkUtils.urlReg.hasMatch(c)) {
        _contentList.add(TextSpan(
            text: c,
            style: TextStyle(color: LinkUtils.hexToColor("015fff")),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onLinkTap != null) {
                  onLinkTap!(text.substring(match.start, match.end));
                } else {
                  LinkUtils.launchURL(
                      context, text.substring(match.start, match.end));
                }
              }));
      } else {
        _contentList.add(
          TextSpan(text: c, style: style ?? const TextStyle(fontSize: 16.0)),
        );
      }
    }
    if (index < text.length) {
      String a = text.substring(index, text.length);
      _contentList.add(
        TextSpan(text: a, style: style ?? const TextStyle(fontSize: 16.0)),
      );
    }

    return _contentList;
  }

  @override
  Widget timBuild(BuildContext context) {
    return Text.rich(
      TextSpan(children: [..._getContentSpan(messageText, context)]),
      style: style ?? const TextStyle(fontSize: 16.0),
    );
  }
}
