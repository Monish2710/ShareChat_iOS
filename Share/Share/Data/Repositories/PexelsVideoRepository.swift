//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import Foundation

struct PexelsVideoRepository: VideoRepository {
    private let remoteDataSource: PexelsRemoteDataSource

    init(remoteDataSource: PexelsRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchPopularVideos(page: Int, perPage: Int) async throws -> PopularVideosPage {
        try await remoteDataSource.fetchPopularVideos(page: page, perPage: perPage)
    }
}
