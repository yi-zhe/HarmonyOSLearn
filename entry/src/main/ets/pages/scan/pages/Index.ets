import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {

      CustomButton({
        mText: $r('app.string.generate_QR_code'), mOnClick: () => {
          router.pushUrl({
            url: 'pages/scan/pages/CreateBarcode'
          });
        }
      })

      CustomButton({
        mText: $r('app.string.default_view_decode'), mOnClick: () => {
          router.pushUrl({
            url: 'pages/scan/pages/BarcodePage'
          });
        }
      })

      CustomButton({
        mText: $r('app.string.customized_view_decode'), mOnClick: () => {
          router.pushUrl({
            url: 'pages/scan/pages/CustomPage',
            params: {
              hasOptions: true,
              isCallback: false
            }
          });
        }
      })

      CustomButton({
        mText: $r('app.string.bitmap_view_decode'), mOnClick: () => {
          router.pushUrl({
            url: 'pages/scan/pages/DetectBarcode'
          });
        }
      })

    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct CustomButton {
  public mText: string | Resource = ''
  private mHeight: number = 40
  public mOnClick: () => void = () => {
  }

  build() {
    Column() {
      Button(this.mText)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .align(Alignment.Center)
        .type(ButtonType.Capsule)
        .margin({ bottom: 12 })
        .width('90%')
        .height(this.mHeight)
        .onClick(this.mOnClick);
    }
  }
}
