import Foundation
import SwiftUI

// Enum for weight units
enum WeightUnit: String, CaseIterable, Codable {
    case kg = "kg"
    case lbs = "lbs"
    case stone = "stone"
}

// WeightEntry struct that conforms to Identifiable and Codable
struct WeightEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var weight: Double
    var bodyFat: Double
    var muscleMass: Double
    var visceralFat: Int
    var weightUnit: WeightUnit
    var imageData: Data? // Store image as Data
    
    // Custom Codable implementation for encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, date, weight, bodyFat, muscleMass, visceralFat, weightUnit, imageData
    }

    init(id: UUID = UUID(), date: Date, weight: Double, bodyFat: Double, muscleMass: Double, visceralFat: Int, weightUnit: WeightUnit, image: UIImage? = nil) {
        self.id = id
        self.date = date
        self.weight = weight
        self.bodyFat = bodyFat
        self.muscleMass = muscleMass
        self.visceralFat = visceralFat
        self.weightUnit = weightUnit
        self.imageData = image?.pngData() // Convert UIImage to Data
    }
    
    // Decode the image back into UIImage
    func getImage() -> UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}

// DataManager class for managing weight entries
class DataManager: ObservableObject {
    @Published var entries: [WeightEntry] = []
    
    init() {
        loadEntries()
    }
    
    func addEntry(entry: WeightEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func getEntry(for date: Date) -> WeightEntry? {
        let calendar = Calendar.current
        return entries.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        })
    }
    
    func updateEntry(entry: WeightEntry, updatedEntry: WeightEntry) {
        if let index = entries.firstIndex(where: {$0.id == entry.id}) {
            entries[index] = updatedEntry
            saveEntries()
        }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "Entries")
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "Entries"),
           let decoded = try? JSONDecoder().decode([WeightEntry].self, from: data) {  // Corrected here to [WeightEntry]
            entries = decoded
        }
    }
}

