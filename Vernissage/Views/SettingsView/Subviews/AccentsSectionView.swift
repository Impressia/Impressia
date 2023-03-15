//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct AccentsSectionView: View {
    @EnvironmentObject var applicationState: ApplicationState
    
    private let accentColors1: [TintColor] = [.accentColor1, .accentColor2, .accentColor3, .accentColor4, .accentColor5]
    private let accentColors2: [TintColor] = [.accentColor6, .accentColor7, .accentColor8, .accentColor9, .accentColor10]
    
    var body: some View {
        Section("settings.title.accent") {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    ForEach(accentColors1, id: \.self) { color in
                        ZStack {
                            Circle()
                                .fill(color.color())
                                .frame(width: 36, height: 36)
                                .onTapGesture {
                                    self.applicationState.tintColor = color
                                    ApplicationSettingsHandler.shared.set(tintColor: color)
                                }
                            if color == self.applicationState.tintColor {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color.white)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        if color != accentColors1.last {
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 8)
                 
                HStack(alignment: .center) {
                    ForEach(accentColors2, id: \.self) { color in
                        ZStack {
                            Circle()
                                .fill(color.color())
                                .frame(width: 36, height: 36)
                                .onTapGesture {
                                    self.applicationState.tintColor = color
                                    ApplicationSettingsHandler.shared.set(tintColor: color)
                                }
                            if color == self.applicationState.tintColor {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color.white)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        if color != accentColors2.last {
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}
