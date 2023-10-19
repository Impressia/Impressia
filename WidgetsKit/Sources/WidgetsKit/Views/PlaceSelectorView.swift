//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit
import EnvironmentKit

@MainActor
public struct PlaceSelectorView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client
    @Environment(\.dismiss) private var dismiss

    @State private var places: [Place] = []
    @State private var showLoader = false
    @State private var query = String.empty()

    @Binding public var place: Place?

    @FocusState private var focusedField: FocusField?
    enum FocusField: Hashable {
        case unknown
        case search
    }

    public init(place: Binding<Place?>) {
        self._place = place
    }

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    Section {
                        HStack {
                            TextField(NSLocalizedString("placeSelector.title.search", bundle: Bundle.module, comment: "Search"), text: $query)
                                .padding(8)
                                .focused($focusedField, equals: .search)
                                .keyboardType(.default)
                                .autocorrectionDisabled()
                                .onAppear {
                                    self.focusedField = .search
                                }
                            Button {
                                Task {
                                    await self.searchPlaces()
                                }
                            } label: {
                                Text("placeSelector.title.buttonSearch", bundle: Bundle.module, comment: "Search")

                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Section {
                        if self.showLoader {
                            HStack(alignment: .center) {
                                Spacer()
                                LoadingIndicator(isVisible: Binding.constant(true))
                                Spacer()
                            }
                        }

                        ForEach(self.places, id: \.id) { place in
                            Button {
                                HapticService.shared.fireHaptic(of: .buttonPress)

                                self.place = place
                                self.dismiss()
                            } label: {
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading) {
                                        Text(place.name ?? String.empty())
                                            .foregroundColor(.mainTextColor)
                                        Text(place.country ?? String.empty())
                                            .font(.subheadline)
                                            .foregroundColor(.customGrayColor)
                                    }

                                    Spacer()
                                    if self.place?.id == place.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(self.applicationState.tintColor.color())
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("placeSelector.navigationBar.title", bundle: Bundle.module, comment: "Title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                self.getTrailingToolbar()
            }
        }
    }

    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(NSLocalizedString("placeSelector.title.cancel", bundle: Bundle.module, comment: "Cancel"), role: .cancel) {
                self.dismiss()
            }
        }
    }

    private func searchPlaces() async {
        self.showLoader = true

        do {
            if let placesFromApi = try await self.client.places?.search(query: self.query) {
                self.places = placesFromApi
            }
        } catch {
            ErrorService.shared.handle(error, message: "placeSelector.error.loadingPlacesFailed", showToastr: true)
        }

        self.showLoader = false
    }
}
