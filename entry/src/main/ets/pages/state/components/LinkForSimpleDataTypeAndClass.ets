import Title from './Title';

class GreenButtonState {
  width: number = 0

  constructor(width: number) {
    this.width = width
  }
}

@Component
struct GreenButton {
  @Link greenButtonState: GreenButtonState

  build() {
    Button('Green Button')
      .width(this.greenButtonState.width)
      .backgroundColor('#64bb5c')
      .height(40)
      .onClick(() => {
        if (this.greenButtonState.width < 700) {
          this.greenButtonState.width += 60
        } else {
          this.greenButtonState = new GreenButtonState(180);
        }
      })
  }
}

@Component
struct YellowButton {
  @Link yellowButtonState: number

  build() {
    Button('Yellow Button')
      .width(this.yellowButtonState)
      .backgroundColor('#f7ce00')
      .height(40)
      .onClick(() => {
        this.yellowButtonState += 40
      })
  }
}

@Component
export default struct LinkForSimpleDataTypeAndClass {
  @State greenButtonState: GreenButtonState = new GreenButtonState(180);
  @State yellowButtonProp: number = 180;

  build() {
    ListItem() {
      Column() {
        Title({ title: '简单类型和类对象类型的@Link' })
        Button('Parent View: set YellowButton')
          .width(312)
          .height(40)
          .onClick(() => {
            this.yellowButtonProp = (this.yellowButtonProp < 500) ? this.yellowButtonProp + 40 : 100
          })
        Button('Parent View: set GreenButton')
          .width(312)
          .height(40)
          .onClick(() => {
            this.greenButtonState.width = (this.greenButtonState.width < 500) ? this.greenButtonState.width + 100 : 100
          })

        GreenButton({ greenButtonState: $greenButtonState })
        YellowButton({ yellowButtonState: $yellowButtonProp })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}

