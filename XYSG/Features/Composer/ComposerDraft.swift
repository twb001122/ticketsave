import Foundation
import XYSGCore

struct ComposerDraft: Sendable {
    var title: String = ""
    var selectedBrandID: UUID?
    var selectedBrandName: String = ""
    var selectedVenueID: UUID?
    var selectedVenueName: String = ""
    var selectedVenueCity: String = ""
    var selectedPerformers: [SelectedPerformer] = []
    var date: Date?
    var format: ShowFormat = .standup
    var myRole: ShowRole = .performer
    var showType: ShowType = .showcase
    var notes: String = ""
    var coverStoragePath: String?
    var coverData: Data?
    var coverFileExtension: String = "jpg"

    var sanitizedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var storedTitle: String {
        ShowPresentation.storedTitle(from: title)
    }

    mutating func setBrand(id: UUID?, name: String) {
        selectedBrandID = id
        selectedBrandName = name
    }

    mutating func setVenue(id: UUID?, name: String, city: String) {
        selectedVenueID = id
        selectedVenueName = name
        selectedVenueCity = city
    }

    mutating func togglePerformer(id: UUID, name: String) {
        if selectedPerformers.contains(where: { $0.id == id }) {
            selectedPerformers.removeAll { $0.id == id }
        } else {
            selectedPerformers.append(SelectedPerformer(id: id, name: name))
        }
    }

    mutating func removePerformer(id: UUID) {
        selectedPerformers.removeAll { $0.id == id }
    }

    static func from(show: ShowRecord) -> ComposerDraft {
        ComposerDraft(
            title: show.title,
            selectedBrandID: show.brand?.id,
            selectedBrandName: show.brand?.displayName ?? "",
            selectedVenueID: show.venue?.id,
            selectedVenueName: show.venue?.displayName ?? "",
            selectedVenueCity: show.venue?.cityName ?? "",
            selectedPerformers: show.performers.map { SelectedPerformer(id: $0.id, name: $0.displayName) },
            date: show.date,
            format: show.format,
            myRole: show.myRole,
            showType: show.showType,
            notes: show.notes,
            coverStoragePath: show.coverStoragePath
        )
    }
}

struct SelectedPerformer: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
}
