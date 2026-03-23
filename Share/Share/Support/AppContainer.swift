//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import Foundation

struct AppContainer {
    private let repository: VideoRepository

    init() {
        let remoteDataSource = DefaultPexelsRemoteDataSource()
        self.repository = PexelsVideoRepository(remoteDataSource: remoteDataSource)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getPopularVideosUseCase: GetPopularVideosUseCase(repository: repository)
        )
    }
}
