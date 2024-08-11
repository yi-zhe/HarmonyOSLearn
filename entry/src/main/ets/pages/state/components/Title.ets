@Component
export default struct Title {
  title: string = ''

  build() {
    Text(this.title)
      .width('100%')
      .fontWeight(FontWeight.Bold)
  }
}
