import Title from './Title'

/**
 * 4. Date对象可以观察到整体的赋值/和一些setXXX方法
 */
@Component
export default struct Dates {
  @State selectedDate: Date = new Date('2021-08-08');

  build() {
    ListItem() {
      Column() {
        Title({ title: '观察Date' })
        Text('setFullYear')
          .onClick(() => {
            this.selectedDate.setFullYear(2022)
          })
        Text('setMonth')
          .onClick(() => {
            this.selectedDate.setMonth(11)
          })
        Text('setDate')
          .onClick(() => {
            this.selectedDate.setDate(1)
          })
        Text('setHours')
          .onClick(() => {
            this.selectedDate.setHours(11)
          })
        Text('setMinutes')
          .onClick(() => {
            this.selectedDate.setMinutes(20)
          })
        Text('setSeconds')
          .onClick(() => {
            this.selectedDate.setSeconds(15)
          })
        Text('setMilliseconds')
          .onClick(() => {
            this.selectedDate.setMilliseconds(100)
          })
        Text('setTime')
          .onClick(() => {
            this.selectedDate.setTime(10)
          })
        Text('setUTCFullYear')
          .onClick(() => {
            this.selectedDate.setUTCFullYear(2022)
          })
        Text('setUTCMonth')
          .onClick(() => {
            this.selectedDate.setUTCMonth(10)
          })
        Text('setUTCDate')
          .onClick(() => {
            this.selectedDate.setUTCDate(15)
          })
        Text('setUTCHours')
          .onClick(() => {
            this.selectedDate.setUTCHours(9)
          })
        Text('setUTCMinutes')
          .onClick(() => {
            this.selectedDate.setUTCMinutes(40)
          })
        Text('setUTCSeconds')
          .onClick(() => {
            this.selectedDate.setUTCSeconds(30)
          })
        Text('setUTCMilliseconds')
          .onClick(() => {
            this.selectedDate.setUTCMilliseconds(200)
          })

        Text(this.selectedDate.toString())
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding(5)
  }
}

class Model {
  public value: number

  constructor(value: number) {
    this.value = value
  }

  toString(): string {
    return this.value.toString()
  }
}
