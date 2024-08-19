import ProvideAndConsume from './components/ProvideAndComsume';

/**
 * @Provide和@Consume，应用于与后代组件的双向数据同步，应用于状态数据在多个层级之间传递的场景。
 * 不同于上文提到的父子组件之间通过命名参数机制传递，@Provide和@Consume摆脱参数传递机制的束缚，实现跨层级传递
 *
 * 其中@Provide装饰的变量是在祖先组件中，可以理解为被“提供”给后代的状态变量。@Consume装饰的变量是在后代组件中，
 * 去“消费（绑定）”祖先组件提供的变量
 *
 * 1. 概述
 *    a. @Provide装饰的状态变量自动对其所有后代组件可用，即该变量被“provide”给他的后代组件
 *    b. 后代通过使用@Consume去获取@Provide提供的变量，建立在@Provide和@Consume之间的双向数据同步
 *    c. @Provide和@Consume可以通过`相同的变量名`或者`相同的变量别名绑定`，建议类型相同，否则会发生类型隐式转换，从而导致应用行为异常
 *    d. @Provide装饰的变量和@Consume装饰的变量是一对多的关系。不允许在同一个自定义组件内，包括其子组件中声明多个同名或者同别名的@Provide装饰
 *       的变量，@Provide的属性名或别名需要唯一且确定，如果声明多个同名或者同别名的@Provide装饰的变量，会发生运行时报错
 * 2. 观察变化和行为表现
 *    当装饰的数据类型为boolean、string、number类型时，可以观察到数值的变化
 *    当装饰的数据类型为class或者Object的时候，可以观察到赋值和属性赋值的变化
 *    当装饰的对象是array的时候，可以观察到数组的添加、删除、更新数组单元
 *    当装饰的对象是Date时，可以观察到Date整体的赋值，同时可通过调用Date的接口更新Date的属性
 *    当装饰的变量是Map时，可以观察到Map整体的赋值，同时可通过调用Map的接口set, clear, delete 更新Map的值
 *    当装饰的变量是Set时，可以观察到Set整体的赋值，同时可通过调用Set的接口add, clear, delete 更新Set的值
 *
 * 3. 框架行为
 *    1. 初始渲染
 *       a. @Provide装饰的变量会以map的形式，传递给当前@Provide所属组件的所有子组件；
 *       b. 子组件中如果使用@Consume变量，则会在map中查找是否有该变量名/alias（别名）对应的@Provide的变量，如果查找不到，框架会抛出JS ERROR；
 *       c. 在初始化@Consume变量时，和@State/@Link的流程类似，@Consume变量会在map中查找到对应的@Provide变量进行保存，并把自己注册给@Provide
 *    2. 当@Provide装饰的数据变化时
 *       a. 过初始渲染的步骤可知，子组件@Consume已把自己注册给父组件。父组件@Provide变量变更后，会遍历更新所有依赖它的系统组件（elementid）和状态变量（@Consume）
 *       b. 通知@Consume更新后，子组件所有依赖@Consume的系统组件（elementId）都会被通知更新。以此实现@Provide对@Consume状态数据同步
 *    3. 当@Consume装饰的数据变化时
 *       通过初始渲染的步骤可知，子组件@Consume持有@Provide的实例。在@Consume更新后调用@Provide的更新方法，将更新的数值同步回@Provide，以此实现@Consume向@Provide的同步更新
 */
@Entry
@Component
export default struct ProvideConsumeManagement {
  build() {
    List({ space: 2 }) {
      ProvideAndConsume()
    }
    .divider({ strokeWidth: 2 })
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
    .padding(5)
  }
}
