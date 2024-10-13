// CustomPage.ets 自定义扫码
import { curves, display, promptAction, router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { scanCore, scanBarcode, customScan } from '@kit.ScanKit';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { xComDisplay, getXComDisplay } from '../utils/Common';
import { PermissionsUtil } from '../utils/PermissionsUtil';
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';

const TAG: string = 'ScanKit customScanPage';
let setInterFlag: number;
let toResultPage: number;

@Extend(Row)
function scanSizes(position: scanBarcode.ScanCodeRect, xDisplay: xComDisplay) {
  .width(position.right - position.left)
  .height(position.bottom - position.top)
  .position({ x: position.left + xDisplay.offsetX, y: position.top + xDisplay.offsetY })
}

@Extend(Image)
function scanCenter(position: scanBarcode.ScanCodeRect, xDisplay: xComDisplay) {
  .width(40)
  .height(40)
  .markAnchor({ x: 20, y: 20 })
  .position({
    x: (position.left + position.right) / 2 + xDisplay.offsetX,
    y: (position.top + position.bottom) / 2 + xDisplay.offsetY
  })
}

@Extend(Button)
function button() {
  .backgroundColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .fontColor(Color.White)
  .align(Alignment.Center)
  .type(ButtonType.Capsule)
  .margin({ bottom: 10 })
  .width(200)
  .height(40)
  .borderRadius(20)
}

@Extend(Row)
function btnRow() {
  .backgroundColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .align(Alignment.Center)
  .margin({ bottom: 10 })
  .width(200)
  .height(40)
  .borderRadius(20)
  .justifyContent(FlexAlign.Center)
}

@Extend(Text)
function btnTextRow() {
  .fontColor(Color.White)
  .align(Alignment.Center)
  .height(40)
}

@Extend(Row)
function angleSizes(x: number, y: number, borderOption: BorderOptions, xDisplay: xComDisplay) {
  .width(20)
  .height(20)
  .border(borderOption)
  .borderColor('#FFFFFF')
  .position({ x: x + xDisplay.offsetX, y: y + xDisplay.offsetY })
}

@Entry
@Component
struct CustomScanPage {
  @State userGrant: boolean = false // 是否已申请相机权限
  @State surfaceId: string = '' // xComponent组件生成id
  @State isShowScanResult: boolean = false // 是否已经识别到码图
  @State isFlashLightEnable: boolean = false // 是否开启了闪光灯
  @State isSensorLight: boolean = false // 记录当前环境亮暗状态
  @State isStopCamera: boolean = false // 是否已经暂停了相机流
  @State zoomValue: number = 1 // 预览流放大倍数
  @State setZoomValue: number = 1 // 显示预览流放大倍数
  @State count: number = 0
  @State isShowFrameResult: boolean = true // 是否显示framework显示结果
  @State scaleValue: number = 1 // 屏幕缩放比
  @State pinchValue: number = 1 // 双指缩放比例
  private displayHeight: number = 0 // 屏幕高度
  private displayWidth: number = 0 // 屏幕宽度
  @State xComDisplay: xComDisplay = {
    // xComponent组件布局样式，宽、高、x轴方向偏移量、y轴方向偏移量
    width: 360,
    height: 640,
    offsetX: 0,
    offsetY: 0
  }
  // 初始化viewControl参数
  @State viewControl: customScan.ViewControl =
    { width: this.xComDisplay.width, height: this.xComDisplay.height, surfaceId: this.surfaceId }
  @State scanCodeRectCallback: Array<scanBarcode.ScanCodeRect> = [] // callback扫码结果码图位置信息，位置类型scanBarcode.ScanCodeRect
  @State scanCodeRect: Array<scanBarcode.ScanResult> = []
  @State scanCodeRectLength: number = 0
  @State scanCodeRectFrameCallback: Array<scanBarcode.ScanCodeRect> = [] // YUV数据frameCallback扫码结果码图位置信息，位置类型scanBarcode.ScanCodeRect
  @State scanLineY: string = '0'
  private mXComponentController: XComponentController = new XComponentController()
  private callback: AsyncCallback<Array<scanBarcode.ScanResult>> = async (error: BusinessError, result:
    Array<scanBarcode.ScanResult>) => {
    if (error) {
      hilog.error(0x0001, TAG, `Failed to get ScanResult by callback. Code: ${error.code}, message: ${error.message}`);
      return;
    }
    this.scanCodeRect = result;
    this.scanCodeRectCallback = [];
    this.scanCodeRectLength = 0;
    this.showScanResult(result);
  }
  // frameCallback回调返回相机预览流(YUV)
  private frameCallback: AsyncCallback<customScan.ScanFrame> =
    async (error: BusinessError, frameResult: customScan.ScanFrame) => {
      if (error || !this.isShowFrameResult) {
        hilog.error(0x0001, TAG, `frameCallback failed, code: ${error.code}, message: ${error.message}`);
      } else {
        customScan.off('lightingFlash');
        hilog.info(0x0001, TAG, `frameCallback width: ${frameResult.width}, height: ${frameResult.height}`);
        // YUV数据更新很快，可以设置更新频率，修改this.count++ % (设置数值，减少更新频率)
        if ((this.count++ % 1) === 0) {
          let ratio: number;
          ratio = this.xComDisplay.width / frameResult.height;
          if (frameResult.scanCodeRects && frameResult.scanCodeRects.length > 0) {
            this.scanCodeRectFrameCallback = [];
            // YUV数据码图位置scanBarcode.ScanCodeRect
            frameResult.scanCodeRects?.forEach((item: scanBarcode.ScanCodeRect) => {
              let reactConverts: scanBarcode.ScanCodeRect = {
                left: (frameResult.height - item.bottom) * ratio,
                top: item.left * ratio,
                right: (frameResult.height - item.top) * ratio,
                bottom: item.right * ratio
              };
              this.scanCodeRectFrameCallback.push(reactConverts);
            })
          }
        }
      }
    };

  aboutToAppear(): void {
    this.setDisplay();
  }

  // 页面显示生命周期
  async onPageShow() {
    hilog.error(0x0001, TAG, `onPageShow - requestCameraPermission before this.userGrant: ${this.userGrant}`);
    // 申请相机权限
    const permissions: Array<Permissions> = ['ohos.permission.CAMERA'];
    let grantStatus = await PermissionsUtil.checkAccessToken(permissions[0]);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // 已经授权，可以继续访问目标操作
      this.userGrant = true;
    } else {
      let grantStatus = await PermissionsUtil.reqPermissionsFromUser()
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          // 用户授权，可以继续访问目标操作
          hilog.info(0x0001, TAG, `requestPermissionsFromUser success`);
          this.userGrant = true;
          break;
        }
      }
    }
    if (this.userGrant) {
      // 检查设备是否可折叠
      if (display.isFoldable()) {
        this.foldStatusSubscribe();
      }
    }
  }

  // 页面消失生命周期
  async onPageHide() {
    this.userGrant = false;
    this.isFlashLightEnable = false;
    this.isSensorLight = false;
    this.customOffLightingFlash();
    clearTimeout(setInterFlag);
    // 页面消失或隐藏时，停止并释放相机流
    await this.customScanRelease();
  }

  aboutToDisappear(): void {
    if (display.isFoldable()) {
      // 取消折叠屏监听
      display.off('foldStatusChange');
    }
  }

  // 自定义扫码界面的顶部返回按钮和扫码提示
  @Builder
  TopTool() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image($rawfile('scan_back.svg'))
          .fillColor(Color.Black)
          .width(30)
          .height(30)
          .objectFit(ImageFit.Contain)
          .onClick(async () => {
            router.back();
          })
      }.padding({ left: 24, right: 24, top: 24 })

      Column() {
        Text($r('app.string.Scan_barcode'))
        Text($r('app.string.Scan_barcode_tips'))
      }.margin({ left: 24, right: 24, top: 24 })
    }
    .height(146)
    .width('100%')
    .margin({ top: 24 })
  }

  build() {
    Stack() {
      if (this.userGrant) {
        Column() {
          // 预览流组件XComponent
          XComponent({
            id: 'componentId',
            type: XComponentType.SURFACE,
            controller: this.mXComponentController
          })
            .onLoad(async () => {
              hilog.info(0x0001, TAG, 'Succeeded in loading, onLoad is called.');
              // 获取XComponent组件的surfaceId
              this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
              hilog.info(0x0001, TAG, `Succeeded in getting surfaceId: ${this.surfaceId}`);
              // 启动相机流
              this.customScanInit();
            })// XComponent宽、高、位置偏移量默认使用单位：vp
            .width(this.xComDisplay.width)
            .height(this.xComDisplay.height)
            .position({ x: this.xComDisplay.offsetX, y: this.xComDisplay.offsetY })
        }
        .height('100%')
        .width('100%')
      }

      // 扫描线动效（可以替换图片），未扫描到结果时显示
      if(this.scanCodeRectLength === 0) {
        Column() {
          Image($rawfile('scan_shadow.png')).width('100%')
            .position({ x: 0, y: this.scanLineY })
            .rotate({
              x: 1,
              angle: 180,
              centerX: 0,
              centerY: 0
            })
        }
        .position({ x: '10%', y: '35%' })
        .width('80%')
        .height('30%')
      }

      // 自定义布局
      Column() {
        this.TopTool()
        Column() {
        }
        .layoutWeight(1)
        .width('100%')

        Column() {
          // 闪光灯按钮，启动相机流后才能使用
          Button('FlashLight').button()
            .onClick(() => {
              // 根据当前闪光灯状态，选择打开或关闭闪关灯
              try {
                if (customScan.getFlashLightStatus()) {
                  customScan.closeFlashLight();
                  this.isFlashLightEnable = false;
                } else {
                  customScan.openFlashLight();
                  this.isFlashLightEnable = true;
                }
              } catch (error) {
                hilog.error(0x0001, TAG, `Failed to flashLight. Code: ${error.code}, message: ${error.message}`);
              }
            })
            .visibility((this.userGrant && this.scanCodeRectLength === 0) ? Visibility.Visible : Visibility.None)

          // 重新扫码按钮
          Button('Scan').button()
            .onClick(() => {
              // 重置扫码数据
              this.scanCodeRectCallback = [];
              this.scanCodeRectFrameCallback = [];
              this.isShowScanResult = false;
              this.scanCodeRectLength = 0;
              this.scanLineY = '0%';
              clearTimeout(toResultPage);
              this.customScanInit();
            })
            .visibility(this.isShowScanResult ? Visibility.Visible : Visibility.None)

          if (this.userGrant && !this.isShowScanResult) {
            Button(this.isShowFrameResult ? 'Close frameYUV' : 'Open frameYUV').button()
              .onClick(() => {
                // 重置扫码数据
                this.scanCodeRectCallback = [];
                this.scanCodeRectFrameCallback = [];
                this.isShowFrameResult = !this.isShowFrameResult;
                clearTimeout(toResultPage);
              })
          }

          if (this.userGrant && !this.isShowScanResult) {
            Row() {
              Row() {
                Text($r('app.string.decode_zoom_current')).btnTextRow()
                Text('' + this.setZoomValue).btnTextRow()
              }
              .btnRow()
              .onClick(() => {
                // 设置相机缩放比例
                if (!this.isShowScanResult) {
                  if (this.zoomValue) {
                    this.setZoomValue = this.zoomValue;
                    customScan.setZoom(this.zoomValue);
                  } else {
                    this.setZoomValue = customScan.getZoom();
                  }
                }
              })
            }
            .margin({ bottom: 10 })

            Row() {
              TextInput({ placeholder: $r('app.string.decode_zoom_enter') })
                .width(200)
                .type(InputType.Number)
                .borderWidth(1)
                .backgroundColor(Color.White)
                .onChange(value => {
                  this.zoomValue = Number(value);
                })
            }
          }
        }
        .height(250)
      }
      .width('100%')
      .height('100%')

      // 相机预览流YUV数据，扫码成功显示码图四个角点框位置,和xComponent外围组件区域保持一致
      if (this.isShowFrameResult) {
        ForEach(this.scanCodeRectFrameCallback, (item: scanBarcode.ScanCodeRect) => {
          // YUV图像码图区域边框
          // 左上角边框
          Row()
            .angleSizes(item.left, item.top, { width: { left: 3, top: 3 } }, this.xComDisplay)
            .markAnchor({ x: 0, y: 0 })
          // 右上角边框
          Row()
            .angleSizes(item.right, item.top, { width: { right: 3, top: 3 } }, this.xComDisplay)
            .markAnchor({ x: 20, y: 0 })
          // 右下角边框
          Row()
            .angleSizes(item.right, item.bottom, { width: { right: 3, bottom: 3 } }, this.xComDisplay)
            .markAnchor({ x: 20, y: 20 })
          // 左下角边框
          Row()
            .angleSizes(item.left, item.bottom, { width: { left: 3, bottom: 3 } }, this.xComDisplay)
            .markAnchor({ x: 0, y: 20 })
          // YUV数据码图中心蓝点，设置opacity数值可以查看
          Image($rawfile('scan_selected.svg'))
            .scanCenter(item, this.xComDisplay)
            .opacity(0)
        }, (item: scanBarcode.ScanCodeRect, index: number) => {
          return index + '__' + JSON.stringify(item);
        })
      }

      // 扫码成功码图位置,和xComponent外围组件区域保持一致
      if (this.scanCodeRectCallback.length > 0) {
        ForEach(this.scanCodeRectCallback, (item: scanBarcode.ScanCodeRect, index: number) => {
          // 图像码图区域，可以设置Row区域背景色
          Row() {
          }.scanSizes(item, this.xComDisplay)

          // 图像码图中心点，识别多码后需要点击蓝点跳转
          Image(this.scanCodeRectLength > 1 ? $rawfile('scan_selected2.svg') : $rawfile('scan_selected.svg'))
            .scanCenter(item, this.xComDisplay)
            .onClick(() => {
              let result: Array<scanBarcode.ScanResult> = [];
              let scanResult: scanBarcode.ScanResult = {
                scanType: this.scanCodeRect[index].scanType,
                originalValue: this.scanCodeRect[index].originalValue,
                scanCodeRect: this.scanCodeRect[index].scanCodeRect
              }
              result.push(scanResult);
              router.replaceUrl({
                url: 'pages/CustomResultPage',
                params: {
                  result: result
                }
              });
            })
        }, (item: scanBarcode.ScanCodeRect, index: number) => {
          return index + '__' + JSON.stringify(item);
        })
      }

    }
    // 建议相机流设置为全屏
    .width('100%')
    .height('100%')
    .onClick((event: ClickEvent) => {
      // 是否已扫描到结果
      if (this.scanCodeRectLength > 0) {
        return;
      }
      // 点击屏幕位置，获取点击位置(x,y)，设置相机焦点
      let x1 = vp2px(event.displayY) / (this.displayHeight + 0.0);
      let y1 = 1.0 - (vp2px(event.displayX) / (this.displayWidth + 0.0));
      hilog.info(0x0001, TAG, `onLoad setFocusPoint x1: ${x1}, y1: ${y1}`);
      try {
        customScan.setFocusPoint({ x: x1, y: y1 });
      } catch (error) {
        hilog.error(0x0001, TAG, `Failed to setFocusPoint. Code: ${error.code}, message: ${error.message}`);
      }
      // 设置连续自动对焦模式
      setTimeout(() => {
        try {
          customScan.resetFocus();
        } catch (error) {
          hilog.error(0x0001, TAG, `Failed to resetFocus. Code: ${error.code}, message: ${error.message}`);
        }
      }, 200);
    }).gesture(PinchGesture({ fingers: 2 })
      .onActionStart((event: GestureEvent) => {
        hilog.info(0x0001, TAG, 'Pinch start');
      })
      .onActionUpdate((event: GestureEvent) => {
        if (event) {
          this.scaleValue = event.scale;
        }
      })
      .onActionEnd((event: GestureEvent) => {
        // 是否已扫描到结果
        if (this.scanCodeRectLength > 0) {
          return;
        }
        // 获取双指缩放比例，设置变焦比
        try {
          let zoom = customScan.getZoom();
          this.pinchValue = this.scaleValue * zoom;
          customScan.setZoom(this.pinchValue);
          hilog.info(0x0001, TAG, 'Pinch end');
        } catch (error) {
          hilog.error(0x0001, TAG, `Failed to setZoom. Code: ${error.code}, message: ${error.message}`);
        }
      }))
  }

  // 显示扫码数据callback回调
  async showScanResult(result: Array<scanBarcode.ScanResult>) {
    this.scanCodeRectLength = result.length;
    if (result.length > 0) {
      this.customScanStop();
      clearTimeout(toResultPage);
      // 扫码成功后码图位置scanBarcode.ScanCodeRect
      result.forEach((item: scanBarcode.ScanResult) => {
        if (item.scanCodeRect) {
          this.scanCodeRectCallback.push(item.scanCodeRect);
        }
      })
      // 识别码图后，停止未识别到码图提示
      clearTimeout(setInterFlag);
      // 打印测试结果，可在获取到结果后做相应处理
      hilog.info(0x0001, TAG, `Succeeded in getting ScanResult.`);
      this.isShowScanResult = true;
      if (this.scanCodeRectLength === 1) {
        toResultPage = setTimeout(() => {
          router.replaceUrl({
            url: 'pages/CustomResultPage',
            params: {
              result: result
            }
          });
        }, 1000);
      }
    }
  }

  // 获取屏幕大小
  setDisplay() {
    // 获取组件xComponent样式： width height offsetX offsetY
    this.xComDisplay = getXComDisplay();
  }

  // 自定义扫码初始化
  customScanInit() {
    if (!this.userGrant) {
      return;
    }
    this.isStopCamera = false;
    let options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true, // 多码扫描
      enableAlbum: true // 图库按钮
    }
    // 自定义扫码配置初始化
    try {
      customScan.init(options);
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to init scan. Code: ${error.code}, message: ${error.message}`);
    }
    this.viewControl = {
      width: this.xComDisplay.width,
      height: this.xComDisplay.height,
      surfaceId: this.surfaceId
    }
    // 启动相机流 callback-获取扫码信息，frameCallback-YUV适合于扫码和识物的综合识别场景
    try {
      customScan.start(this.viewControl, this.callback, this.frameCallback);
      // 点击覆盖图片动画
      animateTo({
        duration: 1500, // 动画时长
        curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1), // 动画曲线
        delay: 100,
        iterations: -1,
        playMode: PlayMode.Normal,
      }, () => {
        this.scanLineY = '100%';
      });
      // 未扫描到码图时，提示信息
      setInterFlag = setTimeout(() => {
        if (this.userGrant && this.scanCodeRectLength === 0) {
          promptAction.showToast({
            message: $r('app.string.Scan_diaLog_not_found'),
            duration: 2000
          });
        }
      }, 5000);
      this.customOnLightingFlash();
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to start scan. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // 暂停相机流
  async customScanStop(): Promise<void> {
    if (!this.isStopCamera) {
      try {
        this.isStopCamera = true;
        customScan.stop((error: BusinessError) => {
          if (error) {
            this.isStopCamera = false;
            hilog.error(0x0001, TAG, `Failed to stop scan. Code: ${error.code}, message: ${error.message}`);
            return;
          }
          hilog.info(0x0001, TAG, 'Succeeded in stopping scan.');
        })
      } catch (error) {
        hilog.error(0x0001, TAG, `Failed to stop customScan. Code: ${error.code}, message: ${error.message}`);
      }
    }
  }

  // 释放相机流
  async customScanRelease(): Promise<void> {
    await this.customScanStop();
    try {
      customScan.release((error: BusinessError) => {
        if (error) {
          hilog.error(0x0001, TAG, `Failed to release scan. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        hilog.info(0x0001, TAG, 'Succeeded in releasing scan.');
      })
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to stop scan. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // 注册闪光灯监听事件
  customOnLightingFlash() {
    try {
      customScan.on('lightingFlash', (error, isLightingFlash) => {
        if (error) {
          hilog.error(0x0001, TAG,
            `Failed to on lightingFlash. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        if (isLightingFlash) {
          this.isFlashLightEnable = true;
          customScan.openFlashLight();
        } else {
          if (!customScan.getFlashLightStatus()) {
            this.isFlashLightEnable = false;
            customScan.closeFlashLight();
          }
        }
      });
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to on lightingFlash. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // 注销闪光灯监听事件
  customOffLightingFlash() {
    try {
      customScan.off('lightingFlash');
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to off lightingFlash. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // 监听折叠屏状态改变，释放、重启相机流逻辑
  foldStatusSubscribe(): void {
    try {
      display.on('foldStatusChange', async (foldStatus: display.FoldStatus) => {
        // 1展开， 2折叠状态改变重新计算宽高
        if (foldStatus === display.FoldStatus.FOLD_STATUS_EXPANDED ||
          foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
          this.scanCodeRectCallback = [];
          this.scanCodeRectFrameCallback = [];
          clearTimeout(toResultPage);
          clearTimeout(setInterFlag);
          // 释放相机流
          this.customScanRelease();
          // 重启相机流
          setTimeout(() => {
            this.setDisplay();
            this.customScanInit();
          }, 300);
        }
      })
    } catch (error) {
      hilog.error(0x0001, TAG, `Failed to foldStatusChange. Code: ${error.code}, message: ${error.message}`);
    }
  }
}