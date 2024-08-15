import Title from './Title';

let nextId: number = 1

/**
 * @Observed装饰的类的实例会被不透明的代理对象包装，此代理可以检测到包装对象内的所有属性更改
 */
@Observed
class Book {
  public id: number
  public title: string
  public pages: number
  public readIt: boolean = false

  constructor(title: string, pages: number) {
    this.id = nextId++
    this.title = title
    this.pages = pages
  }
}

@Component
export default struct PropForArrayType {
  @State allBooks: Book[] = [new Book("C#", 765), new Book("JS", 652), new Book("TS", 765)];

  build() {
    ListItem() {
      Column() {
        Title({ title: '父组件到子组件Array类型同步' })
        Text('library`s all time favorite')
        ReaderComp({ book: this.allBooks[2] })
        Divider()
        Text('Books on loan to a reader')
        ForEach(this.allBooks, (book: Book) => {
          ReaderComp({ book: book })
        }, (book: Book) => book.id.toString())

        Text('Add new')
          .onClick(() => {
            this.allBooks.push(new Book("JA", 512));
          })
        Text('Remove first book')
          .onClick(() => {
            if (this.allBooks.length > 0) {
              this.allBooks.shift();
            }
          })
        Text("Mark read for everyone")
          .onClick(() => {
            this.allBooks.forEach((book) => book.readIt = true)
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}

@Component
struct ReaderComp {
  @Prop book: Book = new Book("", 1)

  build() {
    Row() {
      Text(` ${this.book ? this.book.title : "Book is undefined"}`)
      Text(` has ${this.book ? this.book.pages : "Book is undefined"} pages!`)
      Text(` ${this.book ? this.book.readIt ? "I have read" : 'I have not read it' : "Book is undefined"}`)
        .onClick(() => this.book.readIt = true)
    }
  }
}
