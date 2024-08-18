import Title from './Title';

@Component
export default struct LinkForWatch {
  @State sourceNumber: number = 0

  build() {
    ListItem() {
      Column() {
        Title({ title: '@Watch监听变量变化' })
        Text(`父组件的sourceNumber:` + this.sourceNumber)
        Child({ sourceNumber: this.sourceNumber })
        Text(`父组件更改sourceNumber`)
          .onClick(() => {
            this.sourceNumber++
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}


@Component
struct Child {
  @State memberMessage: string = 'Hello World'
  @Link @Watch('onSourceChange') sourceNumber: number

  onSourceChange() {
    this.memberMessage = this.sourceNumber.toString()
  }

  build() {
    Column() {
      Text(this.memberMessage)
      Text(`子组件的sourceNumber:` + this.sourceNumber.toString())
      Text('子组件更改memberMessage')
        .onClick(() => {
          this.memberMessage = 'Hello memberMessage'
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
