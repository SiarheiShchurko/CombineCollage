
import UIKit
import Photos
import Combine

class PhotosViewController: UICollectionViewController {
  
  // MARK: - Public properties
    
    public var selectedPhotos: AnyPublisher<UIImage, Never> {
        return selectedPhotosSubject.eraseToAnyPublisher()
    }
  
  // MARK: - Private properties
    
  private lazy var photos = PhotosViewController.loadPhotos()
  private lazy var imageManager = PHCachingImageManager()
  
  private lazy var thumbnailSize: CGSize = {
    let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    return CGSize(width: cellSize.width * UIScreen.main.scale,
                  height: cellSize.height * UIScreen.main.scale)
  }()
  
    private var selectedPhotosSubject = PassthroughSubject<UIImage, Never>()
    
  // MARK: - View controller
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Check for Photos access authorization and reload the list if authorized.
    PHPhotoLibrary.fetchAuthorizationStatus { [ weak self ] (status) in
        // 1
        guard let self else { return }
        // 2
        if status {
        self.photos = PhotosViewController.loadPhotos()
    
        DispatchQueue.main.async {
          self.collectionView.reloadData()
        }
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
      self.selectedPhotosSubject.send(completion: .finished)
  }
    
  // MARK: - UICollectionViewDataSource
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let asset = photos.object(at: indexPath.item)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell

    cell.representedAssetIdentifier = asset.localIdentifier
    imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
      if cell.representedAssetIdentifier == asset.localIdentifier {
        cell.preview?.image = image
      }
    })
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = photos.object(at: indexPath.item)
    
    if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
      cell.flash()
    }
    
    imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [ weak self ] (image, info) in
      guard
        let self,
        let image,
        let info else {
          return
      }
      
      if let isThumbnail = info[PHImageResultIsDegradedKey as String] as? Bool, isThumbnail {
        // Skip the thumbnail version of the asset
        return
      }
      // Send the selected photo
      self.selectedPhotosSubject.send(image)
    })
  }

}

// MARK: - Fetch assets
extension PhotosViewController {
  
  static func loadPhotos() -> PHFetchResult<PHAsset> {
    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    return PHAsset.fetchAssets(with: allPhotosOptions)
  }
  
}
