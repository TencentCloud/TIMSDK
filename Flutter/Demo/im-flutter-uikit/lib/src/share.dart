// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';

/// 点击事件
typedef OnItemClickListener = void Function(int index);
typedef DoAction = void Function(ShareType shareType, ShareInfo shareInfo);
// ignore: constant_identifier_names
enum ShareType { SESSION, TIMELINE, COPY_LINK, DOWNLOAD }

/// 定义分享内容
class ShareInfo {
  /// 标题
  String title;

  /// 连接
  String url;

  /// 图片
  var img;

  /// 描述
  String describe;

  ShareInfo(this.title, this.url, {this.img, this.describe = ""});

  static ShareInfo fromJson(Map map) {
    return ShareInfo(map['title'], map['url'],
        img: map['img'], describe: map['describe']);
  }
}

/// 分享操作
class ShareOpt {
  final String title;
  final Widget img;
  final DoAction doAction;
  final ShareType shareType;

  const ShareOpt(
      {this.title = "",
      required this.img,
      this.shareType = ShareType.SESSION,
      required this.doAction});
}

/// 弹出窗
class ShareWidget extends StatefulWidget {
  final List<ShareOpt> list;
  final ShareInfo shareInfo;

  const ShareWidget(this.shareInfo, {Key? key, required this.list})
      : super(key: key);

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Container(
        // margin: const EdgeInsets.only(left: 10, right: 10),
        //边框设置
        decoration: BoxDecoration(
          //背景
          color: hexToColor('E9E9EA'),
          //设置四周边框
          border: Border.all(
            width: 1,
            color: hexToColor('E9E9EA'),
          ),
          //设置四周圆角角度
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        //设置 child 居中
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Center(
                child: Text(
                  '分享到',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 5.0,
                      childAspectRatio: 1.0),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque, // 空白地方也可以点击
                      onTap: () {
                        Navigator.pop(context);
                        widget.list[index].doAction(
                            widget.list[index].shareType, widget.shareInfo);
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 10.0),
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: widget.list[index].img,
                            ),
                          ),
                          Text(widget.list[index].title)
                        ],
                      ),
                    );
                  },
                  itemCount: widget.list.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
