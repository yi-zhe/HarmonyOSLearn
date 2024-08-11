import Title from './Title';

/**
 * 6. Set可以观察到Set整体的赋值 add, clear, delete 更新Set的值
 */
@Component
export default struct Sets {
  @State message: Set<number> = new Set([0, 1, 2, 3, 4]);

  build() {
    ListItem() {
      Column() {
        Title({ title: '观察Set' })
        Text('init set')
          .onClick(() => {
            this.message = new Set([0, 1, 2, 3, 4]);
          })
        Text('set new one')
          .onClick(() => {
            this.message.add(5);
          })
        Text('clear')
          .onClick(() => {
            this.message.clear();
          })
        Text('delete the first one')
          .onClick(() => {
            this.message.delete(0);
          })

        Text(this.display())
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding(5)
  }

  display() {
    let result = ''
    Array.from(this.message.values()).forEach(value => {
      result += value + ', '
    })
    return result
  }
}
