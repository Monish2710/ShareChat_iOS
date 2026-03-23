//
//  Share
//
//  Created by Monish Kumar on 23/03/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: HomeViewModel

    init(appContainer: AppContainer = AppContainer()) {
        _viewModel = StateObject(wrappedValue: appContainer.makeHomeViewModel())
    }

    var body: some View {
        HomeScreen(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
