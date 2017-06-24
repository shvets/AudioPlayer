import Foundation
import SwiftyJSON

open class JsonConverter {
  
  public static func toItems(_ contents: Data) -> [String: Any] {
    var result = [String: Any]()
    
    let json = JSON(data: contents)
    
    for (key, value) in json {
      if value.type == .dictionary {
        result[key] = convertToDictionary(value)
      }
      else if value.type == .array {
        result[key] = convertToArray(value)
      }
      else {
        result[key] = value.rawString()
      }
    }
    
    return result
  }

  static func convertToDictionary(_ json: JSON) -> [String: Any] {
    var dict = [String: Any]()

    if let table = json.dictionaryObject {
      for (key, value) in table {
        if value as? [String: Any] != nil {
          dict[key] = value as! [String: Any]
        }
        else if value as? [Any] != nil {
          dict[key] = value as! [Any]
        }
        else {
          dict[key] = (value as! String).description
        }
      }
    }

    return dict
  }

  static func convertToArray(_ json: JSON) -> [Any] {
    var array = [Any]()

    if let ao = json.arrayObject {
      for value in ao {
        if value as? [String: Any] != nil {
          array.append(value)
        }
        else if value as? [Any] != nil {
          array.append(value)
        }
        else {
          array.append((value as! String).description)
        }
      }
    }

    return array
  }

  public static func toData(_ items: [String: Any]) -> Data {
    var content = Data()
    
    do {
      content = try JSONSerialization.data(withJSONObject: items, options: .prettyPrinted)
    }
    catch {
      print("Error")
    }
    
    return content
  }

  public static func prettified(_ items: [String: Any]) -> String {
    if let text = String(data: toData(items), encoding: String.Encoding.utf8) {
      return text.replacingOccurrences(of: "\\/", with: "/")
    }
    else {
      return ""
    }
  }

  public static func prettified(_ json: JSON) -> String {
    if let text = json.rawString(options: .prettyPrinted) {
      return text.replacingOccurrences(of: "\\/", with: "/")
    }
    else {
      return ""
    }
  }

  public static func prettified(_ any: Any?) -> String {
    if let any = any,
       let text = JSON(any).rawString(options: .prettyPrinted) {
      return text.replacingOccurrences(of: "\\/", with: "/")
    }
    else {
      return ""
    }
  }
}
