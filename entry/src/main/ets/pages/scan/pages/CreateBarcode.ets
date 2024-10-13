// CreateBarcode.ets 码图生成
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanCore, generateBarcode } from '@kit.ScanKit';
import { buffer } from '@kit.ArkTS';

const TAG: string = 'ScanKit createBarcode';

@Extend(Text)
function demoText() {
  .width(60)
  .height(35)
  .fontSize(14)
  .fontColor(0x000000)
  .textAlign(TextAlign.Start)
}

@Extend(TextInput)
function demoTextInput() {
  .caretColor(Color.Blue)
  .fontSize(14)
  .fontWeight(FontWeight.Bold)
  .height(35)
  .width('60%')
}

@Extend(TextArea)
function demoTextArea() {
  .caretColor(Color.Black)
  .fontSize(14)
  .fontColor(Color.Black)
  .fontWeight(FontWeight.Bold)
  .width('80%')
}

@Extend(Select)
function demoSelect() {
  .font({ size: 14 })
  .selectedOptionFont({ size: 14 })
  .optionFont({ size: 14 })
  .width('60%')
  .height(30)
  .backgroundColor('#eeeeee')
}

@Extend(Row)
function demoRow() {
  .margin({ bottom: 15 })
  .justifyContent(FlexAlign.Center)
}

@Extend(Button)
function genButton() {
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .align(Alignment.Center)
  .type(ButtonType.Capsule)
  .margin({ bottom: 12 })
  .width('90%')
  .height(40)
}

@Entry
@Component
struct CreateBarcodePage {
  @State pixelMap: image.PixelMap | undefined = undefined
  @State mContext: string = '123' // 默认设置二维码内容
  @State mScanType: number = scanCore.ScanType.QR_CODE // 默认设置二维码类型 - QR码
  @State mWidth: string = '800' // 默认设置二维码宽度，单位px
  @State mHeight: string = '800' // 默认设置二维码高度，单位px
  @State mMargin: number = 1 // 默认设置二维码边距，单位px
  @State mLevel: generateBarcode.ErrorCorrectionLevel = generateBarcode.ErrorCorrectionLevel.LEVEL_H // 默认设置二维码容错率
  @State mBackgroundColor: number = 0xffffff // 默认设置二维码背景色
  @State mPixelMapColor: number = 0x000000 // 默认设置二维码颜色

