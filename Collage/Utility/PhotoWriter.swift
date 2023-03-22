
import Foundation
import UIKit
import Photos

import Combine

class PhotoWriter {
  enum Error: Swift.Error {
    case couldNotSavePhoto
    case generic(Swift.Error)
  }
    static func save(_ image: UIImage) -> Future<String,
    PhotoWriter.Error> {
        
      return Future { resolve in
          do {
              // 1
              try PHPhotoLibrary.shared().performChangesAndWait {
                  // 2
                  let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                  // 3
                 guard
                    let savedAssetID = request.placeholderForCreatedAsset?.localIdentifier else {
                     return resolve(.failure(.couldNotSavePhoto))
                 }
                  resolve(.success(savedAssetID))
              }
          } catch {
              resolve(.failure(.generic(error)))
          }
          
      }
    }
  
}
