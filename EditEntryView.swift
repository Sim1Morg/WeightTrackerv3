import SwiftUI

struct EditEntryView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var weight: String = ""
    @State private var bodyFat: String = ""
    @State private var muscleMass: String = ""
    @State private var visceralFat: String = ""
    @State private var image: Image? = nil
    @State private var inputImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var weightUnit: WeightUnit = .kg
    
    var body: some View {
        NavigationView{
            Form {
                Section(header: Text("Weight")) {
                    TextField("Weight", text: $weight)
                        .keyboardType(.decimalPad)
                    Picker("Unit", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Body Metrics")) {
                    TextField("Body Fat %", text: $bodyFat)
                        .keyboardType(.decimalPad)
                    TextField("Muscle Mass %", text: $muscleMass)
                        .keyboardType(.decimalPad)
                    TextField("Visceral Fat", text: $visceralFat)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Photo")) {
                    HStack {
                        if let image = image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } else {
                            Text("No image selected")
                        }
                    }
                    
                    Button("Select Photo") {
                        showingImagePicker = true
                    }
                }
                
                Button("Save") {
                    saveEntry()
                    dismiss()
                }
            }
            .navigationTitle("Add Entry")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func saveEntry() {
        guard let weightValue = Double(weight),
              let bodyFatValue = Double(bodyFat),
              let muscleMassValue = Double(muscleMass),
              let visceralFatValue = Int(visceralFat) else {
            return
        }
        
        let newEntry = Entry(
            date: Date(),
            weight: weightValue,
            bodyFat: bodyFatValue,
            muscleMass: muscleMassValue,
            visceralFat: visceralFatValue,
            weightUnit: weightUnit,
            image: inputImage
        )
        
        
       
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            picker.dismiss(animated: true)
        }
    }
}
