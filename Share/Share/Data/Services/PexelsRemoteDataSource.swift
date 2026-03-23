//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import Foundation

enum PexelsAPIError: LocalizedError {
    case invalidResponse
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The Pexels response could not be read."
        case let .serverError(statusCode):
            return "Pexels returned an error (\(statusCode))."
        }
    }
}

protocol PexelsRemoteDataSource {
    func fetchPopularVideos(page: Int, perPage: Int) async throws -> PopularVideosPage
}

struct DefaultPexelsRemoteDataSource: PexelsRemoteDataSource {
    private let session: URLSession
    private let baseURL = URL(string: "https://api.pexels.com/videos/popular")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPopularVideos(page: Int, perPage: Int) async throws -> PopularVideosPage {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
        ]

        guard let url = components?.url else {
            throw PexelsAPIError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PexelsAPIError.invalidResponse
        }

        guard 200 ..< 300 ~= httpResponse.statusCode else {
            throw PexelsAPIError.serverError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(PopularVideosPage.self, from: data)
    }
}
