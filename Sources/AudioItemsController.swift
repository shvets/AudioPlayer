#if os(iOS)

import UIKit

#endif

import PageLoader
import AVFoundation
import SimpleHttpClient

open class AudioItemsController: UITableViewController {
  public static let SegueIdentifier = "Audio Items"
  public static var StoryboardControllerId = "AudioItemsController"
  open var CellIdentifier: String { return "AudioItemCell" }

  public let pageLoader = PageLoader()

  public var selectedBookId: String!
  public var selectedBookName: String!
  public var selectedBookThumb: String!
  public var selectedItemId: Int!
  public var currentSongPosition: Float!

  public var version: Int = 0

  public var playerSettings: ConfigFile<String>!

  public var loadAudioItems: (() throws -> [Any])?

  public var items: [AudioItem] = []

  public var audioPlayer = AudioPlayer.player

  private var visited = false

#if os(iOS)

  public let activityIndicatorView = UIActivityIndicatorView(style: .gray)

  var loaded = false

  override open func viewDidLoad() {
    super.viewDidLoad()

    title = selectedBookName

    tableView?.backgroundView = activityIndicatorView

    if let center = tableView?.center {
      activityIndicatorView.center = center
    }

    pageLoader.spinner = PlainSpinner(activityIndicatorView)

    if let onLoad = loadAudioItems {
      pageLoader.loadData(onLoad: onLoad) { result in
        if let items = result as? [AudioItem] {
          self.items = items
        }

        self.tableView?.reloadData()
      }
    }
  }

  func navigateToSelectedRow() {
    if loaded {
      if let index = visited ? Int(playerSettings.items["selectedItemId"]!) : selectedItemId {
        let selectedItemId = Int(index)

        if isSameBook() && selectedItemId != -1 {
          let indexPath = IndexPath(row: selectedItemId, section: 0)
          tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
          tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
      }
    }
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigateToSelectedRow()
  }

  func isSameBook() -> Bool {
    guard let bookId = playerSettings.items["selectedBookId"] else {
      return false
    }

    return bookId == selectedBookId
  }

  func isSameTrack(_ itemId: Int) -> Bool {
    guard let selectedItemId = Int(playerSettings.items["selectedItemId"]!) else {
      return false
    }

    return selectedItemId != -1 && itemId == selectedItemId
  }

  override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if isSameBook() && isSameTrack(indexPath.row) {
      cell.setSelected(true, animated: true)
    }
    else if cell.isSelected {
      cell.setSelected(false, animated: true)
    }
  }

  // MARK: UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)

    let item = items[indexPath.row]

    cell.textLabel?.text = item.name

    cell.layer.masksToBounds = true
    cell.layer.borderWidth = 0.5
    cell.layer.borderColor = UIColor( red: 0, green: 0, blue:0, alpha: 1.0 ).cgColor

    if !loaded {
      loaded = true

      navigateToSelectedRow()
    }

    return cell
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let location = tableView.cellForRow(at: indexPath) {
      navigate(from: location)
    }
  }

  open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: AudioPlayerController.SegueIdentifier, sender: view)
  }

  // MARK: Navigation

  func isSameBook2() -> Bool {
    if let bookId = playerSettings.items["selectedBookId"] {
      return !bookId.isEmpty && bookId == selectedBookId
    }
    else {
      return false
    }
  }

  func isSameTrack2() -> Bool {
    if let itemId = playerSettings.items["selectedItemId"] {
      return !itemId.isEmpty && Int(itemId)! == selectedItemId
    }
    else {
      return false
    }
  }

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioPlayerController.SegueIdentifier:
          if let destination = segue.destination as? AudioPlayerController {
            destination.parentName = selectedBookName ?? ""
            destination.coverImageUrl = selectedBookThumb ?? ""
            destination.items = items
            destination.playerSettings = playerSettings

            if let cell = sender as? UITableViewCell,
               let indexPath = tableView?.indexPath(for: cell) {
              destination.selectedBookId = selectedBookId
              destination.selectedBookName = selectedBookName
              destination.selectedBookThumb = selectedBookThumb
              destination.selectedItemId = indexPath.row
              destination.currentSongPosition = currentSongPosition

              selectedItemId = indexPath.row

              AudioPlayer.saveSettings(playerSettings)

              audioPlayer.items = items

              let sameBook = isSameBook2()
              let sameTrack = isSameTrack2()

              let newPlayer = audioPlayer.selectedBookId != nil && audioPlayer.selectedItemId != -1 &&
                audioPlayer.selectedBookId != selectedBookId || audioPlayer.selectedItemId != selectedItemId

              audioPlayer.selectedBookId = selectedBookId
              audioPlayer.selectedBookName = selectedBookName
              audioPlayer.selectedBookThumb = selectedBookThumb
              audioPlayer.selectedItemId = selectedItemId
              audioPlayer.currentSongPosition = currentSongPosition ?? -1

              audioPlayer.playerSettings = playerSettings

              audioPlayer.setupPlayer(sameBook: sameBook, sameTrack: sameTrack, newPlayer: newPlayer)

              audioPlayer.save()

              visited = true
            }
          }

        default: break
      }
    }
  }
#endif

}
