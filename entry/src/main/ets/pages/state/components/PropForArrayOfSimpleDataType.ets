import Title from './Title';

@Component
export default struct PropForArrayOfSimpleDataType {
  @State arr: number[] = [1, 2, 3]

  build() {
    ListItem() {
      Column() {
        Title({ title: '父组件到子组件简单数据类型的数组同步' })
        Row() {
          Child({ value: this.arr[0] })
          Child({ value: this.arr[1] })
          Child({ value: this.arr[2] })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)

        Divider().height(5)
        Row() {
          ForEach(this.arr, (item: number) => {
            Child({ value: item })
          }, (item: string) => item.toString())
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)

        Text('replace entire arr')
          .onClick(() => {
            // 数据中都有3 所以在ForEach中3这个组件不会重新创建而是复用
            this.arr = this.arr[0] == 1 ? [3, 4, 5] : [1, 2, 3]
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}

@Component
struct Child {
  @Prop value: number = 0

  build() {
    Column() {
      Text(`${this.value}`)
        .onClick(() => {
          this.value++
        })
    }
    .alignItems(HorizontalAlign.Start)
  }
}
