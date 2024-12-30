import SwiftUI

struct HistoryView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedUnit = "kg"

      init(selectedUnit: String) {
            _selectedUnit = State(initialValue: selectedUnit)
       }
    var body: some View {
        VStack {
            Text("Stored Records")
                .font(.headline)
           HeaderRow(selectedUnit: selectedUnit)
            List {
                Section(){
                    ForEach(dataManager.entries.sorted(by: { $0.date > $1.date })) { entry in
                            ItemRow(entry: entry, selectedEntry: .constant(nil), isEditing: .constant(false), entries: dataManager.entries, dataManager: dataManager, currentUnit: selectedUnit)
                                
                        }
                    .onDelete(perform: deleteItems)
                    }
                
            }
            .listStyle(.plain)
        
        }
         
    }
     private func deleteItems(offsets: IndexSet) {
         withAnimation {
             let idsToDelete = offsets.map { dataManager.entries[$0].id }
             dataManager.entries.removeAll { idsToDelete.contains($0.id) }
         }
     }
}

struct HeaderRow: View {
    
    var selectedUnit:String
    var body: some View {
        HStack{
            Text("Date")
                 .font(.headline)
                   .frame(maxWidth: .infinity, alignment: .center)
                
                 Text("Weight \n (\(selectedUnit))")
                     .font(.headline)
                     .multilineTextAlignment(.center)
                       .frame(maxWidth: .infinity, alignment: .center)
                
                 Text("Muscle %")
                      .font(.headline)
                   .frame(maxWidth: .infinity, alignment: .center)
                     
                   Text("Body Fat %")
                      .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                   
                 Text("Visc. Fat")
                       .font(.headline)
                     .frame(maxWidth: .infinity, alignment: .center)
                     
                  Text("Pic")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
              }
          .padding(.vertical,5)
    }
}

struct ItemRow: View {
    var entry: WeightEntry
    @Binding var selectedEntry: WeightEntry?
    @Binding var isEditing: Bool
    var entries: [WeightEntry]
    var dataManager: DataManager
    var currentUnit: String
    
    private func displayWeight(entry: WeightEntry, unit:String) -> String {
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
          HStack {
             VStack(alignment: .leading) {
                  Text("\(entry.date, formatter: itemDateFormatter)")
                     .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                  Text("\(entry.date, formatter: itemTimeFormatter)")
                     .font(.caption)
                         .frame(maxWidth: .infinity, alignment: .center)
              }
                .frame(maxWidth: .infinity, alignment: .center)
                  
               Text("\(displayWeight(entry: entry, unit: currentUnit))")
                    .frame(maxWidth: .infinity, alignment: .center)
              
                Text("\(entry.muscleMass.formatted(.number.precision(.fractionLength(1))))")
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("\(entry.bodyFat.formatted(.number.precision(.fractionLength(1))))")
                    .frame(maxWidth: .infinity, alignment: .center)
               Text("\(entry.visceralFat.formatted(.number.precision(.fractionLength(0))))")
                    .frame(maxWidth: .infinity, alignment: .center)
              if let image = entry.getImage() {
                    Button {
                         //Add image to view here
                    } label: {
                        Image(uiImage: image)
                            .resizable()
                             .scaledToFit()
                            .frame(width: 30, height: 30, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
          } else {
             Text("-")
                 .frame(maxWidth: .infinity, alignment: .center)
          }
         
          }
           .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button("Edit") {
                   isEditing = true
                   selectedEntry = entry
                }
                .tint(.blue)
           }
           .sheet(isPresented: Binding(
               get: { isEditing && selectedEntry?.id == entry.id },
               set: { newValue in
                   if !newValue {
                       selectedEntry = nil
                   }
                   isEditing = newValue
           })
           ) {
               EditEntryView(entry: selectedEntry ?? entry, selectedUnit: currentUnit, onUpdate: { updatedEntry in
                         if let index = entries.firstIndex(where: {$0.id == entry.id} )
                   {
                       dataManager.entries[index] = updatedEntry
                     }

                   isEditing = false
                 })
           }
       
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yy HH:mm"
    return formatter
}()
private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yy"
    return formatter
}()

private let itemTimeFormatter: DateFormatter = {
   let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()
