import Title from './Title'

let NextId: number = 1

@Observed
class Bag {
  public id: number
  public size: number

  constructor(size: number) {
    this.id = NextId++
    this.size = size
  }
}

@Observed
class User {
  public bag: Bag

  constructor(bag: Bag) {
    this.bag = bag
  }
}

@Observed
class Book {
  public bookName: BookName

  constructor(bookName: BookName) {
    this.bookName = bookName
  }
}

@Observed
class BookName extends Bag {
  public nameSize: number

  constructor(nameSize: number) {
    super(nameSize)
    this.nameSize = nameSize
  }
}

@Component
struct ViewA {
  label: string = 'ViewA'
  @ObjectLink bag: Bag

  build() {
    Column() {
      Text(`ViewA [${this.label}] this.bag.size = ${this.bag.size}`)
      Text(`ViewA: this.bag.size add 1`)
        .onClick(() => {
          this.bag.size += 1
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct ViewC {
  label: string = 'ViewC1'
  @ObjectLink bookName: BookName

  build() {
    Column() {
      Text(`ViewC [${this.label}] this.bookName.size = ${this.bookName.size}`)
      Text(`ViewC: this.bookName.size add 1`)
        .onClick(() => {
          this.bookName.size += 1
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Entry
@Component
export default struct ViewB {
  @State user: User = new User(new Bag(0))
  @State child: Book = new Book(new BookName(0))

  build() {
    ListItem() {
      Column() {
        Title({ title: 'Observed ObjectLink 对象类型' })
        ViewA({ label: 'ViewA #1', bag: this.user.bag })
        ViewC({ label: 'ViewC #3', bookName: this.child.bookName })
        Text(`ViewB this.child.bookName.size add 10`)
          .onClick(() => {
            this.child.bookName.size += 10
          })
        Text(`ViewB this.user.bag = new Bag(10)`)
          .onClick(() => {
            this.user.bag = new Bag(10)
          })
        Text(`ViewB this.user = new User(new Bag(20))`)
          .onClick(() => {
            this.user = new User(new Bag(20))
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
