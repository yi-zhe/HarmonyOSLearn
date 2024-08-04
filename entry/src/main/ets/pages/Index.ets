import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  @State dir2: string = 'Hello World';

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Button('状态管理')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/state/StateManagement' }))
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
