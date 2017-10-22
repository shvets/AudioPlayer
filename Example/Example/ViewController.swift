import UIKit
import AudioPlayer

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
      destination.coverImageUrl = "https://audioknigi.club/uploads/topics/preview/00/01/31/69/486d2f8ba2_200crop.jpg"
      destination.parentName = "Акунин Борис - Сказки для идиотов"
      destination.selectedBookId = "https://audioknigi.club/akunin-boris-skazki-dlya-idiotov"
      destination.selectedItemId = 2
      destination.items = [
        AudioItem(name: "001.Вступление.mp3", id: "https://get.sweetbook.net/b/41196/VwMEFDUDpQvhCU2_Q3NKDs0u3pTNaVImZlHEy9IeOfs,/001.Вступление.mp3"),
        AudioItem(name: "001.Вступление.mp3", id: "https://get.sweetbook.net/b/41196/VwMEFDUDpQvhCU2_Q3NKDs0u3pTNaVImZlHEy9IeOfs,/001.Вступление.mp3"),
        AudioItem(name: "001.Вступление.mp3", id: "https://get.sweetbook.net/b/41196/VwMEFDUDpQvhCU2_Q3NKDs0u3pTNaVImZlHEy9IeOfs,/001.Вступление.mp3")
      ]
    }
  }
  
}

