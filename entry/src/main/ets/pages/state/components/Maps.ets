import Title from './Title';

/**
 * 5. Map可以观察到Map整体的赋值 set, clear, delete 更新Map的值
 */
@Component
export default struct Maps {
  @State message: Map<number, string> = new Map([[0, "a"], [1, "b"], [3, "c"]]);

  build() {
    ListItem() {
      Column() {
        Title({ title: '观察Map' })
        Text('init map')
          .onClick(() => {
            this.message = new Map([[0, "a"], [1, "b"], [3, "c"]]);
          })
        Text('set new one')
          .onClick(() => {
            this.message.set(4, "d");
          })
        Text('clear')
          .onClick(() => {
            this.message.clear();
          })
        Text('replace the first one')
          .onClick(() => {
            this.message.set(0, "aa");
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
    Array.from(this.message.keys()).forEach(key => {
      result += key + ':' + this.message.get(key) + ', '
    })
    return result
  }
}
