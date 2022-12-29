//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import UIKit
import CoreData
import MastodonSwift

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var statuses: [Status] = []
    @State private var account: Account?
    @State private var images: [ImageStatus] = []
    @State private var current: ImageStatus? = nil
    @State private var navBarTitle: String = "Home feed"
    
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

        }.refreshable {
            do {
                try await loadData()
            } catch {
                print("Error", error)
            }
        }
        .navigationBarTitle(navBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        navBarTitle = "Home feed"
                    } label: {
                        HStack {
                            Text("Home feed")
                            Image(systemName: "house")
                        }
                    }
                    
                    Button {
                        navBarTitle = "Local feed"
                    } label: {
                        HStack {
                            Text("Local feed")
                            Image(systemName: "text.redaction")
                        }
                    }

                    Button {
                        navBarTitle = "Global feed"
                    } label: {
                        HStack {
                            Text("Global feed")
                            Image(systemName: "globe.europe.africa")
                        }
                    }
                    
                    Button {
                        navBarTitle = "Notifications"
                    } label: {
                        HStack {
                            Text("Notifications")
                            Image(systemName: "bell.badge")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // Open settings view.
                } label: {
                    if let avatarUrl = self.account?.avatar {
                        AsyncImage(url: avatarUrl) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .shadow(radius: 10)
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "person.circle")
                        }
                        .frame(height: 25)
                        .frame(width: 25)
                    } else {
                        Image(systemName: "person.circle")
                    }
                }
            }
        }
        .task {
            do {
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
        
        self.statuses = try await client.getHomeTimeline()
        self.account = try await client.verifyCredentials()
        
        var imagesCache: [ImageStatus] = []
        for item in self.statuses {
            let imageStatus = try await self.fetchImage(status: item, accessToken: accessToken)

            if let imageStatus {
                imagesCache.append(imageStatus)
            }
        }
        
        self.images = imagesCache
    }
    
    public func fetchImage(status: Status, accessToken: String) async throws -> ImageStatus? {
        guard let url = status.mediaAttachments.first?.url, let id = status.mediaAttachments.first?.id else {
            return nil
        }
        
        let urlRequest = URLRequest(url: url)
        
        // Fetching data.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }

        // Decoding JSON.
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


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
