import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/common/utils.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/widgets/link_preview.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/widgets/link_text.dart';

import 'models/link_preview_content.dart';

class LinkPreviewEntry {
  /// get the text message with hyperlinks
  static LinkPreviewText? getHyperlinksText(V2TimMessage message,
      [Function(String)? onLinkTap]) {
    final String? messageText = message.textElem!.text;

    if (messageText == null) {
      return null;
    }

    return ({TextStyle? style}) {
      return LinkText(
          messageText: messageText, style: style, onLinkTap: onLinkTap);
    };
  }

  /// get the [LinkPreviewContent] with preview widget and website information for the first link.
  /// If you provide `onUpdateMessage(String linkInfoJson)`, it can save the link info to local custom data than call updating the message on UI automatically.
  static Future<LinkPreviewContent?> getFirstLinkPreviewContent(
      {required V2TimMessage message, VoidCallback? onUpdateMessage}) async {
    final String? messageText = message.textElem!.text;
    if (messageText == null) {
      return null;
    }

    final List<String> urlMatches = LinkUtils.getURLMatches(messageText);
    if (urlMatches.isEmpty) {
      return null;
    }

    final List<LinkPreviewModel?> previewItemList =
        await LinkUtils.getURLPreview([urlMatches[0]]);
    if (previewItemList.isNotEmpty) {
      final LinkPreviewModel previewItem = previewItemList.first!;
      if (onUpdateMessage != null) {
        LinkUtils.saveToLocalAndUpdate(message, previewItem, onUpdateMessage);
      }
      return LinkPreviewContent(
        linkInfo: previewItem,
        linkPreviewWidget: LinkPreviewWidget(linkPreview: previewItem),
      );
    } else {
      return null;
    }
  }

  /// get the [LinkPreviewContent] with preview widget and website information for all the links
  static Future<List<LinkPreviewContent?>?> getAllLinkPreviewContent(
      V2TimMessage message) async {
    final String? messageText = message.textElem!.text;
    if (messageText == null) {
      return null;
    }

    final List<String> urlMatches = LinkUtils.getURLMatches(messageText);
    if (urlMatches.isEmpty) {
      return [];
    }

    final List<LinkPreviewModel> previewItemList =
        await LinkUtils.getURLPreview([urlMatches[0]]);
    if (previewItemList.isNotEmpty) {
      final List<LinkPreviewContent?> resultList = previewItemList
          .map((e) => LinkPreviewContent(
                linkInfo: e,
                linkPreviewWidget: LinkPreviewWidget(linkPreview: e),
              ))
          .toList();

      return resultList;
    } else {
      return [];
    }
  }

  static String linkInfoToString(LinkPreviewModel linkInfo) {
    return linkInfo.toString();
  }

  // static LinkPreviewModel? linkInfoFromString(String linkInfoString){
  //   final Map<String, dynamic> data = json.decode(linkInfoString);
  //   LinkPreviewModel linkPreview = LinkPreviewModel(
  //       url: data['url'],
  //       image: data['image'],
  //       title: data['title'],
  //       description: data['description']
  //   );
  //   return isLinkInfoEmpty(linkPreview) ? null : linkPreview;
  // }
  //
  // static bool isLinkInfoEmpty(LinkPreviewModel linkInfo){
  //   if(linkInfo.image == null && linkInfo.title == null && linkInfo.description == null){
  //     return true;
  //   }
  //   return false;
  // }
}
