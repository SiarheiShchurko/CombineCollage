
import Foundation
import Photos
import Combine

extension PHPhotoLibrary {
    static var isAuthorizedPublisher: Future<Bool, Never> {
        return Future<Bool, Never>  { promise in
            requestAuthorization { status in
                status == .authorized ? promise(Result.success(true)) : promise(Result.success(false))
            }
        }
    }
}


