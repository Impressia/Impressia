//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var routerPath: RouterPath

    @State private var query = String.empty()
    
    @FocusState private var focusedField: FocusField?
    enum FocusField: Hashable {
        case unknown
        case search
    }
    
    var body: some View {
        List {
            Section {
                TextField("Search...", text: $query)
                    .padding(8)
                    .focused($focusedField, equals: .search)
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .clearButton(text: $query)
                    .onAppear() {
                        self.focusedField = .search
                    }
                    .buttonStyle(PlainButtonStyle())
            }
            
            if self.query.isEmpty == false {
                Section {
                    NavigationLink(value: RouteurDestinations.accountsPhoto(listType: .search(query: self.query))) {
                        Label("Users with \"\(self.query)\"", systemImage: "person.3.sequence")
                    }
                    
                    NavigationLink(value: RouteurDestinations.userProfile(accountId: "", accountDisplayName: "", accountUserName: self.query)) {
                        Label("Go to user \"@\(self.query)\"", systemImage: "person.crop.circle")
                    }
                }
                
                Section {
                    NavigationLink(value: RouteurDestinations.hashtags(listType: .search(query: self.query))) {
                        Label("Hashtags with \"\(self.query)\"", systemImage: "tag")
                    }
                                        
                    NavigationLink(value: RouteurDestinations.statuses(listType: .hashtag(tag: self.query))) {
                        Label("Go to hashtag \"#\(self.query)\"", systemImage: "tag.circle")
                    }
                }
            }
        }
        .navigationTitle("Search")
    }
}
