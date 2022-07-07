import 'dart:convert';

import 'package:flutter/cupertino.dart';

typedef LinkPreviewText = Widget Function({TextStyle? style});

class LinkPreviewModel {
  final String? description;
  final String? image;
  final String url;
  final String? title;

  LinkPreviewModel(
      {this.description, this.image, required this.url, this.title});

  Map<String, String?> toMap() {
    final Map<String, String?> data = {};
    data['url'] = url;
    data['image'] = image;
    data['title'] = title;
    data['description'] = description;
    return data;
  }

  LinkPreviewModel.fromMap(Map map)
      : description = map['description'],
        image = map['image'],
        url = map['url'],
        title = map['title'];

  @override
  String toString() {
    return json.encode(toMap());
  }

  bool isEmpty() {
    if ((image == null || image!.isEmpty) &&
        (title == null || title!.isEmpty) &&
        (description == null || description!.isEmpty)) {
      return true;
    }
    return false;
  }
}

class LinkPreviewContent {
  const LinkPreviewContent({
    this.linkInfo,
    this.linkPreviewWidget,
  });

  final LinkPreviewModel? linkInfo;
  final Widget? linkPreviewWidget;
}
