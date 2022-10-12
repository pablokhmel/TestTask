import Foundation
import RxSwift

class FeedVM {
    var models = BehaviorSubject(value: [ImageModel]())
    var isGettingImages = false
    var hasError = BehaviorSubject(value: false)

    func getImages(text: String) {
        guard !isGettingImages else { return }

        isGettingImages = true
        apiProvider.request(.images(["count" : 10, "query" : text])) { [weak self] result in
            switch result {
            case .success(let response):
                guard response.statusCode == 200 else { return }
                let tokenResponse = try? response.map([ImageModel].self)
                if var value = try? self?.models.value() {
                    value.append(contentsOf: tokenResponse ?? [])
                    self?.models.onNext(value)
                }

            case.failure(let error):
                self?.hasError.onNext(true)
                print(error)
            }

            sleep(3)

            self?.isGettingImages = false
        }
    }
}
