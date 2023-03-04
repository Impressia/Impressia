//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import PixelfedKit
import NukeUI

struct TagImagesGridView: View {
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath
    
    private let hashtag: String
    private let maxImages = 5

    @State private var photoUrls: [PhotoUrl] = [
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString)
    ]
    
    init(hashtag: String) {
        self.hashtag = hashtag
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
            ForEach(self.photoUrls) { photoUrl in
                ImageGrid(photoUrl: photoUrl)
            }
            
            Text("more...")
                .foregroundColor(.accentColor)
                .fontWeight(.bold)
                .padding(10)
                .onTapGesture {
                    self.routerPath.navigate(to: .tag(hashTag: hashtag))
                }
        }
        .onFirstAppear {
            Task {
                await self.loadData()
            }
        }
    }
    
    private func loadData() async {
        do {
            let statusesFromApi = try await self.client.publicTimeline?.getTagStatuses(
                tag: self.hashtag,
                local: true,
                remote: false,
                limit: 10) ?? []

            let statusesWithImages = statusesFromApi.getStatusesWithImagesOnly()
            self.updatePhotos(statusesWithImages: statusesWithImages)
        } catch {
            ErrorService.shared.handle(error, message: "Loading tags failed.", showToastr: !Task.isCancelled)
        }
    }
    
    private func updatePhotos(statusesWithImages: [Status]) {
        var index = 0
        for status in statusesWithImages {
            if let mediaAttachment = status.getAllImageMediaAttachments().first {
                self.photoUrls[index].statusId = status.id
                self.photoUrls[index].url = mediaAttachment.url
                self.photoUrls[index].blurhash = mediaAttachment.blurhash
                
                index = index + 1
            }
            
            if index == self.maxImages {
                break;
            }
        }
    }
}