  build() {

    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.Wrap,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center
    }) {
      Column() {
      }.height(30)

      Row() {
        // 设置二维码内容
        Text($r('app.string.barcode_content')).demoText()
        TextArea({ placeholder: this.mContext })
          .demoTextArea()
          .onChange((value: string) => {
            this.mContext = value;
          })
      }.width('100%').demoRow()

      // 设置二维码宽度
      Row() {
        Text($r('app.string.barcode_width')).demoText()
        TextInput({ placeholder: '800' }).demoTextInput()
          .type(InputType.Number)
          .onChange((value: string) => {
            this.mWidth = value;
          })
      }.width('50%').demoRow()

      // 设置二维码高度
      Row() {
        Text($r('app.string.barcode_height')).demoText()
        TextInput({ placeholder: '800' }).demoTextInput()
          .type(InputType.Number)
          .onChange((value: string) => {
            this.mHeight = value;
          })
      }.width('50%').demoRow()

      // 设置二维码类型
      Row() {
        Text($r('app.string.barcode_type')).demoText()
        Column() {
          Select(ScanConstant.codeTypeItems)
            .value('QR_CODE')
            .selected(10)
            .demoSelect()
            .onSelect((index: number, value?: string) => {
              hilog.info(0x0001, TAG, `Succeeded in selecting scanType, index is ${index}`);
              this.mScanType = getTypeNum(value);
            })
        }
      }.width('50%').demoRow()

      // 设置二维码边距
      Row() {
        Text($r('app.string.barcode_margin')).demoText()
        TextInput({ placeholder: '1' }).demoTextInput()
          .type(InputType.Number)
          .onChange((value: string) => {
            this.mMargin = Number.parseInt(value);
          })
      }.width('50%').demoRow()

      // 设置二维码颜色
      Row() {
        Text($r('app.string.barcode_color')).demoText()
        Column() {
          Select(ScanConstant.colorItems)
            .selected(0)
            .value('Black')
            .width(100)
            .demoSelect()
            .onSelect((index: number, value?: string) => {
              hilog.info(0x0001, TAG, `Succeeded in selecting pixelMapColor, index is ${index}`);
              this.mPixelMapColor = getColorType(value);
            })
        }
      }.width('50%').demoRow()

      // 设置二维码背景色
      Row() {
        Text($r('app.string.barcode_backgroundcolor')).demoText()
        Column() {
          Select(ScanConstant.colorItems)
            .selected(7)
            .value('White')
            .width(80)
            .demoSelect()
            .onSelect((index: number, value?: string) => {
              hilog.info(0x0001, TAG, `Succeeded in selecting backgroundColor, index is ${index}`);
              this.mBackgroundColor = getColorType(value);
            })
            .align(Alignment.Center)
        }
      }.width('50%').demoRow()

      // 设置二维码纠错水平
      Row() {
        Text($r('app.string.barcode_error_level')).demoText()
        Column() {
          Select(ScanConstant.errorLevelItems)
            .selected(3)
            .value('LEVEL_H')
            .width('60%')
            .demoSelect()
            .onSelect((index: number, value?: string) => {
              hilog.info(0x0001, TAG, `Succeeded in selecting errorLevel, index is ${index}`);
              this.mLevel = getLevelType(value);
            })
        }
      }.width('55%').demoRow()

      Row() {
      }.width('45%').demoRow()

      // 通过文本生成生成码 Promise方式
      Button($r('app.string.generate_barcode')).genButton()
        .onClick(() => {
          this.pixelMap = undefined;
          let content = this.mContext;
          let options: generateBarcode.CreateOptions = {
            scanType: this.mScanType,
            width: Number(this.mWidth),
            height: Number(this.mHeight),
            margin: Number(this.mMargin),
            level: this.mLevel,
            backgroundColor: this.mBackgroundColor,
            pixelMapColor: this.mPixelMapColor,
          }
          try {
            generateBarcode.createBarcode(content, options).then((result: image.PixelMap) => {
              this.pixelMap = result;
            }).catch((error: BusinessError) => {
              hilog.error(0x0001, TAG,
                `Failed to get pixelMap by promise with options. Code: ${error.code}, message: ${error.message}`);
            })
          } catch (error) {
            showError(error);
            hilog.error(0x0001, TAG, `Failed to createBarCode. Code: ${error.code}, message: ${error.message}`);
          }
        })

      // 通过接数组生成码图 Promise方式
      Button($r('app.string.generate_trip_barcode')).genButton()
        .onClick(() => {
          this.pixelMap = undefined;
          let content = this.mContext;
          let pattern = /^[0-9a-fA-F]+$/;
          if (content && !pattern.test(content)) {
            promptAction.showToast({
              message: $r('app.string.trip_barcode_tip'),
              duration: 2000
            });
            return;
          }
          if (content.length % 2 !== 0) {
            content = '0' + content;
          }
          let contentBuffer: ArrayBuffer = buffer.from(content, 'hex').buffer;
          let options: generateBarcode.CreateOptions = {
            scanType: this.mScanType,
            height: Number(this.mHeight),
            width: Number(this.mWidth),
            margin: Number(this.mMargin),
            level: this.mLevel,
            backgroundColor: this.mBackgroundColor,
            pixelMapColor: this.mPixelMapColor,
          }

          try {
            generateBarcode.createBarcode(contentBuffer, options).then((result: image.PixelMap) => {
              this.pixelMap = result;
              hilog.info(0x0001, TAG, 'Succeeded in creating barCode.');
            }).catch((error: BusinessError) => {
              showError(error);
              hilog.error(0x0001, TAG,
                `catch Failed to create barCode. Code: ${error.code}, message: ${error.message}`);
            })
          } catch (error) {
            showError(error);
            hilog.error(0x0001, TAG, `000 Failed to create barCode. Code: ${error.code}, message: ${error.message}`);
          }
        })

      // 生成二维码，图片显示尺寸(300, 300)
      Column() {
        if (this.pixelMap) {
          Image(this.pixelMap).width(300).height(300).objectFit(ImageFit.Contain)
        }
      }.width(300).height(300).margin(10)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#eeeeee')
    .padding({
      left: 10,
      top: 40,
      right: 10,
      bottom: 10
    })
  }
}

// 错误内容提示
function showError(businessError: BusinessError): void {
  try {
    promptAction.showToast({
      message: `Error Code: '${businessError.code}', message: ${businessError.message}`,
      duration: 2000
    });
  } catch (error) {
    let message = (error as BusinessError).message
    let code = (error as BusinessError).code
    hilog.error(0x0001, TAG, `Failed to ShowToast. Code: ${code}, message: ${message}`);
  }
}

