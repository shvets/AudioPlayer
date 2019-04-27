import AVFoundation
import UIKit
import ConfigFile

#if os(iOS)

import MediaPlayer

#endif

open class AudioPlayer: NSObject {
//, AVAssetResourceLoaderDelegate {

#if os(iOS)
  public static var players: [AudioPlayer] = []

  public static func addPlayer(_ player: AudioPlayer) {
    players.append(player)
  }

  public static func getAudioPlayer(_ propertiesFileName: String) -> AudioPlayer {
    var player: AudioPlayer

    let players = AudioPlayer.players

    for player in players {
      if player.propertiesFileName != propertiesFileName &&
        player.player.timeControlStatus == .playing {
        player.pause()
      }
    }

    if let index = players.firstIndex(where: { $0.propertiesFileName == propertiesFileName }) {
      player = players[index]
    }
    else {
      player = AudioPlayer(propertiesFileName)

      AudioPlayer.addPlayer(player)
    }

    player.loadPlayer()

    return player
  }

  public enum Status: Int {
    case ready = 1
    case playing
    case paused
    case loading
  }

  let notificationCenter = NotificationCenter.default

  public var audioPlayerSettings: StringConfigFile?

  let audioSession = AVAudioSession.sharedInstance()

  var timeObserver: AnyObject?

  var currentAudioItem: AudioItem {
    return items[currentTrackIndex]
  }

  var player = AVPlayer()
  var status = Status.ready

  var savePlayerPositionTimer: Timer?
  var reconnectTimer: Timer?

  public var currentBookId: String = ""
  public var currentBookName: String = ""
  public var currentBookThumb: String = ""

  public var currentTrackIndex: Int = -1
  public var currentSongPosition: Float = -1
  public var items: [AudioItem] = []

  public var coverImage: UIImage?
  var authorName: String?
  var bookName: String?
  var selectedBookId: String?
  var selectedBookName: String?
  var selectedBookThumb: String?
  var selectedItemId: Int?

  weak var ui: AudioPlayerUI?

  var propertiesFileName: String!

  public init(_ propertiesFileName: String) {
    self.propertiesFileName = propertiesFileName

    let audioPlayerSettingsFileName = NSHomeDirectory() + "/Library/Caches/" + propertiesFileName

    audioPlayerSettings = StringConfigFile(audioPlayerSettingsFileName)

    UIApplication.shared.beginReceivingRemoteControlEvents() // begin receiving remote events

    do {
      try audioSession.setCategory(AVAudioSession.Category.playback)
      try audioSession.setMode(AVAudioSession.Mode.default)
      try audioSession.setActive(true)
    }
    catch {
      print("Cannot initialize audio session.")
    }

    super.init()

    handleRemoteCenter()

    DispatchQueue.main.async {
      self.savePlayerPositionTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
        self.save()
      }
    }
  }

  deinit {
    UIApplication.shared.endReceivingRemoteControlEvents()

    if let observer = timeObserver {
      player.removeTimeObserver(observer)
    }

    savePlayerPositionTimer?.invalidate()
  }

  func getNewPlayerItem() -> AVPlayerItem? {
    var playerItem: AVPlayerItem?

    if let path = items[currentTrackIndex].id.removingPercentEncoding {
      if let audioPath = getMediaUrl(path: path) {
        let asset = AVURLAsset(url: audioPath, options: nil)

        //asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)

        let duration = asset.duration.seconds

        if duration > 0 {
          playerItem = AVPlayerItem(asset: asset)
        }
      }
    }

    return playerItem
  }

  func setCoverImage(urlPath: String) {
    if let url = NSURL(string: urlPath),
       let data = NSData(contentsOf: url as URL) {
      coverImage = UIImage(data: data as Data)
    }
  }

  func seek(toSeconds seconds: Int) {
    player.seek(to: CMTimeMake(value: Int64(seconds), timescale: 1))
  }

  func changeVolume(_ volume: Float) {
    player.volume = volume
  }

  func getPlayerPosition(_ value: Float) -> Int {
    if let currentItem = player.currentItem {
      let duration = currentItem.asset.duration.seconds

      return Int(Double(value) * duration)
    }
    else {
      return 0
    }
  }

  func navigateToNextTrack() -> Bool {
    if currentTrackIndex < items.count-1 {
      currentTrackIndex = currentTrackIndex+1

      return true
    }

    return false
  }

  func navigateToPreviousTrack() -> Bool {
    if currentTrackIndex > 0 {
      currentTrackIndex = currentTrackIndex-1

      return true
    }

    return false
  }

  // MARK: Progress tracking

  func startProgressTimer() {
    if player.currentItem?.duration.isValid == true {
      let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10)

      timeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval,
        queue: DispatchQueue.main) { [unowned self] (_: CMTime) -> Void in

        self.playbackProgressDidChange()
      } as AnyObject
    }
  }

  func stopProgressTimer() {
    if let observer = timeObserver {
      player.removeTimeObserver(observer)

      timeObserver = nil
    }
  }

  // MARK: Background task

  var backgroundIdentifier = UIBackgroundTaskIdentifier.invalid

  func startBackgroundTask() {
    backgroundIdentifier = UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in
      UIApplication.shared.endBackgroundTask(self.backgroundIdentifier)
      self.backgroundIdentifier = UIBackgroundTaskIdentifier.invalid
    })
  }

  func stopBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundIdentifier)
    backgroundIdentifier = UIBackgroundTaskIdentifier.invalid
  }

  open func loadPlayer() {
    if let settings = audioPlayerSettings {
      do {
        try settings.load()
      }
      catch let error {
        print("Error loading config file: \(error)")
      }

      if let value = settings.items["currentBookId"] {
        currentBookId = value
      }

      if let value = settings.items["currentBookName"] {
        currentBookName = value
      }

      if let value = settings.items["currentBookThumb"] {
        currentBookThumb = value
      }

      if let value = settings.items["currentTrackIndex"] {
        currentTrackIndex = (value as AnyObject).integerValue
      }

      if let value = settings.items["currentSongPosition"] {
        currentSongPosition = (value as AnyObject).floatValue
      }
    }
  }

  func save() {
    if let settings = audioPlayerSettings {
      settings.add(key: "currentBookId", value: currentBookId)
      settings.add(key: "currentBookName", value: currentBookName)
      settings.add(key: "currentBookThumb", value: currentBookThumb)
      settings.add(key: "currentTrackIndex", value: String(currentTrackIndex))
      settings.add(key: "currentSongPosition", value: String(currentSongPosition))

      do {
        try settings.save()
      }
      catch let error {
        print("Error saving config file: \(error)")
      }
    }
  }

  private func getMediaUrl(path: String) -> URL? {
    var url: URL? = nil

    let link = path.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

    if let link = link {
      if !link.isEmpty {
        url = NSURL(string: link) as URL?
      }
    }

    return url
  }

