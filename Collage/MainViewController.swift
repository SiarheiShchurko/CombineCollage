import UIKit
import Combine

class MainViewController: UIViewController {
  
  // MARK: - Outlets

  @IBOutlet weak var imagePreview: UIImageView! {
    didSet {
      imagePreview.layer.borderColor = UIColor.gray.cgColor
    }
  }
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!

  // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    private let images = CurrentValueSubject<[UIImage], Never>([])

  // MARK: - View controller
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let collageSize = imagePreview.frame.size
    
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
  
  // MARK: - Actions
  
  @IBAction func actionClear() {
    
  }
  
  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }
    
  }
  
  @IBAction func actionAdd() {
    
  }
  
  private func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { alert in
      self.dismiss(animated: true, completion: nil)
    }))
    present(alert, animated: true, completion: nil)
  }
}
