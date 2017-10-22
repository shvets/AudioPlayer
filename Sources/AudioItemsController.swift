#if os(iOS)

import UIKit

#endif

import PageLoader
import AVFoundation

open class AudioItemsController: UITableViewController {
  public static let SegueIdentifier = "Audio Items"
  public class var StoryboardControllerId: String { return "AudioItemsController" }

  open var CellIdentifier: String { return "AudioItemCell" }

  public let pageLoader = PageLoader()

  public var name: String?
  public var thumb: String?
  public var id: String?
  public var version: Int = 0

  public var items: [AudioItem] = []
  
#if os(iOS)

  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

  var loaded = false

  override open func viewDidLoad() {
    super.viewDidLoad()

    title = name

    tableView?.backgroundView = activityIndicatorView

    if let center = tableView?.center {
      activityIndicatorView.center = center
    }

    pageLoader.spinner = PlainSpinner(activityIndicatorView)

    pageLoader.loadData { result in
      if let items = result as? [AudioItem] {
        self.items = items
      }

      self.tableView?.reloadData()
    }
  }

  func navigateToSelectedRow() {
    if loaded {
      let currentTrackIndex = AudioPlayer.shared.currentTrackIndex

      if isSameBook() && currentTrackIndex != -1 {
        let indexPath = IndexPath(row: currentTrackIndex, section: 0)
        tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
      }
    }
  }
  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigateToSelectedRow()
  }

  func isSameBook() -> Bool {
    guard let id = id else {
      return false
    }

    return id == AudioPlayer.shared.currentBookId
  }

  func isSameTrack(_ row: Int) -> Bool {
    let currentTrackIndex = AudioPlayer.shared.currentTrackIndex

    return currentTrackIndex != -1 && row == currentTrackIndex
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

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioPlayerController.SegueIdentifier:
          if let destination = segue.destination as? AudioPlayerController {
            destination.parentName = name ?? ""
            destination.coverImageUrl = thumb ?? ""
            destination.items = items
            destination.selectedBookId = id ?? ""

            if let cell = sender as? UITableViewCell,
               let indexPath = tableView?.indexPath(for: cell) {
              destination.selectedItemId = indexPath.row
            }
          }

        default: break
      }
    }
  }
#endif

}
