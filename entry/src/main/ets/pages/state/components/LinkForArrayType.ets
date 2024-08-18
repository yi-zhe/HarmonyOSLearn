import Title from './Title';

@Component
struct Child {
  @Link items: number[]

  build() {
    Column() {
      Text('Text1: push')
        .onClick(() => {
          this.items.push(this.items.length + 1)
        })
      Text('Text2: replace whole item')
        .onClick(() => {
          this.items = [100, 200, 300];
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export default struct LinkForArrayType {
  @State arr: number[] = [1, 2, 3]

  build() {
    ListItem() {
      Column() {
        Title({ title: '数组类型的@Link' })
        Child({ items: this.arr })
        Row() {
          ForEach(this.arr, (item: number) => {
            Text(`${item} `)
          }, (item: ForEachInterface) => item.toString())
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}

