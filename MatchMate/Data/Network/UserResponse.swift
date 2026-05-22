import Foundation

// MARK: - Response

struct UserResponse: Decodable {
    let results: [User]
}

// MARK: - User

struct User: Decodable {
    let gender: String
    let name: PersonName
    let location: UserLocation
    let email: String
    let login: Login
    let dob: Dob
    let registered: Registration
    let phone: String
    let cell: String
    let id: Identity
    let picture: Picture
    let nat: String
}

struct PersonName: Decodable {
    let title: String
    let first: String
    let last: String

    var fullName: String {
        "\(first) \(last)"
    }
}

struct UserLocation: Decodable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: String
    let coordinates: Coordinates
    let timezone: Timezone

    enum CodingKeys: String, CodingKey {
        case street, city, state, country, postcode, coordinates, timezone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        street = try container.decode(Street.self, forKey: .street)
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        country = try container.decode(String.self, forKey: .country)
        coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
        timezone = try container.decode(Timezone.self, forKey: .timezone)

        // Custom decoding is required because the API returns the postal code
        // inconsistently as either a String or an Int.
        if let string = try? container.decode(String.self, forKey: .postcode) {
            postcode = string
        } else if let number = try? container.decode(Int.self, forKey: .postcode) {
            postcode = String(number)
        } else {
            throw DecodingError.typeMismatch(
                String.self,
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.postcode],
                    debugDescription: "Expected postcode as String or Int"
                )
            )
        }
    }
}

struct Street: Decodable {
    let number: Int
    let name: String
}

struct Coordinates: Decodable {
    let latitude: String
    let longitude: String
}

struct Timezone: Decodable {
    let offset: String
    let description: String
}

struct Login: Decodable {
    let uuid: String
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
}

struct Dob: Decodable {
    let date: String
    let age: Int
}

struct Registration: Decodable {
    let date: String
    let age: Int
}

struct Identity: Decodable {
    let name: String
    let value: String?
}

struct Picture: Decodable {
    let large: String
    let medium: String
    let thumbnail: String
}
