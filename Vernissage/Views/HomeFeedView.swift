//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI
import MastodonSwift
import UIKit

struct HomeFeedView: View {
    
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
                defer {
                    self.showLoading = false
                }
                
                self.showLoading = true
                try await loadData()
            } catch {
                print("Error", error)
            }
        }
    }
    
    private func loadData() async throws {
        let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI2MTQwOCIsImp0aSI6IjZjMDg4N2ZlZThjZjBmZjQ1N2RjZDQ5MTU2YjE2NzYyYmQ2MDQ1NDQ1MmEwYzEyMzVmNDA3YjY2YjFhYjU3ZjBjMTY2YjFmZmIyNjJlZDg2IiwiaWF0IjoxNjcyMDU5MDYwLjI3NDgyMSwibmJmIjoxNjcyMDU5MDYwLjI3NDgyNCwiZXhwIjoxNzAzNTk1MDYwLjI1MzM1Nywic3ViIjoiNjc4MjMiLCJzY29wZXMiOlsicmVhZCIsIndyaXRlIiwiZm9sbG93Il19.kGvg3lW8lF1X1mOTdgGgoXNyzwUIJz5hz5RJKK_WiSoBWDQNadhZDty7XMNF0IAPjxOSi6UaIx2av7_eH_65aNlKFw89bkm8bT_zFQW2V0KbADJ-NmE6X0B_NgU2CNoF5IPn6bhCFHCKMtV6MWAQ_db6DT-LXaGemMY3QimcJzCqQuXI_1ouiZ235T297uEPNTrLwtLq-x_UoO-wx254LStBalDIGDVHAa4by9IT-mvu-QXz7k8pH2NHKoX-9Ql_Y3G9RJJNqoOmWMU45Dyo2HaJKKEb1tkeJ9tA3LIYgbwnEbG2PJ7CE8CXxtakiCIflJZpzzOmq1jXLAsCJ1mHnc77o7NfMaB_hY-f8PEI6d2ttOdH8bNlreF2avznNAIVHg_bf-yv_4wKUCUe0QZMG_yWqOwOk6lyruvboSGKuI5RnYsJbXBoJTGMLON6jVmtiKPbHy-9jNcfFgShAc3D5kTO-8Avj9_RquqEh1TQF_S4ljmganxKzMihyMDLK1OVcXzCFO6FKlCw7YKvbfJk1Qrn9kPBrVDM5jzIyXAmqRd1ivcE9nAdYb2l7KnxW_pi31uT0IdJMpTkZrUQSDMyEnj0HgV6Yd5BDlLG6Cnk8GXATTcU-a1pgE13OtWsCpD2cZQm-tOsFHWBDvY-BA0RtTvQAyEUxRIP9NjHe8rSR90"
        
        let client = MastodonClient(baseURL: URL(string: "https://pixelfed.social")!)
            .getAuthenticated(token: accessToken)
        
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
