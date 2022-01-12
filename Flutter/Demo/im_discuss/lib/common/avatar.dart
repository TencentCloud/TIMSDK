import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:discuss/common/colors.dart';

// ignore: must_be_immutable
class Avatar extends StatelessWidget {
  late String avtarUrl = '';
  late double width = 0;
  late double height = 0;
  late double radius = 0;
  Avatar({Key? key, avtarUrl, width, height, radius}) : super(key: key) {
    this.avtarUrl = avtarUrl.toString();
    this.width = width.toDouble();
    this.height = height.toDouble();
    this.radius = radius.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        height: height,
        child: avtarUrl.contains('http')
            ? Image.network(
                avtarUrl,
                width: width,
                height: height,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  Utils.log("图片渲染失败$avtarUrl");
                  return Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: CommonColors.getBorderColor(),
                      ),
                      top: BorderSide(
                        width: 1,
                        color: CommonColors.getBorderColor(),
                      ),
                      left: BorderSide(
                        width: 1,
                        color: CommonColors.getBorderColor(),
                      ),
                      right: BorderSide(
                        width: 1,
                        color: CommonColors.getBorderColor(),
                      ),
                    )),
                  );
                },
              )
            : Image(
                image: AssetImage(avtarUrl),
                width: width,
                height: height,
              ),
      ),
    );
  }
}
