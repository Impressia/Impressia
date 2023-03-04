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
    private let photoUrls: [PhotoUrl]
    
    init(hashtag: String) {
        self.hashtag = hashtag
        self.photoUrls = [
            PhotoUrl(id: UUID().uuidString),
            PhotoUrl(id: UUID().uuidString),
            PhotoUrl(id: UUID().uuidString),
            PhotoUrl(id: UUID().uuidString),
            PhotoUrl(id: UUID().uuidString)
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum:80))]) {
            ForEach(self.photoUrls) { photoUrl in
                ImageGrid(photoUrl: photoUrl)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 80, height: 80)
                    .id(photoUrl.id)
            }
            
            Button {
                self.routerPath.navigate(to: .tag(hashTag: hashtag))
            } label: {
                Text("more...")
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
            
            var index = 0
            for status in statusesWithImages {
                if let mediaAttachment = status.getAllImageMediaAttachments().first {
                    self.photoUrls[index].url = mediaAttachment.url
                    self.photoUrls[index].blurhash = mediaAttachment.blurhash
                    
                    index = index + 1
                }
                
                if index == 5 {
                    break;
                }
            }
            
        } catch {
            ErrorService.shared.handle(error, message: "Loading tags failed.", showToastr: !Task.isCancelled)
        }
    }
}
