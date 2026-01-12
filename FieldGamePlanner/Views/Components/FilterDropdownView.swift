//
//  FilterDropdownView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

/// A dropdown filter button similar to the website's filter dropdowns
struct FilterDropdownView<T: Hashable & Identifiable>: View {
    let title: String
    let icon: String
    let options: [T]
    @Binding var selection: T?
    let label: (T) -> String
    let allLabel: String

    @State private var isExpanded = false

    private var displayLabel: String {
        if let selected = selection {
            return label(selected)
        }
        return allLabel
    }

    var body: some View {
        Menu {
            Button {
                selection = nil
            } label: {
                HStack {
                    Text(allLabel)
                    if selection == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    HStack {
                        Text(label(option))
                        if selection?.id == option.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(displayLabel)
                    .font(.subheadline)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selection != nil ? Color.etonPrimary : Color.clear, lineWidth: 1.5)
            )
        }
        .foregroundColor(.primary)
    }
}

/// House-specific filter dropdown with kit colors
struct HouseFilterDropdown: View {
    let title: String
    let options: [House]
    @Binding var selection: String?
    let allLabel: String

    private var selectedHouse: House? {
        options.first { $0.id == selection }
    }

    private var displayLabel: String {
        selectedHouse?.name ?? allLabel
    }

    var body: some View {
        Menu {
            Button {
                selection = nil
            } label: {
                HStack {
                    Text(allLabel)
                    if selection == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(options) { house in
                Button {
                    selection = house.id
                } label: {
                    HStack {
                        Text(house.name)
                        if selection == house.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "house")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let house = selectedHouse {
                    KitColorIndicator(colors: house.parsedColours)
                        .scaleEffect(0.8)
                }

                Text(displayLabel)
                    .font(.subheadline)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selection != nil ? Color.etonPrimary : Color.clear, lineWidth: 1.5)
            )
        }
        .foregroundColor(.primary)
    }
}

/// Umpire filter dropdown
struct UmpireFilterDropdown: View {
    let options: [String]
    @Binding var selection: String?
    let allLabel: String

    private var displayLabel: String {
        selection ?? allLabel
    }

    var body: some View {
        Menu {
            Button {
                selection = nil
            } label: {
                HStack {
                    Text(allLabel)
                    if selection == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(options, id: \.self) { umpire in
                Button {
                    selection = umpire
                } label: {
                    HStack {
                        Text(umpire)
                        if selection == umpire {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(displayLabel)
                    .font(.subheadline)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selection != nil ? Color.etonPrimary : Color.clear, lineWidth: 1.5)
            )
        }
        .foregroundColor(.primary)
    }
}

/// School team filter dropdown
struct SchoolTeamFilterDropdown: View {
    let options: [House]
    @Binding var selection: String?
    let allLabel: String

    private var selectedTeam: House? {
        options.first { $0.id == selection }
    }

    private var displayLabel: String {
        selectedTeam?.name ?? allLabel
    }

    var body: some View {
        Menu {
            Button {
                selection = nil
            } label: {
                HStack {
                    Text(allLabel)
                    if selection == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(options) { team in
                Button {
                    selection = team.id
                } label: {
                    HStack {
                        Text(team.name)
                        if selection == team.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.3")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let team = selectedTeam {
                    KitColorIndicator(colors: team.parsedColours)
                        .scaleEffect(0.8)
                }

                Text(displayLabel)
                    .font(.subheadline)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selection != nil ? Color.etonPrimary : Color.clear, lineWidth: 1.5)
            )
        }
        .foregroundColor(.primary)
    }
}

#Preview("Filters") {
    struct PreviewWrapper: View {
        @State private var selectedHouse: String?
        @State private var selectedUmpire: String?

        var body: some View {
            VStack(spacing: 16) {
                HouseFilterDropdown(
                    title: "House",
                    options: House.previewList,
                    selection: $selectedHouse,
                    allLabel: "All Houses"
                )

                UmpireFilterDropdown(
                    options: ["John Smith", "Jane Doe", "Bob Wilson"],
                    selection: $selectedUmpire,
                    allLabel: "All Umpires"
                )

                Spacer()
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
