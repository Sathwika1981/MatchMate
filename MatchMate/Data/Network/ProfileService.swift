import Foundation

protocol ProfileServiceProtocol {
    func fetchProfiles() async throws -> [Profile]
}

final class ProfileService: ProfileServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchProfiles() async throws -> [Profile] {
        guard let url = Endpoint.fetchMatches.url else {
            throw APIError.invalidURL
        }

        let data: Data
        let httpResponse: HTTPURLResponse

        do {
            let (responseData, response) = try await session.data(from: url)
            data = responseData

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            httpResponse = http
        } catch let error as APIError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw APIError.noInternet
            default:
                throw APIError.unknown(urlError)
            }
        } catch {
            throw APIError.unknown(error)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.statusCode(httpResponse.statusCode)
        }

        do {
            let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
            return ProfileMapper.toDomain(userResponse)
        } catch {
            throw APIError.decodingError
        }
    }
}
