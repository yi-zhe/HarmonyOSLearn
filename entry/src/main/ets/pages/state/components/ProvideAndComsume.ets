import Title from './Title';


@Component
struct CompD {
  @Consume reviewVotes: number

  build() {
    Column() {
      Text(`reviewVotes(${this.reviewVotes})`)
      Button(`reviewVotes(${this.reviewVotes}), give + 1`)
        .onClick(() => this.reviewVotes += 1)
    }
    .width('50%')
  }
}

@Component
struct CompC {
  build() {
    Row({ space: 5 }) {
      CompD()
      CompD()
    }
  }
}

@Component
struct CompB {
  build() {
    CompC()
  }
}

@Component
export default struct ProvideAndConsume {
  @Provide reviewVotes: number = 0

  build() {
    ListItem() {
      Column() {
        Title({ title: 'Provide Consume双向同步' })
        Button(`reviewVotes(${this.reviewVotes}), give +1`)
          .onClick(() => this.reviewVotes += 1)
        CompB()
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding(5)
  }
}
