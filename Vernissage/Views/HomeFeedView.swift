//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI
import MastodonSwift
import UIKit

struct HomeFeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var applicationState: ApplicationState
    
    @State private var showLoading = false
    
    private static let initialColumns = 1
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id, order: .reverse)]) var dbStatuses: FetchedResults<StatusData>
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(dbStatuses) { item in
                        NavigationLink(destination: DetailsView(statusData: item)) {
                            if let attachmenData = item.attachmentRelation?.first(where: { element in true }) as? AttachmentData {
                                Image(uiImage: UIImage(data: attachmenData.data)!)
                                    .resizable().aspectRatio(contentMode: .fit)
                            }
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
                if self.dbStatuses.isEmpty {
                    self.showLoading = true
                    try await loadData()
                    self.showLoading = false
                }
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
                
        // Get maximimum downloaded stauts id.
        let attachmentDataHandler = AttachmentDataHandler()
        let statusDataHandler = StatusDataHandler()
        let lastStatus = statusDataHandler.getMaximumStatus()
        
        // Retrieve statuses from API.
        let client = MastodonClient(baseURL: accessData.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(minId: lastStatus?.id, limit: 40)
        
        // Download status images and save it into database.
        for status in statuses {
            
            // Save status data in database.
            let statusDataEntity = statusDataHandler.createStatusDataEntity()
            statusDataEntity.accountAvatar = status.account?.avatar
            statusDataEntity.accountDisplayName = status.account?.displayName
            statusDataEntity.accountId = status.account!.id
            statusDataEntity.accountUsername = status.account!.username
            statusDataEntity.applicationName = status.application?.name
            statusDataEntity.applicationWebsite = status.application?.website
            statusDataEntity.bookmarked = status.bookmarked
            statusDataEntity.content = status.content
            statusDataEntity.createdAt = status.createdAt
            statusDataEntity.favourited = status.favourited
            statusDataEntity.favouritesCount = Int32(status.favouritesCount)
            statusDataEntity.id = status.id
            statusDataEntity.inReplyToAccount = status.inReplyToAccount
            statusDataEntity.inReplyToId = status.inReplyToId
            statusDataEntity.muted = status.muted
            statusDataEntity.pinned = status.pinned
            statusDataEntity.reblogged = status.reblogged
            statusDataEntity.reblogsCount = Int32(status.reblogsCount)
            statusDataEntity.sensitive = status.sensitive
            statusDataEntity.spoilerText = status.spoilerText
            statusDataEntity.uri = status.uri
            statusDataEntity.url = status.url
            statusDataEntity.visibility = status.visibility.rawValue
                        
            for attachment in status.mediaAttachments {
                let imageData = try await self.fetchImage(attachment: attachment)
                
                guard let imageData = imageData else {
                    continue
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
                
                // Save attachment in database.
                let attachmentData = attachmentDataHandler.createAttachmnentDataEntity()
                attachmentData.id = attachment.id
                attachmentData.url = attachment.url
                attachmentData.blurhash = attachment.blurhash
                attachmentData.previewUrl = attachment.previewUrl
                attachmentData.remoteUrl = attachment.remoteUrl
                attachmentData.text = attachment.description
                attachmentData.type = attachment.type.rawValue
                
                attachmentData.statusId = statusDataEntity.id
                attachmentData.data = imageData

                attachmentData.statusRelation = statusDataEntity
                statusDataEntity.addToAttachmentRelation(attachmentData)
            }
        }
        
        try self.viewContext.save()
    }
    
    public func fetchImage(attachment: Attachment) async throws -> Data? {
        guard let data = try await RemoteFileService.shared.fetchData(url: attachment.url) else {
            return nil
        }
        
        return data
    }
}

struct HomeFeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeFeedView()
    }
}
