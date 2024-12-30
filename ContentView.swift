import SwiftUI
import PhotosUI
import Charts

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool

    var body: some View {
        Button(action: { showDatePicker.toggle() }) {
            Text("\(selectedDate, format: .dateTime.day().month().year())")
        }
        .sheet(isPresented: $showDatePicker, onDismiss: {}) {
            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                .presentationDetents([.medium])
                .onDisappear { showDatePicker = false }
        }
    }
}

struct UnitPickerView: View {
    @Binding var selectedUnit: String
    let units: [String]

    var body: some View {
        Picker("Unit", selection: $selectedUnit) {
            ForEach(units, id: \.self) {
                Text($0)
            }
        }
    }
}
struct WeightInputView: View {
    @Binding var weight: String
    @Binding var selectedUnit: String
    @Binding var weightInKg: Double
     var updateWeightInKg: (Double) -> Void

    var body: some View {
        TextField("Enter your weight in \(selectedUnit)", text: $weight)
            .keyboardType(.decimalPad)
            .onChange(of: weight) { newValue in
                if let weightValue = Double(newValue) {
                updateWeightInKg(weightValue)
              }
            }
    }
}

struct MuscleMassInputView: View {
    @Binding var muscleMass: String
    @FocusState var isFocused: Bool
    var validatePercentage: (Binding<String>) -> Void


    var body: some View {
        TextField("Enter Muscle Mass %", text: $muscleMass)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .onChange(of: isFocused) { _ in
                if !isFocused{
                    validatePercentage($muscleMass)
                }
            }
    }
}

struct BodyFatInputView: View {
    @Binding var bodyFat: String
    @FocusState var isFocused: Bool
    var validatePercentage: (Binding<String>) -> Void

    var body: some View {
        TextField("Enter Body Fat %", text: $bodyFat)
            .keyboardType(.decimalPad)
            .focused($isFocused)
        .onChange(of: isFocused) { _ in
            if !isFocused {
                validatePercentage($bodyFat)
            }
        }
    }
}

struct VisceralFatInputView: View {
    @Binding var visceralFat: String
    @FocusState var isFocused: Bool

    var body: some View {
        TextField("Enter Visceral Fat", text: $visceralFat)
            .keyboardType(.decimalPad)
            .focused($isFocused)
        .onChange(of: isFocused) { _ in
           if !isFocused {
                validateInteger(value: $visceralFat)
            }
        }
    }
     private func validateInteger(value: Binding<String>) {
          if let number  = Double(value.wrappedValue){
            if number < 0 {
                showError(message: "Must not be negative values!")
                value.wrappedValue = ""
            }
          } else if value.wrappedValue != "" {
            showError(message: "Invalid integer format!")
            value.wrappedValue = ""
          }
    }
    private func showError(message:String)
    {
        
         
        print (message )
        
        
    }
}
struct ImagePickerView: View {
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var image: UIImage?

    var body: some View {
        PhotosPicker(selection: $selectedImage, matching: .images) {
            Text("Pick Image")
        }
    }
}
struct DisplayWeightInfo: View {
    var weightInKg: Double
    var selectedUnit: String
    var muscleMass: String
    var bodyFat: String
    var visceralFat: String
    var image: UIImage?
    var latestEntry: WeightEntry?
     
    private func displayWeight(entry: WeightEntry?, unit:String) -> String {
        guard let entry = entry else {
            return "0.0"
        }
        let weightForDisplay: Double
          if unit == "kg" {
              weightForDisplay = entry.weight
        } else if unit == "lbs"{
               weightForDisplay = kgToLbs(kg: entry.weight)
          } else {
              weightForDisplay = kgToStone(kg:entry.weight)
        }
        
          return String ( format:"%.1f", weightForDisplay)
      }
    
    private func kgToLbs(kg: Double) -> Double {
        return kg * 2.20462
    }
    
    private func kgToStone(kg:Double) -> Double {
        return kg / 6.35029
    }
    var body: some View {
        VStack (alignment:.leading){
            Text("Previous Readings")
                .font(.headline)
                
             Text("Weight: \(displayWeight(entry: latestEntry, unit: selectedUnit)) \(selectedUnit)")
            Text("Muscle Mass: \(muscleMass) %")
            Text("Body Fat: \(bodyFat) %")
          Text("Visceral Fat: \(visceralFat)")
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                     .frame(width: 200, height: 200)
            }
        }
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var weight: String = ""
    @State private var selectedUnit = "kg"
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
    @State private var showDatePicker = false
    
