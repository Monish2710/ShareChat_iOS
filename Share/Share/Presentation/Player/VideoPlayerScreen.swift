//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import AVKit
import SwiftUI

struct VideoPlayerScreen: View {
    @StateObject var viewModel: VideoPlayerViewModel

    var body: some View {
        Group {
            if let currentItem = viewModel.currentItem {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VideoPlayer(player: viewModel.player)
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(alignment: .topTrailing) {
                                Text(currentItem.video.durationText)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .padding(12)
                            }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(currentItem.video.videographerName)
                                .font(.title3.weight(.bold))
                            Text("Pexels popular video • Page \(currentItem.sourcePage)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Text("Next Up")
                            .font(.headline)

                        LazyVStack(spacing: 12) {
                            ForEach(Array(viewModel.queue.enumerated()), id: \.element.id) { index, item in
                                Button {
                                    viewModel.switchToVideo(at: index, autoplay: true)
                                } label: {
                                    NextUpRow(item: item, isActive: index == viewModel.currentIndex)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                }
            } else {
                ContentUnavailableView("No video available", systemImage: "play.slash")
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.prepareInitialPlayback()
        }
        .onDisappear {
            viewModel.stopPlayback()
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { notification in
            guard let endedItem = notification.object as? AVPlayerItem, endedItem == viewModel.player.currentItem else {
                return
            }
            viewModel.playNextVideo()
        }
    }
}

private struct NextUpRow: View {
    let item: VideoFeedItem
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: item.video.image) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "play.rectangle.fill")
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .frame(width: 108, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.video.videographerName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                Text(item.video.durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isActive {
                Image(systemName: "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isActive ? Color.blue.opacity(0.12) : Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    VideoPlayerScreen(viewModel: VideoPlayerViewModel(queue: [], initialVideoID: 0))
}
