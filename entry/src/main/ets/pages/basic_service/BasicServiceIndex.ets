import { router } from '@kit.ArkUI';

@Entry
@Component
struct BasicServiceIndex {

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Button('Emitter')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/basic_service/Emitter' }))
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
