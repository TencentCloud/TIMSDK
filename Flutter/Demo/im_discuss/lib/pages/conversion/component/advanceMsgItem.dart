import 'package:flutter/material.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/conversion/dataInterface/advancemsglist.dart';

class AdvanceMsgItem extends StatelessWidget {
  onPressed() {
    list.onPressed();
  }

  final AdvanceMsgList list;
  const AdvanceMsgItem(this.list, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: list.icon,
                onPressed: onPressed,
              ),
            ),
            Text(
              list.name,
              style: TextStyle(
                fontSize: 12,
                color: CommonColors.getTextWeakColor(),
              ),
            )
          ],
        ));
  }
}
