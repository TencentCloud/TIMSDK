import { ThemeState, TextUtils } from '../../basecomponent/Index';
import { util } from '@kit.ArkTS';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';

export enum GroupType {
  WORK = 'Work',
  PUBLIC = 'Public',
  MEETING = 'Meeting',
  AVCHATROOM = 'AVChatRoom',
  Community = "Community"
}

interface GroupTypeOption {
  type: GroupType;
  title: string | Resource;
  description: string | Resource;
  isSelected: boolean;
}

export interface GroupTypeSelection {
  type: GroupType;
  title: string | Resource;
  description: string | Resource;
}

export interface GroupTypeSelectorParams {
  selectedType: GroupType;
  onCancel?: () => void;
  onSelect?: (selection: GroupTypeSelection) => void;
}

@Component
export struct GroupTypeSelector {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop selectedType: GroupType = GroupType.WORK;
  onCancel?: () => void;
  onSelect?: (selection: GroupTypeSelection) => void;
  private groupTypeOptions: GroupTypeOption[] = [];

  aboutToAppear() {

    this.groupTypeOptions = this.getGroupTypeOptions();

    this.groupTypeOptions.forEach(option => {
      option.isSelected = option.type === this.selectedType;
    });
  }

  build() {
    Column() {

      this.TitleBarBuilder()

      // Divider
      Divider()
        .color(this.themeState.colors.strokeColorSecondary)
        .strokeWidth(0.5)
        .width('100%')


      Scroll() {
        Column({ space: 16 }) {

          ForEach(this.groupTypeOptions, (option: GroupTypeOption) => {
            this.GroupTypeOptionBuilder(option)
          })


          Row() {
            Text($r('app.string.view_product_documentation'))
              .fontSize(16)
              .fontWeight(400)
              .fontFamily('PingFang SC')
              .fontColor(this.themeState.colors.textColorLink)
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            let context = getContext(this) as common.UIAbilityContext;
            let wantInfo: Want = {
              // uncomment line below if wish to implicitly query only in the specific bundle.
              // bundleName: 'com.example.myapplication',
              action: 'ohos.want.action.viewData',
              // entities can be omitted.
              entities: ['entity.system.browsable'],
              uri: 'https://cloud.tencent.com/product/im'
            }
            context.startAbility(wantInfo).then(() => {
              // ...
            }).catch((err: BusinessError) => {
              // ...
            })
          })
          .width('100%')
          .padding({ top: 16, bottom: 32 })
          .justifyContent(FlexAlign.Center)
        }
        .padding({ left: 16, right: 16, top: 16 })
      }
      .layoutWeight(1)
      .backgroundColor(this.themeState.colors.bgColorOperate)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  TitleBarBuilder() {
    Row() {

      Text($r('app.string.group_type_selector_cancel'))
        .fontSize(16)
        .fontWeight(400)
        .fontFamily('PingFang SC')
        .fontColor(this.themeState.colors.textColorLink)
        .onClick(() => {
          if (this.onCancel) {
            this.onCancel();
          }
        })

      Blank()

      // Title
      Text($r('app.string.group_type_selector_title'))
        .fontSize(20)
        .fontWeight(600)
        .fontFamily('PingFang HK')
        .fontColor(this.themeState.colors.textColorPrimary)
        .letterSpacing(-0.41)

      Blank()


      Text('')
        .width(60)
    }
    .width('100%')
    .height(74)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  GroupTypeOptionBuilder(option: GroupTypeOption) {
    Column() {
      Row() {
        Column() {

          Row({ space: 8 }) {

            if (option.isSelected) {
              Stack() {
                Circle()
                  .width(20)
                  .height(20)
                  .fill(this.themeState.colors.textColorLink)
                Image($rawfile('contactlist/check_on.svg'))
                  .width(16)
                  .height(16)
              }
            } else {
              Circle()
                .width(20)
                .height(20)
                .fill('transparent')
                .border({
                  radius: 10,
                  width: 1,
                  color: this.themeState.colors.strokeColorSecondary
                })
            }

            Text(option.title)
              .fontSize(16)
              .fontWeight(400)
              .fontFamily('PingFang SC')
              .fontColor(this.themeState.colors.textColorPrimary)
          }
          .alignItems(VerticalAlign.Center)


          Text(option.description)
            .fontSize(12)
            .fontWeight(400)
            .fontFamily('PingFang SC')
            .fontColor(this.themeState.colors.textColorTertiary)
            .textAlign(TextAlign.JUSTIFY)
            .lineHeight(16.8)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12
      })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .border({
      width: option.isSelected ? 1 : 1,
      color: option.isSelected ? this.themeState.colors.textColorLink :
      this.themeState.colors.strokeColorSecondary,
      radius: 16
    })
    .onClick(() => {

      this.groupTypeOptions.forEach(opt => {
        opt.isSelected = opt.type === option.type;
      });


      if (this.onSelect) {
        this.onSelect({
          type: option.type,
          title: option.title,
          description: option.description
        });
      }
    })
  }

  private getGroupTypeOptions(): GroupTypeOption[] {
    return [
      {
        type: GroupType.WORK,
        title: $r('app.string.group_type_work_title'),
        description: $r('app.string.group_type_work_description'),
        isSelected: false
      },
      {
        type: GroupType.PUBLIC,
        title: $r('app.string.group_type_public_title'),
        description: $r('app.string.group_type_public_description'),
        isSelected: false
      },
      {
        type: GroupType.MEETING,
        title: $r('app.string.group_type_meeting_title'),
        description: $r('app.string.group_type_meeting_description'),
        isSelected: false
      },
      {
        type: GroupType.AVCHATROOM,
        title: $r('app.string.group_type_avchatroom_title'),
        description: $r('app.string.group_type_avchatroom_description'),
        isSelected: false
      }
    ];
  }
} 