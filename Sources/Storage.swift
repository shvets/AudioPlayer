//import Unbox
//import Wrap
//
//public struct StorageProperty: Unboxable {
//  let value: String
//
//  public init(value: String) throws {
//    self.value = value
//  }
//
//  public init(unboxer: Unboxer) throws {
//    self.value = try unboxer.unbox(key: "value")
//  }
//}

open class Storage {
  public var items: [String: Any] = [:]

  public func clear() {
    items.removeAll()
  }

  public func exist() -> Bool {
    return true
  }

  public func add(key: String, value: Any) {
    items[key] = value
  }

  public func remove(_ key: String) -> Bool {
    return items.removeValue(forKey: key) != nil
  }

  public func load() throws {
    clear()
    
    if exist() {
      items = try loadStorage()
    }
  }

  public func save() throws {
    try saveStorage(self.items)
  }

  func loadStorage() throws -> [String: Any] {
    return [:]
  }

  func saveStorage(_ items: [String: Any]) throws {}
  
}
