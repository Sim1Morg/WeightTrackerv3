import SwiftUI
import PhotosUI

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager()
    @State var entry: WeightEntry
    @State private var weight: String = ""
    @State private var selectedUnit: String
    @State private var weightInKg: Double = 0.0
    @State private var muscleMass: String = ""
    @State private var bodyFat: String = ""
    @State private var visceralFat: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var isMuscleFieldFocused: Bool
    @FocusState private var isBodyFatFocused: Bool
    @FocusState private var isVisceralFatFocused: Bool

    @State private var selectedImage: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var selectedDate = Date()
    var onUpdate: ((WeightEntry) -> Void)?


    init(entry: WeightEntry, selectedUnit:String, onUpdate: ((WeightEntry) -> Void)? = nil) {
           _entry = State(initialValue: entry)
        _selectedUnit = State(initialValue: selectedUnit)
            self.onUpdate = onUpdate
        _weightInKg = State(initialValue: entry.weight)
        
       }

    var body: some View {
        NavigationView {
            List {
                HStack {
                Text("Date:")
                     DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
            }
              HStack {
                   Text("Unit: \(selectedUnit)")
              }
                

                HStack {
                     Text("Weight:")
                    TextField("Enter your weight in \(selectedUnit)", text: $weight)
                        .keyboardType(.decimalPad)
                        .onChange(of: weight) { newValue in
                            if let weightValue = Double(newValue){
                                updateWeightInKg(newValue: weightValue)
                            }
                        }
                }
                HStack{
                    Text("Muscle Mass %:")
                    TextField("Enter Muscle Mass %", text: $muscleMass)
                        .keyboardType(.decimalPad)
                        .focused($isMuscleFieldFocused)
                    .onChange(of: isMuscleFieldFocused) { _ in
                        if !isMuscleFieldFocused {
                            validatePercentage(value: $muscleMass)
                        }
                    }
                }
                HStack{
                     Text("Body Fat %:")
                     TextField("Enter Body Fat %", text: $bodyFat)
                         .keyboardType(.decimalPad)
                         .focused($isBodyFatFocused)
                     .onChange(of: isBodyFatFocused) { _ in
                         if !isBodyFatFocused {
                             validatePercentage(value: $bodyFat)
                         }
                     }
                 }
                HStack {
                    Text("Visceral Fat:")
                    TextField("Enter Visceral Fat", text: $visceralFat)
                        .keyboardType(.decimalPad)
                        .focused($isVisceralFatFocused)
                    .onChange(of: isVisceralFatFocused) { _ in
                         if !isVisceralFatFocused {
                           validateInteger(value: $visceralFat)
                         }
                     }
                }
               HStack{
                    Text("Image:")
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("Pick Image")
                    }
                }


                Button("Save") {
                    updateWeightEntry()
                }
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadExistingData()
           updateWeightFromSelectedUnit()
        }
        .task(id: selectedImage) {
            if let data = try? await selectedImage?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    image = uiImage
            }
        }
    }

    private func updateWeightEntry() {
           guard let weightValue = Double(weight) else {
               return showError(message: "Weight must be a valid number.")
           }
           guard let muscleMassValue = Double(muscleMass) else {
               return showError(message: "Muscle mass must be a valid number.")
           }
           guard let bodyFatValue = Double(bodyFat) else {
               return showError(message: "Body fat must be a valid number.")
           }
        guard let visceralFatValue = Int(visceralFat) else {
              return showError(message: "Visceral fat must be an integer.")
          }
        if selectedDate > Date() {
            return showError(message: "Date cannot be in the future.")
        }

        let updatedEntry = WeightEntry(
            id: entry.id,
            date: selectedDate,
            weight: weightValue,
            bodyFat: bodyFatValue,
            muscleMass: muscleMassValue,
            visceralFat: visceralFatValue,
            weightUnit: WeightUnit(rawValue: selectedUnit) ?? .kg,
            image: image
        )
            dataManager.updateEntry(entry: entry, updatedEntry: updatedEntry)
            onUpdate?(updatedEntry)
            dismiss()


       }

    private func loadExistingData() {
       
         muscleMass = String(entry.muscleMass)
         bodyFat = String(entry.bodyFat)
        visceralFat = String(entry.visceralFat)
         selectedDate = entry.date
        image = entry.getImage()
        }


    private func updateWeightInKg(newValue: Double) {
         if selectedUnit == "kg" {
             weightInKg = newValue
         } else if selectedUnit == "lbs" {
             weightInKg = lbsToKg(lbs: newValue)
         } else if selectedUnit == "stone" {
             weightInKg = stoneToKg(stone: newValue)
         }
     }
    private func stoneToKg(stone: Double) -> Double {
        return stone * 6.35029
    }
    private func lbsToKg(lbs: Double) -> Double {
        return lbs * 0.453592
    }

    private func kgToLbs(kg: Double) -> Double {
        return kg * 2.20462
    }
    private func kgToStone(kg:Double) -> Double {
        return kg / 6.35029
    }


    private func showError(message: String) {
        errorMessage = message
        showError = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showError = false
        }
    }

    private func updateWeightFromSelectedUnit() {
       weight = displayWeight()
    }

    private func displayWeight() -> String {
       let weightForDisplay: Double
        if selectedUnit == "kg" {
            weightForDisplay = weightInKg
        } else if selectedUnit == "lbs" {
           weightForDisplay = kgToLbs(kg: weightInKg)
        } else {
            weightForDisplay = kgToStone(kg:weightInKg)
        }
         weight = String(format: "%.1f", weightForDisplay)
       return String(format: "%.1f", weightForDisplay)
    }
    private func validatePercentage(value: Binding<String>) {
            if let percentage = Double(value.wrappedValue) {
                if percentage < 0 || percentage > 100 {
                    showError(message: "Value must be from 0 to 100")
                    value.wrappedValue = ""
                }
                else if let muscle = Double(muscleMass), let fat = Double(bodyFat)
                {
                  let total = muscle + fat
                    if total > 100 {
                        showError(message: "Combined must not exceed 100%")
                        value.wrappedValue = ""
                    }

                }
            } else if value.wrappedValue != "" {
                showError(message: "Invalid number format")
                value.wrappedValue = ""
            }
        }
    
    private func validateInteger(value: Binding<String>) {
          if let number = Double(value.wrappedValue) {
                if number < 0 {
                    showError(message: "Must not be negative values!")
                    value.wrappedValue = ""
                }
            } else if value.wrappedValue != "" {
                showError(message: "Invalid integer format!")
                value.wrappedValue = ""
            }
        }
}
