import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError
    case noInternet
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid Response"
        case .statusCode(let code):
            "Status Code: \(code)"
        case .decodingError:
            "Decoding Failed"
        case .noInternet:
            "No Internet Connection"
        case .unknown(let error):
            error.localizedDescription
        }
    }

    var title: String {
        switch self {
        case .invalidURL, .invalidResponse:
            "Request Failed"
        case .statusCode:
            "Server Error"
        case .decodingError:
            "Data Error"
        case .noInternet:
            "No Connection"
        case .unknown:
            "Something Went Wrong"
        }
    }

    var systemImageName: String {
        switch self {
        case .noInternet:
            "wifi.exclamationmark"
        case .decodingError:
            "doc.text.magnifyingglass"
        case .statusCode:
            "exclamationmark.triangle"
        case .invalidURL, .invalidResponse, .unknown:
            "exclamationmark.circle"
        }
    }
}
