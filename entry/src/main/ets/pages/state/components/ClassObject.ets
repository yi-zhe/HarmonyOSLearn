import Title from './Title'

/**
 * 2. 当装饰的数据类型为class或Object时, 可以观察到自身的赋值变化和其属性赋值的变化,
 *    但不能观察到其嵌套属性的赋值
 */
@Component
export default struct ClassObject {
  @State title: Model = new Model('Hello', new ClassA('World'))

  build() {
    ListItem() {
      Column() {
        Title({ title: '观察class或Object' })
        Text('观察@State变量的属性')
          .onClick(() => {
            this.title.value = 'Hi'
          })

        Text('观察@State变量的嵌套属性-失效')
          .onClick(() => {
            this.title.name.value = 'ArkUI'
          })

        Text(this.title.toString())
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding(5)
  }
}

class ClassA {
  public value: string

  constructor(value: string) {
    this.value = value
  }

  toString(): string {
    return this.value
  }
}

class Model {
  public value: string
  public name: ClassA

  constructor(value: string, a: ClassA) {
    this.value = value
    this.name = a
  }

  toString(): string {
    return this.value + ' ' + this.name.toString()
  }
}
