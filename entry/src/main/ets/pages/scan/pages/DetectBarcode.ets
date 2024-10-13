// DetectBarcode.ets 通过picker选取图片进行图片识码
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { router, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanCore, detectBarcode, scanBarcode } from '@kit.ScanKit';

const TAG = 'ScanKit detectBarcode';

@Entry
@Component
struct DetectBarcodePage {
  build() {
    Column() {
      Button($r('app.string.bitmap_api_decode'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .align(Alignment.Center)
        .type(ButtonType.Capsule)
        .margin({ bottom: 12 })
        .width('90%')
        .height(40)
        .onClick(() => {
          // 定义扫码参数options，图片识码设置扫码参数
          let options: scanBarcode.ScanOptions = {
            scanTypes: [scanCore.ScanType.ALL],
            enableMultiMode: false // 单码识别false,多码识别true
          }
          try {
            // 通过picker拉起图库的图片
            let photoOption = new photoAccessHelper.PhotoSelectOptions();
            photoOption.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
            photoOption.maxSelectNumber = 1;
            let photoPicker = new photoAccessHelper.PhotoViewPicker();
            photoPicker.select(photoOption).then((photoResult) => {
              let infoW: number = 0;
              let infoH: number = 0;
              try {
                let file = fileIo.openSync(photoResult.photoUris[0], fileIo.OpenMode.READ_ONLY);
                const imageSourceApi = image.createImageSource(file.fd);
                imageSourceApi.getImageInfo(0, (error: BusinessError, imageInfo) => {
                  if (imageInfo == undefined) {
                    hilog.error(0x0001, TAG,
                      `Failed to get imageInfo by callbak. Code: ${error.code}, message: ${error.message}`);
                    return;
                  }
                  infoW = imageInfo.size.width;
                  infoH = imageInfo.size.height;
                })
              } catch (error) {
                hilog.error(0x0001, TAG, `Failed to get imageInfo. Code: ${error.code}, message: ${error.message}`);
                return;
              }
              try {
                // 定义扫码参数inputImage，其中uri为picker选择图片
                let inputImage: detectBarcode.InputImage = { uri: photoResult.photoUris[0] }
                // 调用图片识码接口，为promise带参数的接口形式
                detectBarcode.decode(inputImage, options).then((result: Array<scanBarcode.ScanResult>) => {
                  hilog.info(0x0001, TAG,
                    `Succeeded in getting ScanResult by promise with options, result is ${JSON.stringify(result)}`);
                  if (result && result.length > 0) {
                    router.pushUrl({
                      url: 'pages/ResultPage',
                      params: {
                        result: result,
                        uri: photoResult.photoUris[0],
                        infoW: infoW,
                        infoH: infoH,
                        options: options
                      }
                    })
                  } else {
                    promptAction.showToast({
                      message: $r('app.string.Scan_diaLog_not_found'),
                      duration: 2000
                    });
                  }
                }).catch((error: BusinessError) => {
                  if (photoResult.photoUris[0]) {
                    promptAction.showToast({
                      message: $r('app.string.Scan_diaLog_not_found'),
                      duration: 2000
                    });
                    hilog.error(0x0001, TAG,
                      `Failed to get ScanResult by promise with options. Code: ${error.code}, message: ${error.message}`);
                  }
                });
              } catch (error) {
                hilog.error(0x0001, TAG, `Failed to decode. Code: ${error.code}, message: ${error.message}`);
              }
            })
          } catch (error) {
            hilog.error(0x0001, TAG, `Failed to select photo. Code: ${error.code}, message: ${error.message}`);
          }
        });
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}