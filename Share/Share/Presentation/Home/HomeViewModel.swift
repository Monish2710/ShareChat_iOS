//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var items: [VideoFeedItem] = []
    @Published private(set) var isInitialLoading = false
    @Published private(set) var isLoadingMore = false
    @Published var errorMessage: String?

    private let getPopularVideosUseCase: GetPopularVideosUseCase
    private let perPage = 18
    private var currentPage = 0
    private var canLoadMore = true

    init(getPopularVideosUseCase: GetPopularVideosUseCase) {
        self.getPopularVideosUseCase = getPopularVideosUseCase
    }

    var hasContent: Bool {
        !items.isEmpty
    }

    func loadInitialVideosIfNeeded() async {
        guard items.isEmpty, !isInitialLoading else { return }
        await loadVideos(reset: true)
    }

    func refresh() async {
        await loadVideos(reset: true)
    }

    func retry() async {
        await loadVideos(reset: true)
    }

    func loadMoreIfNeeded(currentItem: VideoFeedItem) async {
        guard canLoadMore, !isLoadingMore, !isInitialLoading else { return }
        let thresholdIndex = items.index(items.endIndex, offsetBy: -6, limitedBy: items.startIndex) ?? items.startIndex
        if let currentIndex = items.firstIndex(where: { $0.id == currentItem.id }), currentIndex >= thresholdIndex {
            await loadVideos(reset: false)
        }
    }

    func itemsForPage(containing item: VideoFeedItem) -> [VideoFeedItem] {
        items.filter { $0.sourcePage == item.sourcePage }
    }

    private func loadVideos(reset: Bool) async {
        if reset {
            isInitialLoading = true
            errorMessage = nil
            currentPage = 0
            canLoadMore = true
        } else {
            isLoadingMore = true
            errorMessage = nil
        }

        let targetPage = currentPage + 1

        do {
            let response = try await getPopularVideosUseCase.execute(page: targetPage, perPage: perPage)
            let newItems = response.videos.map { VideoFeedItem(video: $0, sourcePage: response.page) }

            if reset {
                items = newItems
            } else {
                let existingIDs = Set(items.map(\.id))
                items.append(contentsOf: newItems.filter { !existingIDs.contains($0.id) })
            }

            currentPage = response.page
            canLoadMore = response.videos.count == response.perPage
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            if reset {
                items = []
            }
        }

        isInitialLoading = false
        isLoadingMore = false
    }
}
