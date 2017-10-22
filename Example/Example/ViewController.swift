import UIKit
import AudioPlayer
import WebAPI

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func play(_ sender: UIButton) {
    performSegue(withIdentifier: "Play", sender: sender)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if let destination = segue.destination as? AudioPlayerController {
      do {
        let api = AudioKnigiAPI()

        let authors = try api.getAuthors()["movies"] as! [Any]

        let author = authors.filter { item in
          if let item = item as? [String: String] {
            return item["name"] == "Мартин Джордж"
          }
          else {
            return false
          }
        }.first
        
        if let author = author as? [String: String] {
          let books = try api.getBooks(path: author["id"]!)["movies"] as! [Any]
          
          if let book = books[1] as? [String: String] {
            let items = try api.getAudioTracks(book["id"]!)
            
            destination.coverImageUrl = book["thumb"]
            destination.parentName = book["name"]
            destination.selectedBookId = book["id"]
            destination.selectedItemId = 0
            
            destination.items = []
            
            for item in items {
              destination.items.append(AudioItem(name: item.title, id: item.url))
            }
          }
        }
      }
      catch let error {
        print("Errpr: \(error)")
      }
    }
  }
  
}

