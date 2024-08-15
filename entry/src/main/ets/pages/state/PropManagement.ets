import PropForSimpleDataType from './components/PropForSimpleDataType';
import PropArrays from './components/PropArrays';
import Props from './components/Props';
import PropForArrayOfSimpleDataType from './components/PropForArrayOfSimpleDataType';

/**
 * 概述
 * 1. @Prop装饰的变量可以和父组件建立单向同步关系
 * 2. @Prop变量允许在本地修改, 但修改后的变化不会同步回父组件
 *
 * 限制条件
 * 1. @Prop装饰变量时会深拷贝, 拷贝过程中除了基本类型、Map、Set、Date、Array外
 *    其他类型都会丢失
 * 2. @Prop装饰器不能在@Entry装饰的自定义组件中使用
 *
 * 装饰器使用规则
 * 1. 单向同步
 * 2. 允许装饰的类型Object/class/string/number/boolean/enum/Map/Set及其数组, 支持联合类型
 * 3. 支持联合类型 Length/ResourceStr/ResourceColor
 * 4. 嵌套传递层数 不要超过5层
 * 5. 被装饰变量的初始值 允许本地初始化, 如果与@Require结合使用, 则要求父组件传参
 *
 * 变量的传递/访问规则
 * 1. 从父组件初始化: 若本地有初始化, 则是可选的, 否则是必选的
 * 2. 初始化子组件: @Prop支持去初始化子组件中的常规变量、@State、@Link、@Prop、@Provide
 * 3. 不支持组件外访问
 */
@Entry
@Component
export default struct PropManagement {
  build() {
    List({ space: 2 }) {
      Props()
      PropArrays()
      PropForSimpleDataType()
      PropForArrayOfSimpleDataType()
    }
    .divider({ strokeWidth: 2 })
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
    .padding(5)
  }
}
