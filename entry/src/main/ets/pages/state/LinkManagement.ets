import PropForSimpleDataType from './components/PropForSimpleDataType';
import PropArrays from './components/PropArrays';
import Props from './components/Props';
import PropForArrayOfSimpleDataType from './components/PropForArrayOfSimpleDataType';
import PropForClassType from './components/PropForClassType';
import PropForArrayType from './components/PropForArrayType';
import LinkForSimpleDataTypeAndClass from './components/LinkForSimpleDataTypeAndClass';

/**
 * 概述
 * @Link装饰的变量与其父组件中的数据源共享相同的值
 *
 * 限制
 * @Link装饰器不能在@Entry装饰的自定义组件中使用
 *
 * 父组件中@State, @StorageLink和@Link 和子组件@Link可以建立双向数据同步
 *
 * 框架行为
 * @Link装饰的变量和其所属的自定义组件共享生命周期
 * 1. 初始渲染：执行父组件的build()函数后将创建子组件的新实例
 *    必须指定父组件中的@State变量，用于初始化子组件的@Link变量。子组件的@Link变量值与其父组件的数据源变量保持同步
 *    父组件的@State状态变量包装类通过构造函数传给子组件，子组件的@Link包装类拿到父组件的@State的状态变量后，将当前@Link包装类this指针注册给父组件的@State变量
 * 2. @Link的数据源的更新：即父组件中状态变量更新，引起相关子组件的@Link的更新
 *    通过初始渲染的步骤可知，子组件@Link包装类把当前this指针注册给父组件。父组件@State变量变更后，会遍历更新所有依赖它的系统组件（elementid）和状态变量
 *    通知@Link包装类更新后，子组件中所有依赖@Link状态变量的系统组件（elementId）都会被通知更新。以此实现父组件对子组件的状态数据同步
 * 3. @Link的更新：当子组件中@Link更新后，处理步骤如下
 *    @Link更新后，调用父组件的@State包装类的set方法，将更新后的数值同步回父组件
 *    子组件@Link和父组件@State分别遍历依赖的系统组件，进行对应的UI的更新。以此实现子组件@Link同步回父组件@State *
 */
@Entry
@Component
export default struct LinkManagement {
  build() {
    List({ space: 2 }) {
      LinkForSimpleDataTypeAndClass()
    }
    .divider({ strokeWidth: 2 })
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
    .padding(5)
  }
}
