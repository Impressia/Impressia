//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import Nuke
import NukeUI
import ServicesKit

@MainActor
struct ImagesGrid: View {
    public enum GridType: Hashable {
        case account(accountId: String, accountDisplayName: String?, accountUserName: String)
        case hashtag(name: String)
    }

    @Environment(Client.self) var client
    @Environment(RouterPath.self) var routerPath

    private let maxImages = 5
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)

    @State public var gridType: GridType
    @State public var maxHeight = UIDevice.isIPhone ? 160.0 : 240.0

    @State private var photoUrls: [PhotoUrl] = [
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString),
        PhotoUrl(id: UUID().uuidString)
    ]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem(.fixed(self.maxHeight))]) {
                ForEach(self.photoUrls) { photoUrl in
                    ImageGrid(photoUrl: photoUrl, maxHeight: $maxHeight)
                }

                Text("global.title.more", comment: "more...")
                    .foregroundColor(.accentColor)
                    .fontWeight(.bold)
                    .padding(10)
                    .onTapGesture {
                        self.openDetails()
                    }
            }
        }
        .gallery { properties in
            self.maxHeight = properties.horizontalSize == .compact ? 160.0 : 240.0
        }
        .frame(height: self.maxHeight)
        .onFirstAppear {
            Task {
                await self.loadData()
            }
        }
    }

    private func openDetails() {
        switch self.gridType {
        case .hashtag(let name):
            self.routerPath.navigate(to: .tag(hashTag: name))
        case .account(let accountId, let accountDisplayName, let accountUserName):
            self.routerPath.navigate(to: .userProfile(accountId: accountId, accountDisplayName: accountDisplayName, accountUserName: accountUserName))
        }
    }

    private func loadData() async {
        do {
            let statusesFromApi = try await self.loadStatuses()

            let statusesWithImages = statusesFromApi.data.getStatusesWithImagesOnly()
            
            let photoUrls = self.getPhotoUrls(statuses: statusesWithImages)
            self.prefetch(photoUrls: photoUrls)
            
            self.updatePhotos(statusesWithImages: statusesWithImages)
        } catch {
            ErrorService.shared.handle(error, message: "global.error.errorDuringDataLoad", showToastr: !Task.isCancelled)
        }
    }

    private func updatePhotos(statusesWithImages: [Status]) {
        var index = 0
        for status in statusesWithImages {
            if index < self.maxImages {
                if let mediaAttachment = status.getAllImageMediaAttachments().first {
                    self.photoUrls[index].statusId = status.id
                    self.photoUrls[index].url = mediaAttachment.url
                    self.photoUrls[index].blurhash = mediaAttachment.blurhash
                    self.photoUrls[index].sensitive = status.sensitive
                }
            } else {
                if let mediaAttachment = status.getAllImageMediaAttachments().first {
                    let photoUrl = PhotoUrl(id: UUID().uuidString)
                    photoUrl.statusId = status.id
                    photoUrl.url = mediaAttachment.url
                    photoUrl.blurhash = mediaAttachment.blurhash
                    photoUrl.sensitive = status.sensitive

                    self.photoUrls.append(photoUrl)
                }
            }

            index = index + 1
        }

        // Clear placeholders when there is small number of photos.
        if index < self.maxImages {
            for position in (index...self.maxImages - 1).reversed() {
                self.photoUrls.remove(at: position)
            }
        }
    }

    private func loadStatuses() async throws -> Linkable<[Status]> {
        switch self.gridType {
        case .hashtag(let name):
            return try await self.client.publicTimeline?.getTagStatuses(
                tag: name,
                local: true,
                limit: 10) ?? Linkable(data: [])
        case .account(let accountId, _, _):
            let accountStatuses = try await self.client.accounts?.statuses(
                createdBy: accountId,
                onlyMedia: true,
                limit: 10
            ) ?? []
            
            return Linkable(data: accountStatuses)
        }
    }
    
    private func getPhotoUrls(statuses: [Status]) -> [URL] {
        var photoUrls: [URL] = []
        for status in statuses {
            if let photoUrl = status.getAllImageMediaAttachments().first?.url {
                photoUrls.append(photoUrl)
            }
        }
        
        return photoUrls
    }
    
    private func prefetch(photoUrls: [URL]) {
        imagePrefetcher.startPrefetching(with: photoUrls)
    }
}