    @State private var showChart = false
    
    private var latestEntry: WeightEntry? {
           dataManager.entries.max(by: { $0.date < $1.date })
       }

    let units = ["kg", "lbs", "stone"]

    var body: some View {
        NavigationView {
            List {
                DatePickerView(selectedDate: $selectedDate, showDatePicker: $showDatePicker)
                UnitPickerView(selectedUnit: $selectedUnit, units: units)
                WeightInputView(weight: $weight, selectedUnit: $selectedUnit, weightInKg: $weightInKg, updateWeightInKg: updateWeightInKg)
               MuscleMassInputView(muscleMass: $muscleMass, isFocused: _isMuscleFieldFocused, validatePercentage: validatePercentage)
                BodyFatInputView(bodyFat: $bodyFat, isFocused: _isBodyFatFocused, validatePercentage: validatePercentage)
                VisceralFatInputView(visceralFat: $visceralFat, isFocused: _isVisceralFatFocused)
                ImagePickerView(selectedImage: $selectedImage, image: $image)

                Button("Create entry") {
                    createWeightEntry()
                }
                Button("Show Chart") {
                      showChart.toggle()
                  }
                
                  .sheet(isPresented: $showChart){
                         ChartView(selectedUnit: selectedUnit)
                   }

                DisplayWeightInfo(weightInKg: weightInKg, selectedUnit: selectedUnit, muscleMass: latestEntry?.muscleMass.formatted(.number.precision(.fractionLength(1))) ?? "0", bodyFat: latestEntry?.bodyFat.formatted(.number.precision(.fractionLength(1))) ?? "0", visceralFat: latestEntry?.visceralFat.formatted(.number.precision(.fractionLength(0))) ?? "0", image: image, latestEntry: latestEntry)
               
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                   }
                    
            }
           
            .navigationBarItems(trailing: NavigationLink(destination: HistoryView(selectedUnit: selectedUnit)){ Text("History")})
           
        }
        .padding()
        .onChange(of: selectedUnit) {
            updateWeightFromSelectedUnit()
        }
        .task(id: selectedImage) {
            if let data = try? await selectedImage?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    image = uiImage
                
            }
        }
    }
        
    private func createWeightEntry()  {
        guard let weightValue = Double(weight) else {
            showError(message:"Weight must be a valid number.")
             return
        }
        guard let muscleMassValue = Double(muscleMass) else {
            showError(message : "Muscle mass must be a valid number." )
             return
        }
        guard let bodyFatValue = Double(bodyFat) else {
            showError(message: "Body fat must be a valid number." )
             return
        }
        guard let visceralFatValue = Int(visceralFat)  else {
           showError (message:"Visceral Fat must be an integer." )
            return
        }
        
       if selectedDate > Date(){
         showError(message: "Date cannot be in the future.")
         return
        }
        
        let newEntry =  WeightEntry (
            date: selectedDate,
            weight: weightValue,
            bodyFat: bodyFatValue,
            muscleMass:   muscleMassValue,
            visceralFat:   visceralFatValue,
            weightUnit: WeightUnit(rawValue: selectedUnit) ?? .kg,
            image: image
        )
        
        dataManager.addEntry(entry: newEntry)
        resetInputFields()
    }
    
    private func resetInputFields() {
           weight = ""
           muscleMass = ""
           bodyFat = ""
           visceralFat = ""
           selectedImage = nil
           image = nil
           weightInKg = 0.0
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
            
        } else if selectedUnit == "lbs"{
            weightForDisplay = kgToLbs(kg: weightInKg )
        } else {
           weightForDisplay = kgToStone(kg: weightInKg)
        }
      
         return  String ( format:"%.1f", weightForDisplay)
   }
    private func deleteItems(offsets: IndexSet){
        withAnimation {
            offsets.map { dataManager.entries[$0]}.forEach { item in
                dataManager.entries.removeAll(where: { $0.id == item.id})
            }
            
        }
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
}
