import { V2TIMKeywordListMatchType } from '@tencentcloud/imsdk';
import { searchInfo, SearchTestInterfaces } from '../interfaces/SearchTestInterfaces';

@Observed
class Result {
  result = "";
}

let result = new Result();

export function writeResult(...args: ESObject[]) {
  let resultList = new Array<string>();
  args.forEach((value: ESObject) => {
    resultList.push(JSON.stringify(value));
  });
  let currentResult = resultList.join(" ");
  result.result = "\n \n" + currentResult;
}

@Entry
@Component
export struct SearchTestPage {
  @State result: Result = result;

  build() {
    Column() {
      Scroll() {
        Column({ space: 4 }) {
          DemoButton("清空", () => {
            this.result.result = "";
          })
          DemoTitle("接口调用结果：")
          DemoText({ name: this.result.result })
        }.alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('35%')
      .align(Alignment.TopStart)

      Divider()

      Scroll() {
        Column({ space: 4 }) {

          Row({ space: 4 }) {
            TextInput({ placeholder: "keyword1" }).onChange((v) => searchInfo.keyword1 = v).demoTextInputStyle()
            TextInput({ placeholder: "keyword2" }).onChange((v) => searchInfo.keyword2 = v).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("searchUserID")
            Checkbox().onChange((v) => searchInfo.isSearchID = v).size({ width: 12, height: 12 })
            DemoLabel("searchUserNickName")
            Checkbox().onChange((v) => searchInfo.isSearchNickName = v).size({ width: 12, height: 12 })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("searchUserRemark")
            Checkbox().onChange((v) => searchInfo.isSearchRemark = v).size({ width: 12, height: 12 })
          }.DemoRowStyle()

          DemoButton("searchFriend", SearchTestInterfaces.searchFriends)

          Divider()

          Row({ space: 4 }) {
            TextInput({ placeholder: "keyword3" }).onChange((v) => searchInfo.keyword3 = v).demoTextInputStyle()
            TextInput({ placeholder: "keyword4" }).onChange((v) => searchInfo.keyword4 = v).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("searchGroupID")
            Checkbox().onChange((v) => searchInfo.isSearchGroupID = v).size({ width: 12, height: 12 })
            DemoLabel("searchGroupName")
            Checkbox().onChange((v) => searchInfo.isSearchGroupName = v).size({ width: 12, height: 12 })
          }.DemoRowStyle()

          DemoButton("searchGroups", SearchTestInterfaces.searchGroups)
          Divider()
          Row({ space: 4 }) {
            TextInput({ placeholder: "groupID1" }).onChange((v) => searchInfo.groupID1 = v).demoTextInputStyle()
            TextInput({ placeholder: "groupID2" }).onChange((v) => searchInfo.groupID2 = v).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: "keyword5" }).onChange((v) => searchInfo.keyword5 = v).demoTextInputStyle()
            TextInput({ placeholder: "keyword6" }).onChange((v) => searchInfo.keyword6 = v).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("SearchMemberID")
            Checkbox().onChange((v) => searchInfo.isSearchMemberUserID = v).size({ width: 12, height: 12 })
            DemoLabel("searchMemberNickName")
            Checkbox().onChange((v) => searchInfo.isSearchMemberNickName = v).size({ width: 12, height: 12 })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            DemoLabel("searchMemberRemark")
            Checkbox().onChange((v) => searchInfo.isSearchMemberRemark = v).size({ width: 12, height: 12 })
            DemoLabel("searchMemberNameCard")
            Checkbox().onChange((v) => searchInfo.isSearchMemberNameCard = v).size({ width: 12, height: 12 })
          }.DemoRowStyle()

          DemoButton("searchGroupMembers", SearchTestInterfaces.searchGroupMembers)
          Divider()

          Row({ space: 4 }) {
            TextInput({ placeholder: "keyword7" }).onChange((v) => searchInfo.keyword7 = v).demoTextInputStyle()
            TextInput({ placeholder: "keyword8" }).onChange((v) => searchInfo.keyword8 = v).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: "sender1" }).onChange((v) => searchInfo.senderID1 = v).demoTextInputStyle()
            TextInput({ placeholder: "sender2" }).onChange((v) => searchInfo.senderID2 = v).demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: "conversationID" })
              .onChange((v) => searchInfo.conversationID = v)
              .demoTextInputStyle()
            DemoLabel("KeywordsMatchType_AND(default OR)")
            Checkbox()
              .onChange((v) => {
                searchInfo.keywordsMatchType = v ? V2TIMKeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_AND : V2TIMKeywordListMatchType.V2TIM_KEYWORD_LIST_MATCH_TYPE_OR;
              })
              .size({ width: 12, height: 12 })
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: "timePosition" })
              .type(InputType.Number)
              .onChange((v) => searchInfo.searchTimeStart = parseInt(v))
              .demoTextInputStyle()
            TextInput({ placeholder: "timePeriod" })
              .type(InputType.Number)
              .onChange((v) => searchInfo.searchTimePeriod = parseInt(v))
              .demoTextInputStyle()
          }.DemoRowStyle()

          Row({ space: 4 }) {
            TextInput({ placeholder: "pageIndex" })
              .type(InputType.Number)
              .onChange((v) => searchInfo.pageIndex = parseInt(v))
              .demoTextInputStyle()
            TextInput({ placeholder: `pageSize(${searchInfo.pageSize})` })
              .type(InputType.Number)
              .onChange((v) => searchInfo.pageSize = parseInt(v))
              .demoTextInputStyle()
          }.DemoRowStyle()

          DemoButton("searchLocalMessage", SearchTestInterfaces.searchLocalMessages)
        }.justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .align(Alignment.TopStart)

      }.height('65%')
      .width('100%')
      .align(Alignment.TopStart)

    }
  }
}

@Builder function DemoButton(name: string, onclickEvent?: (event?: ClickEvent) => void) {
  Button({ stateEffect: true, type: ButtonType.Normal }) {
    Text(name).fontSize(12).fontColor(Color.White)
  }
  .padding(4)
  .borderRadius(4)
  .onClick(onclickEvent)
}

interface DemoTextInterface {
  name: string;
}

@Builder function DemoText(param: DemoTextInterface) {
  Text(param.name).fontSize(11).fontWeight(FontWeight.Bold)
}

@Builder function DemoTitle(name: string) {
  Text(name).fontSize(12).margin(10).fontWeight(FontWeight.Bold)
}

@Builder function DemoLabel(name: string) {
  Text(name + ":").fontSize(10).margin(10)
}

@Extend(TextInput) function demoTextInputStyle() {
  .width('30%')
  .padding(8)
  .borderRadius(4)
  .fontSize(10)
  .placeholderFont({ size: 10 })
}

@Extend(Row) function DemoRowStyle() {
  .width('100%')
  .justifyContent(FlexAlign.Start)
}
