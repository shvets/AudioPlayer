public protocol AudioPlayerUI: class {
  func startAnimate()

  func stopAnimate()

  func update()

  func displayPlay()

  func displayPause()

  func updateTitle(_ title: String?)

  func getPlayerValue() -> Float

  func playbackProgressDidChange(duration: Double, currentTime: Double)
}
