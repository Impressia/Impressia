//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct SearchView: View {
    
    @State private var query = String.empty()
    
    @FocusState private var focusedField: FocusField?
    enum FocusField: Hashable {
        case unknown
        case search
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Search...", text: $query)
                        .padding(8)
                        .focused($focusedField, equals: .search)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .onAppear() {
                            self.focusedField = .search
                        }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Search")
                        
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            if self.query.isEmpty == false {
                Section {
                    NavigationLink(value: RouteurDestinations.search) {
                        Label("Users with \"\(query)\"", systemImage: "person.3.sequence")
                    }
                    
                    NavigationLink(value: RouteurDestinations.search) {
                        Label("Go to user \"\(query)\"", systemImage: "person.crop.circle")
                    }
                }
                
                Section {
                    NavigationLink(value: RouteurDestinations.search) {
                        Label("Hashtags with \"\(query)\"", systemImage: "tag")
                    }
                    
                    NavigationLink(value: RouteurDestinations.search) {
                        Label("Hashtags with \"\(query)\"", systemImage: "tag.circle")
                    }
                }
            }
        }
        .onTapGesture {
            self.focusedField = .unknown
            hideKeyboard()
        }
         .navigationTitle("Search")
    }
}
