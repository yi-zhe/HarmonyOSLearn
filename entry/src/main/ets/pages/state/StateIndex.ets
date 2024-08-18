import { router } from '@kit.ArkUI';

@Entry
@Component
struct StateIndex {

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Button('State')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/state/StateManagement' }))
        Button('Prop')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/state/PropManagement' }))
        Button('Link')
          .width('100%')
          .onClick(() => router.pushUrl({ url: 'pages/state/LinkManagement' }))
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
