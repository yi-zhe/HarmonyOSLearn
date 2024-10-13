// ResultPage.ets 展示图片识码的结果，以及绘制码图的位置
import { hilog } from '@kit.PerformanceAnalysisKit';
import { scanBarcode } from '@kit.ScanKit';
import { display, router } from '@kit.ArkUI';

const TAG: string = 'ScanKit scanResult';
let typeStr: Array<string> =
  ['FORMAT_UNKNOWN', 'AZTEC_CODE', 'CODABAR_CODE', 'CODE39_CODE', 'CODE93_CODE', 'CODE128_CODE', 'DATAMATRIX_CODE',
    'EAN8_CODE', 'EAN13_CODE',
    'ITF14_CODE', 'PDF417_CODE', 'QR_CODE', 'UPC_A_CODE', 'UPC_E_CODE', ''];

@Entry
@Component
struct ScanResultPage {
  private result: Array<scanBarcode.ScanResult> = [];
  private uri: string = ''
  private infoW: number = 0
  private infoH: number = 0
  @State cameraHeight: number = 1412
  @State cameraWidth: number = 720
  @State layTop: number = 226
  @State layLeft: number = 0
  @State screen: number = 1
  @State rx: number = 0
  @State ry: number = 0
  @State rw: number = 0
  @State rh: number = 0
  public scroller: Scroller = new Scroller()
  private statusHeight: number = 39

  aboutToAppear() {
    let isFold: boolean = display.isFoldable();
    this.setDisplay();
    hilog.info(0x0001, TAG, 'aboutToAppear ResultPage');
    let params = router.getParams() as Record<string, number | string | Array<scanBarcode.ScanResult>>;
    // 识别码图返回结果
    this.result = params.result as Array<scanBarcode.ScanResult>;
    this.uri = params.uri as string;
    this.infoW = params.infoW as number;
    this.infoH = params.infoH as number;
    hilog.info(0x0001, TAG, `Succeeded in getting params: ${JSON.stringify(params)}`);
    hilog.info(0x0001, TAG, `Succeeded in getting result: ${JSON.stringify(this.result)}`);
    hilog.info(0x0001, TAG,
      `Succeeded in getting uri: ${this.uri}, this.infoW: ${this.infoW}, this.infoH: ${this.infoH}`);
    this.calculate();
    if (isFold) {
      display.on('foldStatusChange', async (foldStatus: display.FoldStatus) => {
        // 1:展开态，2：折叠态
        if (foldStatus === 1 || foldStatus === 2) {
          setTimeout(() => {
            this.setDisplay();
            this.calculate();
          }, 300)
        }
      });
    }
  }

  setDisplay(): void {
    hilog.info(0x0001, TAG, 'setDisplay start');
    let displayClass: display.Display | null = null;
    try {
      displayClass = display.getDefaultDisplaySync();
      hilog.info(0x0001, TAG, `Succeeded in getting displayClass: ${JSON.stringify(displayClass)}`);
    } catch (exception) {
      hilog.error(0x0001, TAG, `Failed to get displayClass. Code: ${exception.code}, message: ${exception.message}`);
    }

    if (displayClass !== null) {
      displayClass.height = displayClass.height - vp2px(this.statusHeight);
      this.cameraHeight = Math.round(px2lpx(displayClass.height));
      this.cameraWidth = Math.round(px2lpx(displayClass.width));
      hilog.info(0x0001, TAG, `Succeeded in getting cameraHeight: ${this.cameraHeight}`);
      hilog.info(0x0001, TAG, `Succeeded in getting cameraWidth: ${this.cameraWidth}`);
    }
  }

  calculate() {
    // 计算当前图片宽高和屏幕宽高的比例换算
    if (this.infoW && this.infoH && this.cameraHeight && this.cameraWidth) {
      if (this.infoW / this.infoH > this.cameraWidth / this.cameraHeight) {
        this.screen = 720 / this.infoW;
        this.layTop = (this.cameraHeight - this.cameraWidth * this.infoH / this.infoW) / 2;
        this.layLeft = 0;
      } else {
        this.layTop = 0;
        this.layLeft = (this.cameraWidth - this.cameraHeight * this.infoW / this.infoH) / 2;
        this.screen = this.cameraHeight / this.infoH;
      }
    }
  }

  @Builder
  CustomTextBox(scanType: string, inputValue: string, left: number, top: number, right: number, bottom: number) {
    Column() {
      Column() {
        Text($r('app.string.code_format'))
        Text(scanType).align(Alignment.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 10 })

      Column() {
        Text($r('app.string.result_content'))
        Text(inputValue)
      }.width('100%').justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 10 })

      Column() {

        Text($r('app.string.code_react')).align(Alignment.Start)
        Text('left: ' + left + '  top: ' + top + '  right: ' + right + '  bottom: ' + bottom).align(Alignment.Start)
      }.width('100%').justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 10 })

    }.margin({ bottom: 5 })
  }

  build() {
    Stack() {
      // 显示码图
      Image(this.uri)
        .objectFit(ImageFit.Contain)
        .width('100%').height('100%')
      // 判断二维码返回数据，显示位置
      ForEach(this.result, (item: scanBarcode.ScanResult, index: number) => {
        Column() {
          if (item.scanCodeRect && index >= 0) {
            Image($rawfile('scan_selected.svg'))
              .width(40)
              .height(40)
              .markAnchor({ x: 20, y: 20 })
              .position({
                x: Math.round(item.scanCodeRect.left * this.screen + this.layLeft) +
                  Math.round((item.scanCodeRect.right - item.scanCodeRect.left) * this.screen) / 2 + 'lpx',
                y: Math.round(item.scanCodeRect.top * this.screen + this.layTop) +
                  Math.round((item.scanCodeRect.bottom - item.scanCodeRect.top) * this.screen) / 2 + 'lpx',
              })
          }
        }.width('100%')
        .height('100%')
      })

      Scroll(this.scroller) {
        Column() {
          Image($rawfile('scan_back.svg'))
            .fillColor(Color.Black)
            .width(30)
            .height(30)
            .objectFit(ImageFit.Contain)
            .position({ x: 0, y: 0 })
            .zIndex(10)
            .onClick(async () => {
              router.back();
            })
          Column() {
            Text($r('app.string.title_result'))
              .fontSize(18)
              .fontColor('#000000')
              .margin({ top: 20 })
            ForEach(this.result, (item: scanBarcode.ScanResult) => {
              if (item['scanCodeRect']) {
                this.CustomTextBox(typeStr[item['scanType']], item['originalValue'], item['scanCodeRect']['left'],
                  item['scanCodeRect'].top, item['scanCodeRect'].right, item['scanCodeRect'].bottom)
              }
            })
          }
          .width('80%')
          .height('100%')
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.On)
      .scrollBarColor(Color.Gray)
      .scrollBarWidth(5)
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding({
      top: 40
    })
  }
}
