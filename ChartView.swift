import SwiftUI
import Charts

struct ChartView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedUnit: String
    @State private var showAsWeight = false


    init(selectedUnit: String){
         _selectedUnit = State(initialValue: selectedUnit)
    }
    var body: some View {
        VStack {
            Text("Weight Progress")
                .font(.headline)
            
            HStack {
                 Text("Show Fat and Muscle as Weight")
                 Toggle("", isOn: $showAsWeight)
            }
           
            Chart {
                ForEach(dataManager.entries) { entry in
                    LineMark(
                         x: .value("Date", entry.date),
                        y: .value("Weight", displayWeight(entry: entry))
                    )
                    .symbol(Circle())
                       .foregroundStyle(.blue)
                      .annotation(position: .overlay, alignment: .bottom, spacing: 4) {
                               Text(String(format: "%.1f", displayWeight(entry: entry)))
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                   
                    if showAsWeight {
                        if entry.bodyFat != 0 {
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Fat", displayFatWeight(entry: entry))
                                )
                             .foregroundStyle(.red)
                               .symbol(Circle())
                                  .annotation(position: .overlay, alignment: .bottom, spacing: 4) {
                                   Text(String(format: "%.1f", displayFatWeight(entry: entry)))
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }
                        }
                         if entry.muscleMass != 0 {
                             LineMark(
                                 x: .value("Date", entry.date),
                                 y: .value("Muscle", displayMuscleWeight(entry: entry))
                                 )
                               .foregroundStyle(.green)
                                 .symbol(Circle())
                                  .annotation(position: .overlay, alignment: .bottom, spacing: 4) {
                                       Text(String(format: "%.1f", displayMuscleWeight(entry: entry)))
                                       .font(.caption2)
                                        .foregroundColor(.green)
                                   }
                         }
                    } else {
                         if entry.bodyFat != 0 {
                             LineMark(
                                 x: .value("Date", entry.date),
                                 y: .value("Fat", entry.bodyFat)
                             )
                             .foregroundStyle(.red)
                               .symbol(Circle())
                                .annotation(position: .overlay, alignment: .bottom, spacing: 4) {
                                    Text(String(format: "%.1f", entry.bodyFat))
                                        .font(.caption2)
                                       .foregroundColor(.red)
                                }
                         }
                          if entry.muscleMass != 0 {
                              LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Muscle", entry.muscleMass)
                            )
                            .foregroundStyle(.green)
                              .symbol(Circle())
                              .annotation(position: .overlay, alignment: .bottom, spacing: 4) {
                                 Text(String(format: "%.1f", entry.muscleMass))
                                   .font(.caption2)
                                    .foregroundColor(.green)
                                }
                          }
                     }
                    if entry.visceralFat != 0 {
                        LineMark(
                           x: .value("Date", entry.date),
                           y: .value("Visceral Fat", Double(entry.visceralFat))
                       )
                       .foregroundStyle(.purple)
                       .symbol(Circle())
                         .annotation(position: .overlay, alignment: .bottom, spacing: 4) {
                                  Text(String(format: "%.0f", Double(entry.visceralFat)))
                                    .font(.caption2)
                                   .foregroundColor(.purple)
                                }
                    }
                }
                
               
            }
            .chartForegroundStyleScale([
                     "Weight": .blue,
                     "Fat": .red,
                    "Muscle": .green,
                    "Visceral Fat": .purple
                 ])
           .chartLegend(position: .bottom, alignment: .center, spacing: 10)
        }
        .padding()
    }
    private func displayWeight(entry: WeightEntry) -> Double {
        let weightForDisplay: Double
        if selectedUnit == "kg" {
            weightForDisplay = entry.weight
        } else if selectedUnit == "lbs"{
           weightForDisplay = kgToLbs(kg: entry.weight)
        } else {
            weightForDisplay = kgToStone(kg:entry.weight)
        }
        return  weightForDisplay
    }
    private func displayFatWeight(entry: WeightEntry) -> Double {
            let weightForDisplay: Double
          
            if selectedUnit == "kg" {
                weightForDisplay = entry.weight * (entry.bodyFat / 100)
            } else if selectedUnit == "lbs"{
                 weightForDisplay =  kgToLbs(kg: entry.weight * (entry.bodyFat / 100))
            } else {
               weightForDisplay = kgToStone(kg: entry.weight * (entry.bodyFat / 100))
            }
           return  weightForDisplay
        }
    private func displayMuscleWeight(entry: WeightEntry) -> Double {
            let weightForDisplay: Double
         
            if selectedUnit == "kg" {
                weightForDisplay = entry.weight * (entry.muscleMass / 100)
           } else if selectedUnit == "lbs"{
                weightForDisplay =  kgToLbs(kg: entry.weight * (entry.muscleMass / 100))
           } else {
               weightForDisplay = kgToStone(kg: entry.weight * (entry.muscleMass / 100))
           }
           return  weightForDisplay
        }

    private func kgToLbs(kg: Double) -> Double {
        return kg * 2.20462
    }

    private func kgToStone(kg:Double) -> Double {
        return kg / 6.35029
    }
}
