//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI
import MastodonSwift
import UIKit

struct HomeFeedView: View {
    @EnvironmentObject var applicationState: ApplicationState
    
    @State private var statuses: [Status] = []
    @State private var images: [ImageStatus] = []
    @State private var showLoading = false
    
    private static let initialColumns = 1
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(images) { item in
                        NavigationLink(destination: DetailsView(current: item)) {
                            Image(uiImage: item.image)
                                .resizable().aspectRatio(contentMode: .fit)
                        }
                    }
                }
            }
            
            VStack(alignment:.trailing) {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .font(.body)
                            .padding(16)
                            .foregroundColor(.white)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }.padding()
            
            if showLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .refreshable {
            do {
                try await loadData()
            } catch {
                print("Error", error)
            }
        }
        .task {
            do {
                self.showLoading = true
                try await loadData()
                self.showLoading = false
            } catch {
                self.showLoading = false
                print("Error", error)
            }
        }
    }
    
    private func loadData() async throws {
        guard let accessData = self.applicationState.accountData, let accessToken = accessData.accessToken else {
            return
        }
                
        let client = MastodonClient(baseURL: accessData.serverUrl).getAuthenticated(token: accessToken)
        self.statuses = try await client.getHomeTimeline(limit: 40)
        
        var imagesCache: [ImageStatus] = []
        for item in self.statuses {
            let imageStatus = try await self.fetchImage(status: item)

            if let imageStatus {
                imagesCache.append(imageStatus)
            }
        }
        
        self.images = imagesCache
    }
    
    public func fetchImage(status: Status) async throws -> ImageStatus? {
        guard let url = status.mediaAttachments.first?.url, let id = status.mediaAttachments.first?.id else {
            return nil
        }
        
        guard let data = try await RemoteFileService.shared.fetchData(url: url) else {
            return nil
        }
        
        let image = UIImage(data: data)
        guard let image = image else {
            return nil
        }
        
        /*
        var exif = image.getExifData()
        if let dict = exif as? [String: AnyObject] {
            dict.keys.map { key in
                print(key)
                print(dict[key])
            }
        }
        */
        
        return ImageStatus(id: id,image: image, status: status)
    }
}

struct HomeFeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeFeedView()
    }
}
