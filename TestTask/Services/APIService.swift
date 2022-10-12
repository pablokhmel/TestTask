import Foundation
import Moya

let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)

let apiProvider = MoyaProvider<APIService>(
    plugins: [
        networkLogger
    ])

enum APIService {
    case images(Parameters)
    case search(Parameters)
}

extension APIService: TargetType {
    typealias Parameters = [String: Any]

    var baseURL: URL { URL(string: "https://api.unsplash.com")! }

    var path: String {
        switch self {
        case .images:
            return "/photos/random"

        case .search:
            return "/search/photos"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .images(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)

        case .search(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json",
        "Authorization" : "Client-ID uicyuhWvy1QvfEblqBi-hV7NJ7anl-9gPo2P5JYmgGA"]
    }
}
