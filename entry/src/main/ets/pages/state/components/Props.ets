import Title from './Title'

enum Type {
  type1,
  type2,
}

class ClassA {
  public value: string
  public model: Model

  constructor(value: string, model: Model) {
    this.value = value
    this.model = model
  }

  toString() {
    return 'ClassA: ' + this.value + ' ' + this.model.value
  }
}

export interface Obj {
  value: string
}

@Component
export default struct Props {
  @Prop mixedVariable: boolean | string | number | Type | ClassA | Object = 'null'

  build() {
    ListItem() {
      Column() {
        Title({ title: 'Prop支持观察的类型' })
        Text('boolean')
          .onClick(() => {
            this.mixedVariable = true
          })
        Text('string')
          .onClick(() => {
            this.mixedVariable = 'Hi Prop'
          })
        Text('number')
          .onClick(() => {
            this.mixedVariable = 6
          })
        Text('enum')
          .onClick(() => {
            this.mixedVariable = Type.type1
          })
        Text('class')
          .onClick(() => {
            this.mixedVariable = new ClassA('Hi', new Model(1))
          })
        Text('class 的第一层属性变化')
          .onClick(() => {
            this.mixedVariable = new ClassA('Hi2', new Model(2))
            setTimeout(() => {
              const a: ClassA = this.mixedVariable as ClassA
              a.value = 'New Value'
            }, 1000)
          })
        Text('class 的第二层属性变化-失效')
          .onClick(() => {
            this.mixedVariable = new ClassA('Hi2', new Model(2))
            setTimeout(() => {
              const a: ClassA = this.mixedVariable as ClassA
              a.model.value = 3
            }, 1000)
          })

        Text(this.mixedVariable.toString())
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
