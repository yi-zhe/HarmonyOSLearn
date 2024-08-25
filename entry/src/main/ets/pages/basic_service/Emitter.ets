/**
 * Emitter主要提供线程间发送和处理事件的能力，包括对持续订阅事件或单次订阅事件的处理、取消订阅事件、发送事件到事件队列等
 *
 * Emitter的开发步骤如下：
 * 1. 订阅事件
 * 2. 发送事件
 */
import emitter from '@ohos.events.emitter';
import promptAction from '@ohos.promptAction';

const TAG: string = 'ThreadModel';

// 定义一个eventId为1的事件
let event: emitter.InnerEvent = {
  eventId: 1
};
@Entry
@Component
struct Emitter {
  build() {
    Column({ space: 10 }) {
      Button('订阅事件')
        .width('100%')
        .onClick(() => {

          // 收到eventId为1的事件后执行该回调
          let callback = (eventData: emitter.EventData): void => {
            promptAction.showToast({
              message: JSON.stringify(eventData.data)
            });
            console.info(TAG, 'event callback:' + JSON.stringify(eventData.data?.content));
          };

          // 订阅eventId为1的事件
          emitter.on(event, callback);
        })
      Button('发送事件')
        .width('100%')
        .onClick(() => {
          // 定义一个eventId为1的事件，事件优先级为Low
          let event: emitter.InnerEvent = {
            eventId: 1,
            priority: emitter.EventPriority.LOW
          };

          let eventData: emitter.EventData = {
            data: {
              content: 'c',
              id: 1,
              isEmpty: false
            }
          };

          // 发送eventId为1的事件，事件内容为eventData
          emitter.emit(event, eventData);
        })

      Button('取消订阅事件')
        .width('100%')
        .onClick(() => {
          emitter.off(event.eventId)
        })
    }
    .width('100%')
    .padding(10)
  }
}
