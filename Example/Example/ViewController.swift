import UIKit
import AudioPlayer
import MediaApis

class ViewController: UIViewController {
  static let audioPlayerPropertiesFileName1 = "audio-boo-player-settings.json"
  static let audioPlayerPropertiesFileName2 = "bookzvook-player-settings.json"

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func play1(_ sender: UIButton) {
    performSegue(withIdentifier: "Play", sender: sender)
  }
  
  @IBAction func play2(_ sender: UIButton) {
    performSegue(withIdentifier: "Play", sender: sender)
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
    if let destination = segue.destination as? AudioPlayerController {
      do {
        if let identifier = (sender as! UIButton).titleLabel!.text {
          switch identifier {
          case "Play1":
            let (book, items) = try getItems1()

            destination.coverImageUrl = book!["thumb"]
            destination.parentName = book!["name"]
            destination.selectedBookId = book!["id"]
            destination.selectedItemId = 0
            destination.audioPlayer.propertiesFileName = ViewController.audioPlayerPropertiesFileName1
            destination.audioPlayer.loadPlayer()
            
            destination.items = []

            for item in items! {
              destination.items.append(AudioItem(name: item.title, id: item.url!))
            }

          //          destination.loadAudioItems = AudioKnigiMediaItemsController.loadAudioItems(currentBookId, dataSource: dataSource)
          case "Play2":
            let (book, items) = try getItems2()

            destination.coverImageUrl = ""
            destination.parentName = book!["name"]
            destination.selectedBookId = book!["id"]
            destination.selectedItemId = 0
            destination.audioPlayer.propertiesFileName = ViewController.audioPlayerPropertiesFileName2
            destination.audioPlayer.loadPlayer()

            destination.items = []

            for item in items! {
              destination.items.append(AudioItem(name: item.title, id: item.url))
            }
          default:
            print("")
          }
        }
      }
      catch let error {
        print("Error: \(error)")
      }
    }
  }

  func getItems1() throws -> (AudioKnigiAPI.BookItem?, [AudioKnigiAPI.Track]?) {
    var book: AudioKnigiAPI.BookItem? = nil
    var items: [AudioKnigiAPI.Track]? = nil

    let api = AudioKnigiAPI()

    let authors = try api.getAuthors().items

    let author = authors.filter { item in
      return item["name"] == "Мартин Джордж"
      }.first
    
    if let author = author {
      let books = try api.getBooks(path: author["id"]!).items
      
      book = books[1]
      items = try api.getAudioTracks(book!["id"]!)
    }
    
    return (book, items)
  }

  func getItems2() throws -> (BookZvookAPI.BookItem?, [BookZvookAPI.BooTrack]?) {
    var book: BookZvookAPI.BookItem? = nil
    var items: [BookZvookAPI.BooTrack]? = nil

    let api = BookZvookAPI()

    let id = "http://bookzvuk.ru/avtor-na-bukvu-p/"

    let books = try api.getAuthorBooks(id, name: "Пратчетт Терри").items

    book = books[1]
    
    let playlistUrls = try api.getPlaylistUrls(book!["id"]!)
    
    items = try api.getAudioTracks(playlistUrls[0])

    return (book, items)
  }
  
}