#endif

}

extension AudioPlayer {

#if os(iOS)

  func setupPlayer() {
    let isAnotherBook = currentBookId != selectedBookId
    let isAnotherTrack = isAnotherBook || currentTrackIndex != selectedItemId
    let isNewPlayer = currentTrackIndex == -1 || isAnotherTrack

    if isAnotherBook {
      currentBookId = selectedBookId ?? ""
      currentBookName = selectedBookName ?? ""
      currentBookThumb = selectedBookThumb ?? ""
    }

    currentTrackIndex = selectedItemId ?? -1

    if isAnotherBook || isAnotherTrack {
      player.replaceCurrentItem(with: nil)

      currentTrackIndex = selectedItemId ?? -1
      currentSongPosition = -1
    }

    save()

    ui?.updateTitle(currentAudioItem.name)

    if player.timeControlStatus == .playing {
      status = .playing
    }

    if isNewPlayer || isAnotherBook || isAnotherTrack {
      stop()

      play()
    }
    else {
      ui?.update()

      print("init: \(status)")
      if status == .playing {
        ui?.startAnimate()
        ui?.stopAnimate()
        startProgressTimer()
        print("init: displayPause1")
        ui?.displayPause()
      }
      else if status == .ready {
        play(newPlayer: true, songPosition: currentSongPosition)
      }
      else if status == .paused {
        ui?.startAnimate()
        ui?.stopAnimate()
        startProgressTimer()
        print("init: displayPlay")
        ui?.displayPlay()
      }
      else {
        ui?.startAnimate()
        ui?.stopAnimate()
        startProgressTimer()
        print("init: displayPause2")
        ui?.displayPause()
      }
    }
  }

