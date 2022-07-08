import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tencent_im_base/base_widgets/tim_stateless_widget.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/common/utils.dart';

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
