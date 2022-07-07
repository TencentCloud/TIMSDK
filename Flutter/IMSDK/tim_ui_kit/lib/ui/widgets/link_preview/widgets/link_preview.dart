import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/common/utils.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/models/link_preview_content.dart';

class LinkPreviewWidget extends TIMStatelessWidget {
  final LinkPreviewModel linkPreview;

  const LinkPreviewWidget({Key? key, required this.linkPreview})
      : super(key: key);

  @override
  Widget timBuild(BuildContext context) {
    if (linkPreview.isEmpty()) {
      return Container();
    }
    return GestureDetector(
      onTap: () {
        LinkUtils.launchURL(context, linkPreview.url);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
        decoration: const BoxDecoration(
          color: Color(0x19696969),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (linkPreview.title != null && linkPreview.title!.isNotEmpty)
              Text(
                linkPreview.title!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF444444),
                    fontWeight: FontWeight.w400),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (linkPreview.image != null && linkPreview.image!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Image.network(linkPreview.image!),
                    ),
                  ),
                if (linkPreview.description != null &&
                    linkPreview.description!.isNotEmpty)
                  Expanded(
                      child: Text(
                    linkPreview.description!,
                    style: const TextStyle(
                        fontSize: 12.0, color: Color(0xFF999999)),
                  )),
                if ((linkPreview.description == null ||
                        linkPreview.description!.isEmpty) &&
                    linkPreview.title != null &&
                    linkPreview.title!.isNotEmpty)
                  Expanded(
                      child: Text(
                    linkPreview.title!,
                    style: const TextStyle(
                        fontSize: 12.0, color: Color(0xFF999999)),
                  )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
