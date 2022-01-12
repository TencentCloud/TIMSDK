import 'package:flutter/cupertino.dart';
import 'package:discuss/common/colors.dart';

class ListGap extends StatelessWidget {
  const ListGap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: CommonColors.getGapColor(),
    );
  }
}
