import Title from './Title';

class Book {
  public title: string
  public pages: number
  public readIt: boolean = false

  constructor(title: string, pages: number) {
    this.title = title
    this.pages = pages
  }
}

@Component
export default struct PropForClassType {
  @State book: Book = new Book('Secrets of C++', 765)

  build() {
    ListItem() {
      Column() {
        Title({ title: '父组件到子组件Class类型同步' })
        ReaderComp({ book: this.book })
        ReaderComp({ book: this.book })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}

@Component
struct ReaderComp {
  @Prop book: Book = new Book("", 0)

  build() {
    Row() {
      Text(this.book.title)
      Text(`/has ${this.book.pages} pages`)
      Text(`/${this.book.readIt ? 'I have read' : 'I have not read'}`)
        .onClick(() => {
          this.book.readIt = true
        })
    }
  }
}
