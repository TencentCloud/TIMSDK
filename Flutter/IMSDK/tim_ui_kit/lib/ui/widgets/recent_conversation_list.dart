import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:tim_ui_kit/ui/widgets/az_list_view.dart';
import 'package:tim_ui_kit/ui/widgets/radio_button.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

class RecentForwardList extends StatefulWidget {
  final bool isMultiSelect;
  final Function(List<V2TimConversation> conversationList)? onChanged;

  const RecentForwardList({
    Key? key,
    this.isMultiSelect = true,
    this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecentForwardListState();
}

class _RecentForwardListState extends TIMUIKitState<RecentForwardList> {
  final TUIConversationViewModel _conversationViewModel =
      TUIConversationViewModel();
  final List<V2TimConversation> _selectedConversation = [];

  List<ISuspensionBeanImpl<V2TimConversation?>> _buildMemberList(
      List<V2TimConversation?> conversationList) {
    final List<ISuspensionBeanImpl<V2TimConversation?>> showList =
        List.empty(growable: true);
    for (var i = 0; i < conversationList.length; i++) {
      final item = conversationList[i];
      showList.add(ISuspensionBeanImpl(memberInfo: item, tagIndex: "#"));
    }
    return showList;
  }

  Widget _buildItem(V2TimConversation conversation) {
    final faceUrl = conversation.faceUrl ?? "";
    final showName = conversation.showName ?? "";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.isMultiSelect)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: CheckBoxButton(
              isChecked: _selectedConversation.contains(conversation),
              onChanged: (value) {
                if (value) {
                  _selectedConversation.add(conversation);
                } else {
                  _selectedConversation.remove(conversation);
                }
                setState(() {});
                if (widget.onChanged != null) {
                  widget.onChanged!(_selectedConversation);
                }
              },
            ),
          ),
        Expanded(
            child: InkWell(
          onTap: () {
            if (widget.isMultiSelect) {
              final isSelected = _selectedConversation.contains(conversation);
              if (isSelected) {
                _selectedConversation.remove(conversation);
              } else {
                _selectedConversation.add(conversation);
              }
              if (widget.onChanged != null) {
                widget.onChanged!(_selectedConversation);
              }
              setState(() {});
            } else {
              if (widget.onChanged != null) {
                widget.onChanged!([conversation]);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.only(top: 10, left: 16),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(right: 12),
                  child: Avatar(faceUrl: faceUrl, showName: showName),
                ),
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 10, bottom: 19),
                  decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFDBDBDB)))),
                  child: Text(
                    showName,
                    // textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Color(0xFF111111), fontSize: 18),
                  ),
                ))
              ],
            ),
          ),
        ))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _conversationViewModel.loadData(count: 50);
  }

  @override
  void dispose() {
    super.dispose();
    _conversationViewModel.dispose();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;

    if (!widget.isMultiSelect) {
      _selectedConversation.clear();
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _conversationViewModel),
      ],
      builder: (context, w) {
        final recentConvList =
            Provider.of<TUIConversationViewModel>(context).conversationList;
        final showList = _buildMemberList(recentConvList);

        return AZListViewContainer(
          memberList: showList,
          isShowIndexBar: false,
          susItemBuilder: (context, index) {
            return Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 16.0),
              color: theme.weakDividerColor,
              alignment: Alignment.centerLeft,
              child: Text(
                TIM_t("最近联系人"),
                softWrap: true,
                style: TextStyle(
                  fontSize: 14.0,
                  color: theme.weakTextColor,
                ),
              ),
            );
          },
          itemBuilder: (context, index) {
            final conversation = showList[index].memberInfo;
            if (conversation != null) {
              return _buildItem(conversation);
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
