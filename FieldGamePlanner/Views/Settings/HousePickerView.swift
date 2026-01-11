//
//  HousePickerView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct HousePickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // Placeholder houses - will be loaded from Supabase
    let houses = [
        "Angelo's", "Baldwin's Bec", "Caxton", "Coleridge",
        "Cotton Hall", "Durnford", "Evans'", "Godolphin",
        "Hawtrey", "Hopgarden", "Keate", "Villiers",
        "Warre", "Weston's", "Wotton"
    ]

    var body: some View {
        NavigationStack {
            List(houses, id: \.self) { house in
                Button {
                    appState.setMyHouse(house)
                    dismiss()
                } label: {
                    HStack {
                        Text(house)
                            .foregroundColor(.primary)
                        Spacer()
                        if appState.myHouse == house {
                            Image(systemName: "checkmark")
                                .foregroundColor(.etonGreen)
                        }
                    }
                }
            }
            .navigationTitle("Select House")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if !appState.myHouse.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear") {
                            appState.setMyHouse("")
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HousePickerView()
        .environmentObject(AppState())
}
