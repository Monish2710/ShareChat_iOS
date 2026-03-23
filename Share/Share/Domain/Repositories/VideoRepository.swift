//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import Foundation

protocol VideoRepository {
    func fetchPopularVideos(page: Int, perPage: Int) async throws -> PopularVideosPage
}
