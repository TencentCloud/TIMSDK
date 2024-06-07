// Copyright (c) 2023 Tencent. All rights reserved.

import { BaseManagerTestPage } from './BaseManagerTestPage';
import { MessageManagerTestPage } from './MessageManagerTestPage';
import { ConversationManagerTestPage } from './ConversationManagerTestPage';
import { GroupManagerTestPage } from './GroupManagerTestPage';
import { FriendshipManagerTestPage } from './FriendshipManagerTestPage';
import { SignalingTestPage } from './SignalingTestPage';
import { SearchTestPage } from './SearchTestPage';
import { MessageFetchTestPage } from './MessageFetchTestPage';
import { CommunityManagerTestPage } from './CommunityManagerTestPage';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Tabs({barPosition:BarPosition.End}) {
        TabContent() {
          BaseManagerTestPage()
        }.tabBar('基础')

        TabContent() {
          ConversationManagerTestPage()
        }.tabBar('会话')

        TabContent() {
          MessageManagerTestPage()
        }.tabBar('消息')

        TabContent() {
          MessageFetchTestPage()
        }.tabBar('消息拉取')

        TabContent() {
          FriendshipManagerTestPage()
        }.tabBar('关系链')

        TabContent() {
          GroupManagerTestPage()
        }.tabBar('群组')

        TabContent() {
          SearchTestPage()
        }.tabBar('搜索')

        TabContent() {
          SignalingTestPage()
        }.tabBar('信令')

        TabContent() {
          CommunityManagerTestPage()
        }.tabBar('社群')

      }
      .scrollable(true)
      .barMode(BarMode.Scrollable)
      .align(Alignment.Start)
      .height('100%')
      .width('100%')
    }.padding({bottom:15})
  }
}
