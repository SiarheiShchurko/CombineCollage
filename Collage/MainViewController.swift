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
    private lazy var collageSize = self.imagePreview.frame.size

  // MARK: - View controller
  
  override func viewDidLoad() {
      super.viewDidLoad()
      self.createImageCollage()
      
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
    
    private func createImageCollage() {
        self.images
            .handleEvents(receiveOutput: { [ weak self ] (photos) in
                // 1
                guard let self else {
                    return
                }
                // 2
                self.updateUI(photos: photos)
            })
        // 3
            .map { photos in
                UIImage.collage(images: photos, size: self.collageSize)
            }
            .assign(to: \.image, on: self.imagePreview)
            .store(in: &subscriptions)
    }
  
  // MARK: - Actions
  
  @IBAction func actionClear() {
      self.images.send([])
  }
  
  @IBAction func actionSave() {
    guard let image = imagePreview.image else {
        return
    }
      // 1
      PhotoWriter.save(image)
          .sink { [ unowned self ] complition in
            // 2
              if case .failure(let error) = complition {
                  self.showMessage("Error", description:
            error.localizedDescription)
              }
              self.actionClear()
          } receiveValue: { [ unowned self ] (id) in
              // 3
              self.showMessage("\(id)")
          }.store(in: &subscriptions)

  }
  
  @IBAction func actionAdd() {
//      let newImages = images.value + [UIImage(named: "IMG_1907.jpg")!]
//      self.images.send(newImages)
      // 1
      guard
        let photosVC = storyboard?.instantiateViewController(withIdentifier: "\(PhotosViewController.self)") as? PhotosViewController else {
          return
      }
      // 2
       photosVC.selectedPhotos
          .map { [ weak self ] (selectedPhotos) in
              guard let self else {
                  return []
              }
             return self.images.value + [selectedPhotos]
          }
          .assign(to: \.value, on: images)
          .store(in: &subscriptions)
      navigationController?.pushViewController(photosVC, animated: true)
  }
  
  private func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { alert in
      self.dismiss(animated: true, completion: nil)
    }))
    present(alert, animated: true, completion: nil)
  }
}
