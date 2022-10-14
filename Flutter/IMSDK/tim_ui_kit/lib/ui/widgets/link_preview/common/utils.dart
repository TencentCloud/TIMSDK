import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/common/extensions.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/link_preview_entry.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/models/link_preview_content.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkUtils {
  static RegExp urlReg = RegExp(
      r"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");

  /// Get all the URL from a text message
  static List<String> getURLMatches(String textMessage) {
    final matches = urlReg.allMatches(textMessage).toList();

    List<String> urlMatches = [];

    for (Match m in matches) {
      String match = m.group(0) ?? "";
      urlMatches.add(match);
    }

    return urlMatches;
  }

  /// Launch URL
  static Future<void> launchURL(BuildContext context, String url) async {
    try {
      await launchUrl(
        Uri.parse(url).withScheme,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TIM_t("无法打开URL"))), // Cannot launch the url
      );
    }
  }

  /// Get color
  static Color hexToColor(String hexString) {
    return Color(int.parse(hexString, radix: 16)).withAlpha(255);
  }

  /// Get the URL preview information
  static Future<List<LinkPreviewModel>> getURLPreview(
      List<String> urlMatches) async {
    // Request for preview information for all URL links synchronously
    final List<LinkPreviewModel> urlPreview =
        await Future.wait(urlMatches.map((e) async {
      String url = e;
      if (!e.contains("http")) {
        url = 'http://$e';
      }
      final WebInfo info = await LinkPreview.scrapeFromURL(url);

      return LinkPreviewModel(
          url: e,
          title: info.title,
          image: info.image,
          description: info.description);
    }));

    return urlPreview;
  }

  /// save the link info to local and call updating the message on UI, only works with [onUpdateMessage]
  static Future<void> saveToLocalAndUpdate(V2TimMessage message,
      LinkPreviewModel previewItem, VoidCallback onUpdateMessage) async {
    if (message.msgID != null) {
      String saveInfo = LinkPreviewEntry.linkInfoToString(previewItem);
      final currentInfo = message.localCustomData;
      if (currentInfo != null && currentInfo.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(currentInfo);
        data['url'] = previewItem.url;
        data['image'] = previewItem.image;
        data['title'] = previewItem.title;
        data['description'] = previewItem.description;
        saveInfo = json.encode(data);
      }
      final result = await TencentImSDKPlugin.v2TIMManager.v2TIMMessageManager
          .setLocalCustomData(msgID: message.msgID!, localCustomData: saveInfo);
      if (result.code == 0) {
        onUpdateMessage();
      }
    }
  }
}
