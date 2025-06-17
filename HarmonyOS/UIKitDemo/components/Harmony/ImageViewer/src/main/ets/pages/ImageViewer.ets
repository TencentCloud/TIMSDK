import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import { ThemeManager } from 'basecomponent';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';

/**
 * 图片来源类型
 */
export enum ImageSourceType {
  URL = 0, // 网络URL
  LOCAL = 1 // 本地路径
}

/**
 * 图片查看器页面
 * 支持网络图片和本地图片查看
 * 支持缩放、平移手势
 */
@Entry({ routeName: 'ImageViewer' })
@Component
export struct ImageViewer {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  // 图片源类型
  @State imageType: ImageSourceType = ImageSourceType.URL;
  // 图片URL或本地路径
  @State imagePath: string = '';
  // 图片加载状态
  @State isLoading: boolean = true;
  // 图片加载错误
  @State hasError: boolean = false;
  // 错误信息
  @State errorMessage: string = '';
  // 本地临时文件路径（用于网络图片下载后的缓存）
  @State localTempPath: string = '';
  // 当前缩放比例
  @State currentScale: number = 1.0;
  // 缩放中心点X坐标
  @State centerX: number = 0;
  // 缩放中心点Y坐标
  @State centerY: number = 0;
  // 平移偏移量X
  @State offsetX: number = 0;
  // 平移偏移量Y
  @State offsetY: number = 0;
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {

    // 使用router获取参数，而不是context.want
    const params = router.getParams() as Record<string, string>;
    if (params) {
      // 获取图片类型参数
      if (params.imageType !== undefined) {
        this.imageType = parseInt(params.imageType);
      }

      // 获取图片路径参数
      if (params.imagePath !== undefined) {
        this.imagePath = params.imagePath;
      }
    }

    // 根据图片类型处理图片
    if (this.imageType === ImageSourceType.URL) {
      // 下载网络图片
      this.downloadImage();
    } else {
      // 本地图片，直接设置加载完成
      this.isLoading = false;
    }
  }

  /**
   * 加载中状态UI构建器
   */
  @Builder
  LoadingStateBuilder() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(this.themeManager.currentTheme.textColorPrimary)

