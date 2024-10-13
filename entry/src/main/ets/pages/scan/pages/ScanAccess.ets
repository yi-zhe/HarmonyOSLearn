// ScanAccess.est
@Entry
@Component
struct ScanAccess {
  build() {
    RelativeContainer() {
      Text($r('app.string.access_message'))
        .id('AccessMessage')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}