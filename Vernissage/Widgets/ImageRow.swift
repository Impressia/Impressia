//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ImageRow: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath
    
    private let status: StatusData
    private let attachmentData: AttachmentData?
    
    @State private var imageHeight: Double
    @State private var imageWidth: Double
    @State private var uiImage:UIImage?
    @State private var showThumbImage = false
    @State private var error: Error?
    @State private var cancelled = true
    
    init(statusData: StatusData) {
        self.status = statusData
        self.attachmentData = statusData.attachments().first
        
        // Calculate size of frame (first from cache, then from real image, then from metadata).
        if let attachmentData, let size = ImageSizeService.shared.get(for: attachmentData.url) {
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else if let attachmentData, attachmentData.metaImageWidth > 0 && attachmentData.metaImageHeight > 0 {
            let size = ImageSizeService.shared.calculate(for: attachmentData.url,
                                                         width: attachmentData.metaImageWidth,
                                                         height: attachmentData.metaImageHeight)
            self.imageWidth = size.width
            self.imageHeight = size.height
        } else {
            self.uiImage = nil
            self.imageHeight = UIScreen.main.bounds.width
            self.imageWidth = UIScreen.main.bounds.width
        }
    }
    
    var body: some View {
        if let attachmentData {
            if let uiImage {
                ZStack {
                    if self.status.sensitive && !self.applicationState.showSensitive {
                        ZStack {
                            ContentWarning(blurhash: attachmentData.blurhash, spoilerText: self.status.spoilerText) {
                                self.imageView(uiImage: uiImage)
                                
                                if showThumbImage {
                                    FavouriteTouch {
                                        self.showThumbImage = false
                                    }
                                }
                            }
                        }
                    } else {
                        ZStack {
                            self.imageView(uiImage: uiImage)
                            
                            if showThumbImage {
                                FavouriteTouch {
                                    self.showThumbImage = false
                                }
                            }
                        }
                    }
                    
                    if let count = self.status.attachments().count, count > 1 {
                        BottomRight {
                            Text("1 / \(count)")
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .font(.caption2)
                                .foregroundColor(.black)
                                .background(.ultraThinMaterial, in: Capsule())
                        }.padding()
                    }
                }
                .frame(width: self.imageWidth, height: self.imageHeight)
            } else {
                if cancelled {
                    BlurredImage(blurhash: attachmentData.blurhash)
                        .frame(width: self.imageWidth, height: self.imageHeight)
                        .task {
                            await self.downloadImage(attachmentData: attachmentData)
                        }
                }
                else if let error {
                    ZStack {
                        BlurredImage(blurhash: attachmentData.blurhash)
                            .frame(width: self.imageWidth, height: self.imageHeight)
                        
                        ErrorView(error: error) {
                            await self.downloadImage(attachmentData: attachmentData)
                        }
                        .padding()
                    }
                } else {
                    BlurredImage(blurhash: attachmentData.blurhash)
                        .frame(width: self.imageWidth, height: self.imageHeight)
                        .onTapGesture{
                            self.navigateToStatus()
                        }
                        .task {
                            await self.downloadImage(attachmentData: attachmentData)
                        }
                }
            }
        }
    }
    
    private func imageView(uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture(count: 2) {
                Task {
                    try? await self.client.statuses?.favourite(statusId: self.status.id)
                }

                self.showThumbImage = true
                HapticService.shared.fireHaptic(of: .buttonPress)
            }
            .onTapGesture{
                self.navigateToStatus()
            }
            .imageContextMenu(client: self.client, statusData: self.status)
    }
    
    private func downloadImage(attachmentData: AttachmentData) async {
        do {
            if let imageData = try await RemoteFileService.shared.fetchData(url: attachmentData.url),
               let downloadedImage = UIImage(data: imageData) {
                    
                let size = ImageSizeService.shared.calculate(for: attachmentData.url,
                                                             width: downloadedImage.size.width,
                                                             height: downloadedImage.size.height)
                
                if self.imageHeight != size.height || self.imageWidth != size.width {
                    withAnimation(.linear) {
                        self.imageWidth = size.width
                        self.imageHeight = size.height
                    }
                }

                self.uiImage = downloadedImage
                
                HomeTimelineService.shared.update(attachment: attachmentData, withData: imageData, imageWidth: size.width, imageHeight: size.height)
                self.error = nil
                self.cancelled = false
            }
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "global.error.errorDuringImageDownload")
                self.error = error
            } else {
                ErrorService.shared.handle(error, message: "global.error.canceledImageDownload")
                self.cancelled = true
            }
        }
    }
    
    private func navigateToStatus() {
        self.routerPath.navigate(to: .status(
            id: status.rebloggedStatusId ?? status.id,
            blurhash: status.attachments().first?.blurhash,
            highestImageUrl: status.attachments().getHighestImage()?.url,
            metaImageWidth: status.attachments().first?.metaImageWidth,
            metaImageHeight: status.attachments().first?.metaImageHeight
        ))
    }
}
