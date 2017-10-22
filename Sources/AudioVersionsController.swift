#if os(iOS)

import UIKit

#endif

import AVFoundation
import PageLoader

open class AudioVersionsController: UITableViewController {
  public static let SegueIdentifier = "Audio Versions"
  public class var StoryboardControllerId: String { return "AudioVersionsController" }

  open var CellIdentifier: String { return "AudioVersionCell" }

  public let pageLoader = PageLoader()

  public var name: String?
  public var thumb: String?
  public var id: String?
  public var items: [AudioItem] = []
  public var version: Int = 0

  public var audioItemsLoad: (() throws -> [Any]) = {
    return []
  }

#if os(iOS)

  public let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

  var loaded = false

  override open func viewDidLoad() {
    super.viewDidLoad()

    title = name

    if let tableView = tableView {
      tableView.backgroundView = activityIndicatorView
      activityIndicatorView.center = tableView.center
    }

    pageLoader.spinner = PlainSpinner(activityIndicatorView)

    pageLoader.loadData { result in
      if let items = result as? [AudioItem] {
        self.items = items
      }

      self.tableView?.reloadData()
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

    return cell
  }

  override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let location = tableView.cellForRow(at: indexPath) {
      navigate(from: location)
    }
  }

  open func navigate(from view: UITableViewCell) {
    performSegue(withIdentifier: AudioItemsController.SegueIdentifier, sender: view)
  }

  // MARK: Navigation

  override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let identifier = segue.identifier {
      switch identifier {
        case AudioItemsController.SegueIdentifier:
          if let destination = segue.destination as? AudioItemsController {
            destination.name = name
            destination.thumb = thumb
            destination.id = id

            if let cell = sender as? UITableViewCell,
               let indexPath = tableView?.indexPath(for: cell) {
              destination.version = indexPath.row
              version = indexPath.row
            }

            destination.pageLoader.pageSize = pageLoader.pageSize
            destination.pageLoader.rowSize = pageLoader.rowSize

            destination.pageLoader.load = audioItemsLoad
          }

        default: break
      }
    }
  }
#endif

}
