public protocol AudioPlayerUI: class {
#if os(iOS)
  func startAnimate()

  func stopAnimate()

  func update()

  func displayPlay()

  func displayPause()

  func updateTitle(_ title: String?)

  func getPlayerValue() -> Float

  func playbackProgressDidChange(duration: Double, currentTime: Double)

#endif
}
