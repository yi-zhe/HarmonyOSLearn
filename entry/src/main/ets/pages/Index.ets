import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Button('状态管理v1')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/state/StateIndex' }))
        Button('Basic Service Kit')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/basic_service/BasicServiceIndex' }))
        Button('Scan Kit')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/scan/pages/Index' }))
      }
      .padding(10)
      .width('100%')
      .height('100%')
    }
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
  }
}
