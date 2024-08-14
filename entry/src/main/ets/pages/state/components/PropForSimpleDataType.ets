import Title from './Title';

@Component
export default struct PropForSimpleDataType {
  @State countDownStartValue: number = 10

  build() {
    ListItem() {
      Column() {
        Title({ title: '父组件到子组件简单数据类型同步' })
        Text(`Grant ${this.countDownStartValue} nuggets to play.`)
        // 父组件对数据源的修改会同步给子组件
        Text(`+1 - Nuggets in New Game`).onClick(() => {
          this.countDownStartValue += 1
        })
        Text(`-1 - Nuggets in New Game`).onClick(() => {
          this.countDownStartValue -= 1
        })

        CountDownComponent({ count: this.countDownStartValue, costOfOneAttempt: 2 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}

@Component
struct CountDownComponent {
  @Prop count: number = 0
  costOfOneAttempt: number = 1

  build() {
    Column() {
      if (this.count > 0) {
        Text(`You have ${this.count} Nuggets left`)
      } else {
        Text(`Game over`)
      }

      Text(`Try again`).onClick(() => {
        // 子组件的修改不会同步回父组件
        this.count -= this.costOfOneAttempt
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
