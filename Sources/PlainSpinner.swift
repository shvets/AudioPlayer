import UIKit

open class PlainSpinner: Spinner {
  open var view: UIActivityIndicatorView

  public init(_ view: UIActivityIndicatorView) {
    self.view = view
  }

  open func start() {
    view.startAnimating()
  }

  open func stop() {
    view.stopAnimating()
  }
}
