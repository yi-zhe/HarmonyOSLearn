// BarcodePage.ets 默认界面扫码
import { hilog } from '@kit.PerformanceAnalysisKit';
import { scanCore, scanBarcode } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'ScanKit scanBarcode';

let typeStr: Array<string> =
  ['FORMAT_UNKNOWN', 'AZTEC_CODE', 'CODABAR_CODE', 'CODE39_CODE', 'CODE93_CODE',
    'CODE128_CODE', 'DATAMATRIX_CODE', 'EAN8_CODE', 'EAN13_CODE', 'ITF14_CODE',
    'PDF417_CODE', 'QR_CODE', 'UPC_A_CODE', 'UPC_E_CODE', ''];

@Entry
@Component
struct ScanBarcodePage {
  @State inputValue: string = ''
  @State scanType: number = -1

  build() {
    Column() {
      Button($r('app.string.default_view_decode'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .align(Alignment.Center)
        .type(ButtonType.Capsule)
        .margin({ bottom: 12 })
        .width('90%')
        .height(40)
        .margin({ top: 5, bottom: 5 })
        .onClick(() => {
          // 定义扫码参数options
          let options: scanBarcode.ScanOptions = {
            scanTypes: [scanCore.ScanType.ALL],
            enableMultiMode: true,
            enableAlbum: true
          };
          try {
            scanBarcode.startScanForResult(getContext(this), options).then((result: scanBarcode.ScanResult) => {
              // 收到正确的扫码返回
              this.scanType = result.scanType;
              this.inputValue = result.originalValue;
              hilog.debug(0x0001, TAG,
                `Succeeded in getting ScanResult by promise with options, result is ${JSON.stringify(result)}`);
            }).catch((error: BusinessError) => {
              if (error.code == scanCore.ScanErrorCode.SCAN_SERVICE_CANCELED) {
                hilog.info(0x0001, TAG, `Disabling the Scanning Service.`);
              } else {
                hilog.error(0x0001, TAG, `Failed to start the scanning service. Code: ${error.code}`);
              }
            });
          } catch (error) {
            hilog.error(0x0001, TAG, `Failed to start scan. Code: ${error.code}`);
          }
        })

      CustomTextBox({ scanType: typeStr[this.scanType], inputValue: this.inputValue })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct CustomTextBox {
  @Prop inputValue: string = ''
  @Prop scanType: string = ''

  build() {
    Column() {
      Column() {
        Text(this.scanType)
          .fontSize(20)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Normal)
          .align(Alignment.Center)
          .width('90%')
          .margin({ top: 5, bottom: 5 })
      }

      Column() {
        Text(this.inputValue)
          .fontSize(20)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Normal)
          .align(Alignment.Center)
          .width('90%')
          .margin({ top: 5, bottom: 5 })
      }
    }
  }
}
