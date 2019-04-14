#if os(iOS)

import UIKit
import MediaPlayer

#endif

import AVFoundation

open class AudioPlayerController: UIViewController, AudioPlayerUI {
  public static let SegueIdentifier = "Audio Player"

  public var parentName: String!
  public var coverImageUrl: String!
  public var items: [AudioItem]!
  public var selectedBookId: String!
  public var selectedBookName: String!
  public var selectedBookThumb: String!
  public var selectedItemId: Int!

#if os(iOS)

  var audioPlayer: AudioPlayer!

  @IBOutlet fileprivate weak var poster: UIImageView!
  @IBOutlet fileprivate weak var playbackSlider: UISlider!
  @IBOutlet fileprivate weak var playPauseButton: UIButton!
  @IBOutlet fileprivate weak var replayButton: UIButton!
  @IBOutlet fileprivate weak var stopButton: UIButton!
  @IBOutlet fileprivate weak var currentTimeLabel: UILabel!
  @IBOutlet fileprivate weak var durationLabel: UILabel!
  @IBOutlet fileprivate weak var volumeSlider: UISlider!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var indicator: UIActivityIndicatorView!

  override open func viewDidLoad() {
    super.viewDidLoad()

    title = parentName

    playbackSlider.tintColor = UIColor.green
    playbackSlider.setThumbImage(UIImage(named: "sliderThumb"), for: UIControl.State())

    audioPlayer.ui = self

    audioPlayer.setCoverImage(urlPath: coverImageUrl)
  
    poster.image = audioPlayer.coverImage
  
    audioPlayer.authorName = getAuthorName(parentName)
    audioPlayer.bookName = getBookName(parentName)

    audioPlayer.items = items
    audioPlayer.selectedBookId = selectedBookId
    audioPlayer.selectedBookName = selectedBookName
    audioPlayer.selectedBookThumb = selectedBookThumb
    audioPlayer.selectedItemId = selectedItemId

    audioPlayer.setupPlayer()
  }

  override open func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    audioPlayer.save()
  }

//  override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//    return UIInterfaceOrientationMask.portrait
//  }
//
//  override open var shouldAutorotate: Bool {
//    return false
//  }
  
  @IBAction func volumeSliderValueChanged() {
    audioPlayer.changeVolume(volumeSlider.value)
  }

  @IBAction func playbackSliderValueChanged(_ sender: UISlider) {
    //if audioPlayer.player.timeControlStatus == .playing {
      audioPlayer.pause()
      audioPlayer.changePlayerPosition(value: getPlayerValue())
      audioPlayer.play()
//    }
//    else {
//      audioPlayer.changePlayerPosition(value: getPlayerValue())
//    }
  }

  @IBAction func prevAction() {
    audioPlayer.playPrevious()
  }

  @IBAction func nextAction() {
    audioPlayer.playNext()
  }

  @IBAction func playPauseAction(_ sender: AnyObject) {
    audioPlayer.togglePlayPause()
  }

  @IBAction func replayAction() {
    audioPlayer.replay()
  }

  @IBAction func stopAction(_ sender: UIButton) {
    audioPlayer.stop()
  }

  @IBAction func skipBackward(_ sender: UIButton) {
    audioPlayer.skipBackward(getPlayerValue())
  }

  @IBAction func skipForward(_ sender: UIButton) {
    audioPlayer.skipForward(getPlayerValue())
  }

  private func getAuthorName(_ name: String) -> String {
    if let index = name.range(of: "-")?.lowerBound {
      return String(name[name.startIndex ..< name.index(index, offsetBy: -1)])
    }
    else {
      return ""
    }
  }

  private func getBookName(_ name: String) -> String {
    if let index = name.range(of: "-")?.lowerBound {
      return name[name.index(index, offsetBy: 1) ..< name.endIndex].trimmingCharacters(in: .whitespaces)
    }
    else {
      return ""
    }
  }

#endif

}

extension AudioPlayerController {

#if os(iOS)

  // MARK: AudioPlayerUI

  public func startAnimate() {
    UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
      self.indicator.alpha = 1
      self.playPauseButton.alpha = 0
      self.playPauseButton.isEnabled = false
    })
  }

  public func stopAnimate() {
    UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
      self.indicator.alpha = 0
      self.playPauseButton.alpha = 1
      self.playPauseButton.isEnabled = true
    })
  }

  public func update() {
    if let playerItem = audioPlayer.player.currentItem {
      let currentTime = playerItem.currentTime().seconds
      let duration = playerItem.asset.duration.seconds

      playbackSlider.value =  Float(currentTime / duration)

      let leftTime = duration - currentTime

      let sign = (leftTime == 0) ? "" : "-"

      durationLabel.text = "\(sign)\(formatTime(duration-currentTime))"
      currentTimeLabel.text = formatTime(currentTime)
    }
    else {
      playbackSlider.value = 0
      durationLabel.text = "00:00"
      currentTimeLabel.text = "00:00"
    }
  }

  public func displayPlay() {
    playPauseButton.setImage(UIImage(named: "Play"), for: .normal)
  }

  public func displayPause() {
    playPauseButton.setImage(UIImage(named: "Pause"), for: .normal)
  }

  public func updateTitle(_ title: String?) {
    if let title = title {
      titleLabel.text = title
    }
  }

  public func getPlayerValue() -> Float {
    return playbackSlider.value
  }

  public func playbackProgressDidChange(duration: Double, currentTime: Double) {
    currentTimeLabel.text = formatTime(currentTime)

    let leftTime = duration - currentTime

    let sign = (leftTime == 0) ? "" : "-"

    durationLabel.text = "\(sign)\(formatTime(leftTime))"

    playbackSlider.value = Float(currentTime / duration)
  }

  private func formatTime(_ time: Double) -> String {
    let (hours, minutes, seconds) = timeToHoursMinutesSeconds(time: Int(time))
    
    if hours > 0 {
      return String(format: "%i:%02i:%02i", hours, minutes, seconds)
    }
    else {
      return String(format: "%02i:%02i", minutes, seconds)
    }
  }
  
  func timeToHoursMinutesSeconds (time: Int) -> (Int, Int, Int) {
    return (time / 3600, (time % 3600) / 60, (time % 3600) % 60)
  }


#endif

}
