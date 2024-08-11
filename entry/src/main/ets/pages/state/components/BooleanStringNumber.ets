import Title from './Title'

/**
 * 1. 当装饰类型为boolean/string/number类型时, 可以观察到数值变化
 */
@Component
export default struct BooleanStringNumber {
  @State mixedVariable: boolean | string | number = 'null'

  build() {
    ListItem() {
      Column() {
        Title({ title: '观察boolean、string、number类型' })
        Row() {
          Button('boolean')
            .onClick(() => {
              this.mixedVariable = true
            })
          Button('string')
            .onClick(() => {
              this.mixedVariable = 'This is a string'
            })
          Button('number')
            .onClick(() => {
              this.mixedVariable = 5
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)

        Text(this.mixedVariable?.toString())
      }
    }
    .borderColor(Color.Gray)
    .borderWidth(1)
    .borderRadius(5)
    .padding(5)
  }
}
