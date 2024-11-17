import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi from 'libentry.so';
import { HashMap } from '@kit.ArkTS';
import demo from '../../Demo'

interface Obj1 {
  obj: Obj2,
  hello: String,
  arr: number[],
  typedArray: Uint8Array
}

interface Obj2 {
  str: string
}


let jsCodeStr = `{
let a = "hello World";
consoleinfo(a);
let b = add(99, 1);
const mPromise = createPromise();
mPromise.then((result) => {
assertEqual(result, 0);
onJSResultCallback(result, "abc", "v");
});
a;
};`;

function MyCallback(a: string, b: string): string {
  console.log("TEST MyCallback run: " + a);
  b = "callback done";
  console.log("TEST MyCallback run: " + b);
  return "callback pass";
}


@Entry
@Component
struct Index {
  build() {
    Scroll() {
      Column({ space: 10 }) {
        Button("map数据在TS和C++传递")
          .width('100%')
          .onClick(() => {
            let hashmap: HashMap<string, number> = new HashMap()
            hashmap.set("Abc", 123)
            hashmap.set("Bcd", 234)
            hashmap.set("Cde", 345)
            for (let key of hashmap.keys()) {
              testNapi.mapDemo(key, hashmap.get(key))
              console.info(`key is ${key}, value is ${hashmap.get(key)}`)
            }
          })
        Button("Native修改ArkTS的Object类型的数据、属性")
          .width('100%')
          .onClick(() => {
            const typedArr = new Uint8Array(3);
            typedArr[0] = 1;
            typedArr[1] = 2;
            typedArr[2] = 3;
            const obj: Obj1 = {
              obj: { str: 'obj in obj' },
              hello: 'world',
              arr: [94, 32, 43],
              typedArray: typedArr
            }
            console.info(`Test NAPI modifyObject result is ${JSON.stringify(testNapi.modifyObject(obj))}`)
          })
        Button("2个整数相加")
          .width('100%')
          .onClick(() => {
            console.info(`result is ==>${testNapi.add(1, 10)}`);
          })
        Button("TS侧如何调用C++生成的Buffer")
          .width('100%')
          .onClick(() => {
            let arr = testNapi.testBuffer();
            let result = new Uint8Array(arr);
            for (let index = 0; index < result.byteLength; index++) {
              console.info(`res[${index}] = ${result[index]}`)
            }
          })

        Button("Native获取ArkTS类实例,调用TS的函数，并返回执行的结果到TS")
          .width('100%')
          .onClick(() => {
            console.info(`Num is  ${demo.add(3, 2)}`)
            console.info(`Test NAPI Result is ${testNapi.cal(2, 3, demo, true)}`)
          })

        Button("Node-api异步任务使用Promise方式")
          .width('100%')
          .onClick(() => {
            testNapi.asyncWork(3).then((result) => {
              hilog.info(0x0000, '异步任务', 'result is %{public}d', result);
            });
          })

        Button("Node-api异常捕获处理")
          .width('100%')
          .onClick(() => {
            try {
              hilog.info(0x0000, 'testTag', 'Test Node-API napi_get_last_error_info: %{public}s',
                testNapi.getLastErrorInfo('message'));
            } catch (error) {
              hilog.error(0x0000, 'testTag', 'Test Node-API napi_get_last_error_info error: %{public}s', error);
            }
          })

        Button("Native侧调用ArkTS侧的系统能力")
          .width('100%')
          .onClick(() => {
            try {
              hilog.info(0x0000, 'testTag', 'Test Node-API napi_get_last_error_info: %{public}s',
                testNapi.getSystemCap('message'));
            } catch (error) {
              hilog.error(0x0000, 'testTag', 'Test Node-API napi_get_last_error_info error: %{public}s', error);
            }
          })
        Button("使用JSVM引擎")
          .width('100%')
          .onClick(() => {
            const coreId: number = testNapi.createJsCore(MyCallback);
            testNapi.evaluateJS(coreId, jsCodeStr);
            testNapi.releaseJsCore(coreId);
            hilog.info(0x0000, 'testTag', 'Test NAPI 2 + 3 = %{public}d', testNapi.add(2, 3));
          })
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
