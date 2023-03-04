//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import PixelfedKit
import NukeUI

struct AccountImagesGridView: View {
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath
    
    private let account: Account
    private var photoUrls: [PhotoUrl]
    
    init(account: Account) {
        self.account = account
        self.photoUrls = [
            PhotoUrl(id: UUID().uuidString),
            PhotoUrl(id: UUID().uuidString),
            PhotoUrl(id: UUID().uuidString)
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum:140))]) {
            ForEach(self.photoUrls) { photoUrl in
                ImageGrid(photoUrl: photoUrl)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 140, height: 140)
                    .id(photoUrl.id)
            }
            
            Text("more...")
                .foregroundColor(.accentColor)
                .padding(10)
                .onTapGesture {
                    self.routerPath.navigate(to: .userProfile(accountId: account.id,
                                                              accountDisplayName: account.displayNameWithoutEmojis,
                                                              accountUserName: account.acct))
                }
        }
        .onFirstAppear {
            self.loadData()
        }
    }
    
    private func loadData() {
        if let statuses = self.account.recentPosts {
            let statusesWithImages = statuses.getStatusesWithImagesOnly()
            
            var index = 0
            for status in statusesWithImages {
                if let mediaAttachment = status.getAllImageMediaAttachments().first {
                    self.photoUrls[index].statusId = status.id
                    self.photoUrls[index].url = mediaAttachment.url
                    self.photoUrls[index].blurhash = mediaAttachment.blurhash
                    
                    index = index + 1
                }
                
                if index == 3 {
                    break;
                }
            }
        }
    }
}
