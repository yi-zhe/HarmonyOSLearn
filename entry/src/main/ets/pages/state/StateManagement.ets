import BooleanStringNumber from './components/BooleanStringNumber'
import ClassObject from './components/ClassObject'

@Entry
@Component
struct StateManagement {
  /**
   * @State装饰器 是私有的, 只能从组件内部访问, 声明时必须指定类型
   * 初始化:
   *   1. 本地初始化 或 使用命名参数机制从父组件完成初始化
   * 特点:
   *   1. 与子组件中的@Prop建立单向数据同步
   *   2. 与@Link/@ObjectLink装饰变量之间建立双向数据同步
   *   3. 生命周期与其所属的自定义组件的生命周期相同
   * 传递和访问规则:
   *   1. 从父组件初始化将覆盖本地初始化
   *   2. @State装饰的变量支持初始化子组件的常规变量/@State/@Link/@Prop/@Provide装饰的变量
   *
   * 观察变化:
   *   1. 当装饰类型为boolean/string/number类型时, 可以观察到数值变化
   *   2. 当装饰的数据类型为class或Object时, 可以观察到自身的赋值变化和其属性赋值的变化,
   *      但不能观察到其嵌套属性的赋值
   *   3. 当装饰的对象是array时, 可以观察到数组本身的赋值/添加/删除/更新数组的变化
   *      但不能观察到数组项中属性的赋值
   *   4. Date对象可以观察到整体的赋值/和一些setXXX方法
   *   5. Map可以观察到Map整体的赋值 set, clear, delete 更新Map的值
   *   6. Set可以观察到Set整体的赋值 add, clear, delete 更新Set的值
   *
   * 框架行为:
   *   1. 当状态变量被改变时,查询依赖该状态变量的组件
   *   2. 执行依赖该状态变量的组件的更新方法,组件更新渲染
   *   3. 和该状态变量不相关的组件或者UI描述不会发生重新渲染,从而实现页面渲染的按需更新
   *
   * State支持联合类型
   *   1. @State count: number | undefined = 0
   *
   * 常见问题
   *   1. 使用箭头函数改变状态变量不生效
   *      箭头函数内的this对象是定义函数时所在作用域指向的对象, 而不是使用时所在的作用域指向的对象
   *   2. 状态变量的修改放在构造函数内不生效
   *      状态管理中, 类会被一层代理进行包装. 当在组件中改变该类的成员变量时,会被该代理进行拦截,
   *      在更改数据源中值的同时, 也会将变化通知给绑定的组件. 当开发者把修改success的箭头函数放在构造函数中初始化时
   *      此时this指向原本TestModel, 还未被代理封装, 所以后续触发query事件无法响应变化
   *   3. 状态变量只能影响其直接绑定的UI组件的刷新
   */
  @State stateInComponent: string = ''

  build() {
    List({ space: 2 }) {
      BooleanStringNumber()
      ClassObject()
    }
    .divider({ strokeWidth: 2 })
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
    .padding(5)
  }
}
