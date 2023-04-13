
import UIKit
import Combine

extension UIViewController {
  
    func alert(title: String, text: String) -> AnyPublisher<Void, Never> {
        let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
        return Future { resolve in
            alertVC.addAction(UIAlertAction(title: "Close", style: .cancel) { _ in
                resolve(.success(()))
            })
            self.present(alertVC, animated: true)
        }
        .handleEvents(receiveCancel: {
            self.dismiss(animated: true)
        })
        .eraseToAnyPublisher()
    }
}
