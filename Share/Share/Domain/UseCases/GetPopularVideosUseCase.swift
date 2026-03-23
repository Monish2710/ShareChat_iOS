//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import Foundation

struct GetPopularVideosUseCase {
    private let repository: VideoRepository

    init(repository: VideoRepository) {
        self.repository = repository
    }

    func execute(page: Int, perPage: Int) async throws -> PopularVideosPage {
        try await repository.fetchPopularVideos(page: page, perPage: perPage)
    }
}
