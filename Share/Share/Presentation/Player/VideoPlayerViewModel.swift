//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import AVKit
import Combine
import Foundation

@MainActor
final class VideoPlayerViewModel: ObservableObject {
    @Published private(set) var currentIndex: Int
    let queue: [VideoFeedItem]
    let player = AVPlayer()

    init(queue: [VideoFeedItem], initialVideoID: Int) {
        self.queue = queue
        self.currentIndex = queue.firstIndex(where: { $0.id == initialVideoID }) ?? 0
    }

    var currentItem: VideoFeedItem? {
        guard queue.indices.contains(currentIndex) else { return nil }
        return queue[currentIndex]
    }

    func prepareInitialPlayback() {
        switchToVideo(at: currentIndex, autoplay: false)
    }

    func playNextVideo() {
        let nextIndex = currentIndex + 1
        if queue.indices.contains(nextIndex) {
            switchToVideo(at: nextIndex, autoplay: true)
        }
    }

    func switchToVideo(at index: Int, autoplay: Bool) {
        guard queue.indices.contains(index), let videoURL = queue[index].video.bestPlayableURL else { return }
        currentIndex = index
        player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
        if autoplay {
            player.play()
        }
    }

    func stopPlayback() {
        player.pause()
    }
}
