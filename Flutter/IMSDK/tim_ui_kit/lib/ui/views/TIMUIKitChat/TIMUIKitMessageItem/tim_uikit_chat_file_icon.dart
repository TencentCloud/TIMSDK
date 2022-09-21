// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';

class TIMUIKitFileIcon extends TIMUIKitStatelessWidget {
  final String? fileFormat;

  TIMUIKitFileIcon({this.fileFormat, Key? key}) : super(key: key);

  Map fileMap = {
    "doc": "images/word.png",
    "docx": "images/word.png",
    "ppt": "images/ppt.png",
    "pptx": "images/ppt.png",
    "xls": "images/excel.png",
    "xlsx": "images/excel.png",
    "pdf": "images/pdf.png",
    "zip": "images/zip.png",
    "rar": "images/zip.png",
    "7z": "images/zip.png",
    "tar": "images/zip.png",
    "gz": "images/zip.png",
    "xz": "images/zip.png",
    "bz2": "images/zip.png",
    "txt": "images/txt.png",
    "jpg": "images/image_icon.png",
    "bmp": "images/image_icon.png",
    "gif": "images/image_icon.png",
    "png": "images/image_icon.png",
    "jpeg": "images/image_icon.png",
    "tif": "images/image_icon.png",
    "wmf": "images/image_icon.png",
    "dib": "images/image_icon.png",
  };

  Widget _getFileIcon() {
    return Image.asset(
      fileMap[fileFormat?.toLowerCase()] ?? "images/unknown.png",
      package: 'tim_ui_kit',
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return SizedBox(
      height: 50,
      width: 50,
      child: Container(padding: const EdgeInsets.all(4), child: _getFileIcon()),
    );
  }
}
