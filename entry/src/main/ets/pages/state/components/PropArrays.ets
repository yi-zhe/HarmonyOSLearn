import Title from './Title'

/**
 * 3. 当装饰的对象是array时, 可以观察到数组本身的赋值/添加/删除/更新数组的变化
 *    但不能观察到数组项中属性的赋值
 */
@Component
export default struct PropArrays {
  @Prop titles: Model[] = [new Model(11), new Model(1)]

  build() {
    ListItem() {
      Column() {
        Title({ title: '观察Array' })
        Text('观察@Prop数组变量的赋值')
          .onClick(() => {
            this.titles = [new Model(2)]
          })
        Text('观察@Prop数组中某项的赋值')
          .onClick(() => {
            this.titles[0] = new Model(3)
          })
        Text('观察@Prop数组中删除')
          .onClick(() => {
            this.titles.pop()
          })
        Text('观察@Prop数组中新增')
          .onClick(() => {
            this.titles.push(new Model(4))
          })
        Text('观察@Prop数组中某项的属性赋值-失效')
          .onClick(() => {
            this.titles[0].value = 6
          })

        Text(this.titles.toString())
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