  func createNewPlayer(newPlayer: Bool=false, songPosition: Float=0) -> Bool {
    if newPlayer || player.currentItem == nil {
      if let playerItem = getNewPlayerItem() {

        player.replaceCurrentItem(with: playerItem)

        let asset = playerItem.asset

        ui?.startAnimate()

        status = AudioPlayer.Status.loading

        asset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: { () -> Void in
          DispatchQueue.main.async { [unowned self] in
            self.startBackgroundTask()
            self.updateNowPlayingInfoCenter()

            if let currentItem = self.player.currentItem {
              self.notificationCenter.addObserver(self, selector: #selector(self.handleAVPlayerItemDidPlayToEndTime),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)

              self.notificationCenter.addObserver(self, selector: #selector(self.handleAVPlayerItemPlaybackStalled),
                name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)

              self.notificationCenter.addObserver(self, selector: #selector(self.handleAVAudioSessionInterruption),
                                                  name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            }

            let seconds = self.getPlayerPosition(songPosition)

            self.seek(toSeconds: seconds)

            self.ui?.update()

            self.status = AudioPlayer.Status.ready

            self.ui?.stopAnimate()
          }
        })
      }
      else {
        return false
      }
    }

    return true
  }

  func play(newPlayer: Bool=false, songPosition: Float=0) {
    if createNewPlayer(newPlayer: newPlayer, songPosition: songPosition) {
      print("play")
      ui?.displayPlay()

      startProgressTimer()

      status = Status.playing
      player.play()

      ui?.displayPause()
    }
    else {
      print("Cannot build player")

      pause()

      let alert = UIAlertController(title: "Error", message: "Cannot build player", preferredStyle: .alert);

      let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        //let reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
          self.play()
        //}
      }

      alert.addAction(okAction)

      if let controller = getTopViewController() {
        controller.present(alert, animated: true)
      }
    }
  }

//  func createReconnectTimer() {
//    DispatchQueue.main.async {
//      self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
//        self.play()
//      }
//    }
//  }
//
//  func destroyReconnectTimer() {
//    reconnectTimer?.invalidate()
//
//    reconnectTimer = nil
//  }

