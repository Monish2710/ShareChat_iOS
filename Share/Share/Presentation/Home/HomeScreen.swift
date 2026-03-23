//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel

    private let columnCount = 3
    private let columnSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 12
    private let cardHeight: CGFloat = 230

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let itemWidth = ((geometry.size.width - (horizontalPadding * 2)) - (columnSpacing * CGFloat(columnCount - 1))) / CGFloat(columnCount)
                let columns = Array(repeating: GridItem(.fixed(itemWidth), spacing: columnSpacing), count: columnCount)

                Group {
                    if viewModel.isInitialLoading && !viewModel.hasContent {
                        loadingView(columns: columns, itemWidth: itemWidth)
                    } else if let errorMessage = viewModel.errorMessage, !viewModel.hasContent {
                        errorView(message: errorMessage)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: columnSpacing) {
                                ForEach(viewModel.items) { item in
                                    NavigationLink {
                                        VideoPlayerScreen(
                                            viewModel: VideoPlayerViewModel(
                                                queue: viewModel.itemsForPage(containing: item),
                                                initialVideoID: item.id
                                            )
                                        )
                                    } label: {
                                        VideoGridCard(item: item, width: itemWidth, height: cardHeight)
                                    }
                                    .buttonStyle(.plain)
                                    .task {
                                        await viewModel.loadMoreIfNeeded(currentItem: item)
                                    }
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.top, 12)

                            if viewModel.isLoadingMore {
                                ProgressView("Loading more")
                                    .padding()
                            }
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Video Discovery")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await viewModel.loadInitialVideosIfNeeded()
                }
                .overlay(alignment: .bottom) {
                    if let errorMessage = viewModel.errorMessage, viewModel.hasContent {
                        InlineErrorBanner(message: errorMessage)
                            .padding()
                    }
                }
            }
        }
    }

    private func loadingView(columns: [GridItem], itemWidth: CGFloat) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: columnSpacing) {
                ForEach(0..<18, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                        .frame(width: itemWidth, height: cardHeight)
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 6) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray4))
                                    .frame(height: 12)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray4))
                                    .frame(height: 10)
                                    .frame(maxWidth: 60)
                            }
                            .padding(10)
                        }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 12)
        }
        .redacted(reason: .placeholder)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try Again") {
                Task {
                    await viewModel.retry()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

private struct VideoGridCard: View {
    let item: VideoFeedItem
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: item.video.image) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray4))
                        .overlay {
                            Image(systemName: "video.slash")
                                .foregroundStyle(.white)
                        }
                @unknown default:
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray5))
                }
            }
            .frame(width: width, height: height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 14))

            LinearGradient(
                colors: [.clear, .black.opacity(0.82)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.video.durationText)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial, in: Capsule())
                Text(item.video.videographerName)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(.white)
            .frame(width: width - 20, alignment: .leading)
            .padding(10)
        }
        .frame(width: width, height: height)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .clipped()
    }
}

private struct InlineErrorBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HomeScreen(viewModel: AppContainer().makeHomeViewModel())
}
