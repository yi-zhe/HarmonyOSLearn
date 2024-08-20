import ViewB from './components/ObservedClassType';

/**
 * @ObjectLink和@Observed类装饰器用于在涉及嵌套对象或数组的场景中进行双向数据同步
 * a. 被@Observed装饰的类，可以被观察到属性的变化
 * b. 子组件中@ObjectLink装饰器装饰的状态变量用于接收@Observed装饰的类的实例，和父组件中对应的状态变量建立双向数据绑定
 *    这个实例可以是数组中的被@Observed装饰的项，或者是class object中的属性，这个属性同样也需要被@Observed装饰
 * c. @Observed用于嵌套类场景中，观察对象类属性变化，要配合自定义组件使用（示例详见嵌套对象），
 *    如果要做数据双/单向同步，需要搭配@ObjectLink或者@Prop使用
 *
 * 限制条件
 * a. 使用@Observed装饰class会改变class原始的原型链，@Observed和其他类装饰器装饰同一个class可能会带来问题
 * b. @ObjectLink装饰器不能在@Entry装饰的自定义组件中使用
 *
 * 观察变化和行为表现
 * a. @Observed装饰的类，如果其属性为非简单类型，比如class、Object或者数组，也需要被@Observed装饰，否则将观察不到其属性的变化
 *
 * 框架行为
 * a. 初始渲染
 *    1. @Observed装饰的class的实例会被不透明的代理对象包装，代理了class上的属性的setter和getter方法
 *    2. 子组件中@ObjectLink装饰的从父组件初始化，接收被@Observed装饰的class的实例，@ObjectLink的包装类会将自己注册给@Observed class
 * b. 属性更新：当@Observed装饰的class属性改变时，会走到代理的setter和getter，然后遍历依赖它的@ObjectLink包装类，通知数据更新
 *
 */
@Entry
@Component
export default struct ObservedObjectLinkManagement {
  build() {
    List({ space: 2 }) {
      ViewB()
    }
    .divider({ strokeWidth: 2 })
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
    .padding(5)
  }
}
