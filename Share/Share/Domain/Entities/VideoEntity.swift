//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import Foundation

struct PopularVideosPage: Decodable {
    let page: Int
    let perPage: Int
    let videos: [VideoEntity]

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case videos
    }
}

struct VideoEntity: Decodable, Identifiable, Hashable {
    let id: Int
    let image: URL
    let duration: Int
    let user: VideographerEntity
    let videoFiles: [VideoFileEntity]

    enum CodingKeys: String, CodingKey {
        case id
        case image
        case duration
        case user
        case videoFiles = "video_files"
    }

    var videographerName: String {
        user.name
    }

    var durationText: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var bestPlayableURL: URL? {
        let mp4Files = videoFiles.filter { $0.fileType.lowercased().contains("mp4") }
        let sortedFiles = mp4Files.sorted { lhs, rhs in
            let lhsScore = abs(lhs.width - 720) + abs(lhs.height - 1280)
            let rhsScore = abs(rhs.width - 720) + abs(rhs.height - 1280)
            if lhsScore == rhsScore {
                return lhs.width * lhs.height > rhs.width * rhs.height
            }
            return lhsScore < rhsScore
        }
        return sortedFiles.first?.link ?? videoFiles.first?.link
    }
}

struct VideographerEntity: Decodable, Hashable {
    let name: String
}

struct VideoFileEntity: Decodable, Hashable {
    let id: Int
    let quality: String
    let fileType: String
    let width: Int
    let height: Int
    let link: URL

    enum CodingKeys: String, CodingKey {
        case id
        case quality
        case fileType = "file_type"
        case width
        case height
        case link
    }
}

struct VideoFeedItem: Identifiable, Hashable {
    let video: VideoEntity
    let sourcePage: Int

    var id: Int { video.id }
}
