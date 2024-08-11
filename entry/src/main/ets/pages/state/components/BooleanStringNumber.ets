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
        Text('观察boolean')
          .onClick(() => {
            this.mixedVariable = true
          })
        Text('观察string')
          .onClick(() => {
            this.mixedVariable = 'This is a string'
          })
        Text('观察number')
          .onClick(() => {
            this.mixedVariable = 5
          })

        Text(this.mixedVariable?.toString())
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding(5)
  }
}