  func getTopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return getTopViewController(controller: navigationController.visibleViewController)
    }

    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return getTopViewController(controller: selected)
      }
    }

    if let presented = controller?.presentedViewController {
      return getTopViewController(controller: presented)
    }

    return controller
  }

  func pause() {
    print("pause")
    ui?.displayPause()

    status = Status.paused
    player.pause()

    stopProgressTimer()

    ui?.displayPlay()
  }

  func togglePlayPause() {
    let status = player.timeControlStatus

    switch status {
      case .waitingToPlayAtSpecifiedRate:
        play()

      case .playing:
        pause()

      case .paused:
        play()

      @unknown default:
        fatalError()
    }
  }

  func replay() {
    ui?.update()

    pause()
    seek(toSeconds: 0)
    play()
  }

  func stop() {
    print("stop")

    pause()

    player.replaceCurrentItem(with: nil)

    stopBackgroundTask()

    status = Status.ready

    ui?.update()

    ui?.displayPlay()
  }

  func playNext() {
    if navigateToNextTrack() {
      stop()

      ui?.updateTitle(currentAudioItem.name)

      play(newPlayer: true)

      save()
    }
    else {
      replay()
    }
  }

  func playPrevious() {
    if navigateToPreviousTrack() {
      stop()

      ui?.updateTitle(currentAudioItem.name)

      play()

      save()
    }
    else {
      replay()
    }
  }

  func skipBackward(_ value: Float) {
    pause()

    let playerPosition = getPlayerPosition(value)

    seek(toSeconds: playerPosition - 15)

    play()
  }

  func skipForward(_ value: Float) {
    pause()

    let playerPosition = getPlayerPosition(value)

    seek(toSeconds: playerPosition + 15)

    play()
  }

  @objc func handleAVPlayerItemDidPlayToEndTime(notification: Notification) {
    if let currentItem = self.player.currentItem {
      notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentItem)
      notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
//      notificationCenter.removeObserver(self, name: NSNotification.Name.AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }

    save()

    if navigateToNextTrack() {
      stop()

      ui?.updateTitle(currentAudioItem.name)

      player.replaceCurrentItem(with: nil)

      play()
    }
    else {
      stop()
    }
  }

  @objc func handleAVPlayerItemPlaybackStalled() {
    pause()

    play()
  }

  @objc func handleAVAudioSessionInterruption(_ notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: AnyObject] else { return }

    guard let rawInterruptionType = userInfo[AVAudioSessionInterruptionTypeKey] as? NSNumber else { return }
    guard let interruptionType = AVAudioSession.InterruptionType(rawValue: rawInterruptionType.uintValue) else { return }

    switch interruptionType {
      case .began: //interruption started
        self.pause()

      case .ended: //interruption ended
        if let rawInterruptionOption = userInfo[AVAudioSessionInterruptionOptionKey] as? NSNumber {
          let interruptionOption = AVAudioSession.InterruptionOptions(rawValue: rawInterruptionOption.uintValue)
          if interruptionOption == AVAudioSession.InterruptionOptions.shouldResume {
            self.togglePlayPause()
          }
        }
      @unknown default:
        fatalError()
    }
  }

  func changePlayerPosition(value: Float) {
    let playerPosition = getPlayerPosition(value)

    seek(toSeconds: playerPosition)
  }

  // MARK: MPRemoteCommandCenter

  func handleRemoteCenter() {
    if #available(iOS 9.1, *) {
      let rcc = MPRemoteCommandCenter.shared()

      rcc.togglePlayPauseCommand.removeTarget(nil)
      rcc.playCommand.removeTarget(nil)
      rcc.pauseCommand.removeTarget(nil)

//      rcc.skipBackwardCommand.removeTarget(nil)
//      rcc.skipForwardCommand.removeTarget(nil)

      rcc.previousTrackCommand.removeTarget(nil)
      rcc.nextTrackCommand.removeTarget(nil)

      rcc.togglePlayPauseCommand.addTarget(self, action: #selector(self.doPlayPause))
      rcc.playCommand.addTarget(self, action:#selector(self.doPlayPause))
      rcc.pauseCommand.addTarget(self, action:#selector(self.doPlayPause))

//      rcc.skipBackwardCommand.addTarget(self, action:#selector(doSkipBackward))
//      rcc.skipForwardCommand.addTarget(self, action:#selector(doSkipForward))

      rcc.previousTrackCommand.addTarget(self, action:#selector(self.doPreviousTrack))
      rcc.nextTrackCommand.addTarget(self, action:#selector(self.doNextTrack))

      rcc.changePlaybackPositionCommand.addTarget(self, action:#selector(self.doPlaybackSliderValueChanged))

      //delay(1) { // we somehow get disabled after removing our player v.c.
      //rcc.togglePlayPauseCommand.isEnabled = true
      rcc.playCommand.isEnabled = true
      rcc.pauseCommand.isEnabled = true

//        rcc.skipBackwardCommand.isEnabled = true
//        rcc.skipForwardCommand.isEnabled = true

      rcc.previousTrackCommand.isEnabled = true
      rcc.nextTrackCommand.isEnabled = true
      //}
    }
  }

  func delay(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay

    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
  }

  @objc func doPlayPause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    togglePlayPause()

    return .success
  }

  func doPlay(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    togglePlayPause()

    return .success
  }
  func doPause(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    togglePlayPause()

    return .success
  }

  func doSkipBackward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    if let ui = ui {
      skipBackward(ui.getPlayerValue())
    }

    return .success
  }

  func doSkipForward(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    if let ui = ui {
      skipForward(ui.getPlayerValue())
    }

    return .success
  }

  @objc func doPreviousTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    playPrevious()

    return .success
  }

  @objc func doNextTrack(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    playNext()

    return .success
  }

  @objc func doPlaybackSliderValueChanged(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    if let playbackEvent = event as? MPChangePlaybackPositionCommandEvent {
      seek(toSeconds: Int(playbackEvent.positionTime))

      playbackProgressDidChange()
    }

    return .success
  }

  func playbackProgressDidChange() {
    if let playerItem = player.currentItem {
      let currentTime = playerItem.currentTime().seconds
      let duration = playerItem.asset.duration.seconds

      ui?.playbackProgressDidChange(duration: duration, currentTime: currentTime)

      updateNowPlayingInfoCenter()

      currentSongPosition = Float(currentTime / duration)
    }
  }

#endif

}

extension AudioPlayer {
  // MARK: MPNowPlayingInfoCenter

#if os(iOS)

  func updateNowPlayingInfoCenter() {
    if NSClassFromString("MPNowPlayingInfoCenter") != nil {
      let defaultNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

      if let currentItem = player.currentItem {
        let title = currentAudioItem.name
        let currentTime = currentItem.currentTime().seconds
        let duration = currentItem.asset.duration.seconds

        let trackNumber = currentTrackIndex
        let trackCount = items.count

        var nowPlayingInfo: [String: AnyObject] = [
          MPNowPlayingInfoPropertyPlaybackRate: 1.0 as AnyObject,
          MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime as AnyObject,
          MPMediaItemPropertyPlaybackDuration: duration as AnyObject,
          MPMediaItemPropertyTitle: title as AnyObject,
          MPNowPlayingInfoPropertyPlaybackQueueCount: trackCount as AnyObject,
          MPNowPlayingInfoPropertyPlaybackQueueIndex: trackNumber as AnyObject
        ]

        nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue as AnyObject

        // If is a live broadcast, you can set a newest property (iOS 10+): MPNowPlayingInfoPropertyIsLiveStream indicating that is a live broadcast
//        if #available(iOS 10.0, *) {
//          nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true as AnyObject
//        }

        if let authorName = authorName {
          nowPlayingInfo[MPMediaItemPropertyArtist] = authorName as AnyObject?
        }

        if let bookName = bookName {
          nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = bookName as AnyObject?
        }

        if let coverImage = coverImage {
          let artwork = MPMediaItemArtwork.init(boundsSize: coverImage.size, requestHandler: { (size) -> UIImage in
            return coverImage
          })

          nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        defaultNowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
      }
    }
  }

#endif

}