export default class ScanConstant {
  static readonly qr_code: Record<string, string> = {
    'scanType': 'qrcode', 'originalValue': 'TEC-IT'
  }
  static readonly colorItems: Array<SelectOption> = [{
    value: 'Black', icon: ''
  },
    {
      value: 'Blue', icon: ''
    },
    {
      value: 'Brown', icon: ''
    },
    {
      value: 'Gray', icon: ''
    },
    {
      value: 'Green', icon: ''
    },
    {
      value: 'Orange', icon: ''
    },
    {
      value: 'Red', icon: ''
    },
    {
      value: 'White', icon: ''
    },
    {
      value: 'Yellow', icon: ''
    }];
  static readonly errorLevelItems: Array<SelectOption> = [{
    value: 'LEVEL_L', icon: ''
  },
    {
      value: 'LEVEL_M', icon: ''
    },
    {
      value: 'LEVEL_Q', icon: ''
    },
    {
      value: 'LEVEL_H', icon: ''
    }];
  static readonly codeTypeItems: Array<SelectOption> = [{
    value: 'AZTEC_CODE', icon: ''
  },
    {
      value: 'CODABAR_CODE', icon: ''
    },
    {
      value: 'CODE93_CODE', icon: ''
    },
    {
      value: 'CODE39_CODE', icon: ''
    },
    {
      value: 'CODE128_CODE', icon: ''
    },
    {
      value: 'DATAMATRIX_CODE', icon: ''
    },
    {
      value: 'EAN8_CODE', icon: ''
    },
    {
      value: 'EAN13_CODE', icon: ''
    },
    {
      value: 'ITF14_CODE', icon: ''
    },
    {
      value: 'PDF417_CODE', icon: ''
    },
    {
      value: 'QR_CODE', icon: ''
    },
    {
      value: 'UPC_A_CODE', icon: ''
    },
    {
      value: 'UPC_E_CODE', icon: ''
    }];
}

function getLevelType(type?: string): generateBarcode.ErrorCorrectionLevel {
  let result: generateBarcode.ErrorCorrectionLevel = generateBarcode.ErrorCorrectionLevel.LEVEL_H;
  switch (type) {
    case 'LEVEL_L':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_L;
      break;
    case 'LEVEL_M':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_M;
      break;
    case 'LEVEL_Q':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_Q;
      break;
    case 'LEVEL_H':
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_H;
      break;
    default:
      result = generateBarcode.ErrorCorrectionLevel.LEVEL_H;
      break;
  }
  return result;
}

function getColorType(type?: string): number {
  let color: number = 0x000000;
  switch (type) {
    case 'Black':
      color = 0x000000;
      break;
    case 'Blue':
      color = 0x0000ff;
      break;
    case 'Brown':
      color = 0xa52a2a;
      break;
    case 'Gray':
      color = 0x808080;
      break;
    case 'Green':
      color = 0x008000;
      break;
    case 'Orange':
      color = 0xffa500;
      break;
    case 'Red':
      color = 0xff0000;
      break;
    case 'White':
      color = 0xffffff;
      break;
    case 'Yellow':
      color = 0xffff00;
      break;
    default:
      color = 0x1e1e1e;
      break;
  }
  return color;
}

function getTypeNum(type?: string): scanCore.ScanType {
  let result: scanCore.ScanType = scanCore.ScanType.QR_CODE;
  switch (type) {
    case 'AZTEC_CODE':
      result = scanCore.ScanType.AZTEC_CODE;
      break;
    case 'CODABAR_CODE':
      result = scanCore.ScanType.CODABAR_CODE;
      break;
    case 'CODE39_CODE':
      result = scanCore.ScanType.CODE39_CODE;
      break;
    case 'CODE93_CODE':
      result = scanCore.ScanType.CODE93_CODE;
      break;
    case 'CODE128_CODE':
      result = scanCore.ScanType.CODE128_CODE;
      break;
    case 'DATAMATRIX_CODE':
      result = scanCore.ScanType.DATAMATRIX_CODE;
      break;
    case 'EAN8_CODE':
      result = scanCore.ScanType.EAN8_CODE;
      break;
    case 'EAN13_CODE':
      result = scanCore.ScanType.EAN13_CODE;
      break;
    case 'ITF14_CODE':
      result = scanCore.ScanType.ITF14_CODE;
      break;
    case 'PDF417_CODE':
      result = scanCore.ScanType.PDF417_CODE;
      break;
    case 'QR_CODE':
      result = scanCore.ScanType.QR_CODE;
      break;
    case 'UPC_A_CODE':
      result = scanCore.ScanType.UPC_A_CODE;
      break;
    case 'UPC_E_CODE':
      result = scanCore.ScanType.UPC_E_CODE;
      break;
    default:
      result = scanCore.ScanType.QR_CODE;
      break;
  }
  return result;
}