      Text('加载中...')
        .fontSize(16)
        .fontColor(this.themeManager.currentTheme.textColorTertiary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 错误状态UI构建器
   */
  @Builder
  ErrorStateBuilder() {
    Column() {
      // 使用通用错误图标或文本代替资源
      Image($r('sys.media.ohos_app_icon'))
        .width(80)
        .height(80)
        .fillColor(this.themeManager.currentTheme.textColorTertiary)

      Text('加载失败')
        .fontSize(18)
        .fontColor(this.themeManager.currentTheme.textColorTertiary)
        .margin({ top: 16 })

      Text(this.errorMessage)
        .fontSize(14)
        .fontColor(this.themeManager.currentTheme.textColorTertiary)
        .margin({ top: 8 })

      Button('重试')
        .margin({ top: 24 })
        .onClick(() => {
          this.isLoading = true;
          this.hasError = false;
          this.downloadImage();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')

      if (this.isLoading) {
        // 加载中
        this.LoadingStateBuilder()
      } else if (this.hasError) {
        // 加载错误
        this.ErrorStateBuilder()
      } else {
        // 图片显示区域
        Column() {
          Image(this.getDisplayImagePath())
            .objectFit(ImageFit.Contain)
            .width('100%')
            .height('100%')
            .translate({ x: this.offsetX, y: this.offsetY })
            .scale({ x: this.currentScale, y: this.currentScale })
            .onComplete(() => {
              // 图片加载完成后重置缩放和平移
              this.resetZoomAndPan();
            })
            // 缩放手势
            .gesture(
              PinchGesture({ fingers: 2 })
                .onActionStart((event: GestureEvent) => {
                  // 记录开始缩放，但不使用不存在的属性
                  console.info(`[ImageViewer] 开始缩放`);
                })
                .onActionUpdate((event: GestureEvent) => {
                  // 计算新的缩放比例，限制缩放范围为1~1.5倍
                  const prevScale = this.currentScale;
                  const newScale = Math.max(1.0, Math.min(1.5, this.currentScale * event.scale));
                  this.currentScale = newScale;
                  
                  // 微信风格的缩放效果：缩放时图片保持在手指中心位置
                  if (Math.abs(prevScale - newScale) > 0.01) {
                    // 当缩放比例接近1时，确保平移量渐进归零，实现自动回到中心
                    if (Math.abs(newScale - 1.0) < 0.05) {
                      // 逐渐回到中心，而不是立即回到中心
                      this.offsetX *= 0.5;
                      this.offsetY *= 0.5;
                    }
                  }
                })
                .onActionEnd(() => {
                  // 缩放结束时，如果缩放比例接近1，直接重置为完全居中状态
                  if (Math.abs(this.currentScale - 1.0) < 0.05) {
                    this.currentScale = 1.0;
                    this.offsetX = 0;
                    this.offsetY = 0;
                  }
                  console.info(`[ImageViewer] 结束缩放, 最终缩放: ${this.currentScale}`);
                })
            )
            // 平移手势
            .gesture(
              PanGesture({ fingers: 1, direction: PanDirection.All })
                .onActionStart(() => {
                  console.info('[ImageViewer] 开始平移');
                })
                .onActionUpdate((event: GestureEvent) => {
                  // 只有在缩放比例大于1时才允许平移
                  if (this.currentScale > 1.0) {
                    // 大幅减小平移速度，使其更接近微信的平移手感
                    const dampingFactor = 0.1; // 降低到0.3，比之前的0.6更慢
                    const deltaX = event.offsetX * dampingFactor;
                    const deltaY = event.offsetY * dampingFactor;
                    
                    this.offsetX += deltaX;
                    this.offsetY += deltaY;
                    
                    // 使用更精确的估计值
                    const viewWidth = 390; // 更接近常见手机屏幕宽度的估计值
                    const viewHeight = 640; // 更接近常见手机屏幕高度的估计值
                    
                    // 根据缩放比例计算最大可平移距离
                    const maxOffsetX = (this.currentScale - 1.0) * viewWidth / 2;
                    const maxOffsetY = (this.currentScale - 1.0) * viewHeight / 2;
                    
                    // 限制平移范围，保持图片始终在视野内
                    this.offsetX = Math.max(-maxOffsetX, Math.min(maxOffsetX, this.offsetX));
                    this.offsetY = Math.max(-maxOffsetY, Math.min(maxOffsetY, this.offsetY));
                  }
                })
                .onActionEnd(() => {
                  // 如果缩放比例几乎为1，强制回到中心
                  if (Math.abs(this.currentScale - 1.0) < 0.05) {
                    this.resetZoomAndPan();
                  }
                  console.info('[ImageViewer] 结束平移');
                })
            )
            // 双击手势
            .gesture(
              TapGesture({ count: 2 })
                .onAction(() => {
                  // 双击切换缩放：如果接近原始大小则放大到1.5倍，否则重置为1倍
                  if (Math.abs(this.currentScale - 1.0) < 0.1) {
                    this.currentScale = 1.5;
                    // 不使用事件位置，始终居中缩放
                  } else {
                    this.resetZoomAndPan();
                  }
                })
            )
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 顶部导航栏
      Column() {
        Row() {
          Button() {
            // 使用系统返回图标
            Image($r('sys.media.ohos_ic_back'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
          }
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .borderRadius(24)
          .width(48)
          .height(48)
          .margin({ left: 16 })
          .onClick(() => this.closeViewer())
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .gesture(
      TapGesture()
        .onAction(() => {
          // 单击关闭查看器
          this.closeViewer();
        })
    )
  }

  /**
   * 下载网络图片
   */
  private downloadImage() {
    if (!this.imagePath) {
      this.hasError = true;
      this.errorMessage = '图片URL为空';
      this.isLoading = false;
      return;
    }

    // 创建HTTP请求
    let httpRequest = http.createHttp();

    httpRequest.request(
      this.imagePath,
      {
        method: http.RequestMethod.GET,
        readTimeout: 30000,
        connectTimeout: 30000
      },
      (err, data) => {
        if (err) {
          console.error(`[ImageViewer] 下载图片失败: ${JSON.stringify(err)}`);
          this.hasError = true;
          this.errorMessage = `下载失败: ${err.message}`;
          this.isLoading = false;
          return;
        }

        if (data.responseCode === 200) {
          // 保存到临时文件
          this.saveToTempFile(data.result as ArrayBuffer);
        } else {
          console.error(`[ImageViewer] 下载图片失败, HTTP状态码: ${data.responseCode}`);
          this.hasError = true;
          this.errorMessage = `下载失败: HTTP状态码 ${data.responseCode}`;
          this.isLoading = false;
        }
      }
    );
  }

  /**
   * 保存下载的图片到临时文件
   */
  private saveToTempFile(data: ArrayBuffer) {
    try {
      // 获取缓存目录
      const cacheDir = this.context.cacheDir;
      // 创建临时文件名
      const fileName = `img_${new Date().getTime()}.jpg`;
      const filePath = `${cacheDir}/${fileName}`;

      // 打开文件并写入数据
      let file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, data);
      fs.closeSync(file);

      // 更新本地临时路径
      this.localTempPath = filePath;
      this.isLoading = false;

    } catch (error) {
      console.error(`[ImageViewer] 保存临时文件失败: ${JSON.stringify(error)}`);
      this.hasError = true;
      this.errorMessage = '保存图片失败';
      this.isLoading = false;
    }
  }

  /**
   * 获取当前显示的图片路径
   */
  private getDisplayImagePath(): string {
    if (this.imageType === ImageSourceType.URL) {
      return this.localTempPath || '';
    } else {
      return this.imagePath;
    }
  }

  /**
   * 关闭查看器
   */
  private closeViewer() {
    // 删除临时文件
    if (this.localTempPath && fs.accessSync(this.localTempPath)) {
      try {
        fs.unlinkSync(this.localTempPath);
      } catch (error) {
        console.error(`[ImageViewer] 删除临时文件失败: ${JSON.stringify(error)}`);
      }
    }

    // 返回上一页
    router.back();
  }

  /**
   * 重置缩放和平移状态
   */
  private resetZoomAndPan() {
    this.currentScale = 1.0;
    this.offsetX = 0;
    this.offsetY = 0;
  }
} 