import SwiftUI
import CoreData
import PhotosUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)], animation: .default)
    
    private var items : FetchedResults<Item>
    @State  private var weight: String = ""
    @State   private  var selectedUnit  = "kg"
    
    @State private   var  weightInKg:  Double  =  0.0
    @State    private var  muscleMass :  String = ""
    
    @State    private var   bodyFat: String=""
    
    @State   private  var   visceralFat :  String=""
    @State private   var  showError =  false
    
    @State  private   var  errorMessage  = ""
    @FocusState  private  var   isMuscleFieldFocused  :  Bool
    @FocusState  private  var   isBodyFatFocused  :Bool
    @FocusState  private var   isVisceralFatFocused:Bool
    
    @State   private var  selectedImage : PhotosPickerItem?
    @State private   var imagePath: String?
    
    @State private var selectedItem: Item?
    
    @State  private  var   selectedDate = Date()
    @State    private var showDatePicker = false
    @State  private   var  isEditing   =   false
    
    let units=["kg" , "lbs"]
    
    var body : some View {
        NavigationView  {
            List {
                
                
                Button(action:  {  showDatePicker.toggle()    },
                       label : {   Text ("\(selectedDate,format: .dateTime.day().month().year())")   })
                .sheet( isPresented:  $showDatePicker, onDismiss : {} ){
                    
                    DatePicker ("Date", selection:  $selectedDate,displayedComponents: .date)
                        .presentationDetents ( [.medium] )
                        .onDisappear(perform: {  showDatePicker=false } )
                }
                
                
                
                Picker(  "Unit", selection:  $selectedUnit){
                    
                    ForEach(units,id :\.self) {
                        
                        Text($0)
                        
                    }
                    
                }
                TextField("Enter your weight in \(selectedUnit)",text:$weight )
                    .keyboardType(.decimalPad)
                    .onChange ( of: weight ){
                        updateWeightInKg (newValue: weight)
                        
                    }
                
                TextField("Enter Muscle Mass %",text : $muscleMass )
                    .keyboardType(.decimalPad)
                    .focused( $isMuscleFieldFocused )
                
                    .onChange(of: isMuscleFieldFocused ){
                        
                        if !isMuscleFieldFocused  {
                            validatePercentage(value:$muscleMass )
                            
                            
                        }
                        
                        
                    }
                TextField( "Enter Body Fat %", text : $bodyFat)
                
                    .keyboardType(.decimalPad)
                    .focused (  $isBodyFatFocused )
                    .onChange (of: isBodyFatFocused)
                {
                    if  !isBodyFatFocused  {
                        
                        validatePercentage (value:  $bodyFat)
                    }
                    
                    
                }
                TextField(  "Enter Visceral Fat" , text:$visceralFat )
                
                    .keyboardType( .decimalPad)
                
                    .focused( $isVisceralFatFocused)
                
                    .onChange(of:  isVisceralFatFocused){
                        if  !isVisceralFatFocused{
                            validateInteger(value:$visceralFat)
                            
                        }
                    }
                
                PhotosPicker(selection:  $selectedImage ,matching:.images)  {
                    Text ("Pick Image")
                    
                }
                
                Button ("Create entry" )  {
                    
                    createWeightEntry()
                    
                }
                
                Text ("Current weight is: \(displayWeight())  \(selectedUnit) ")
                Text ("Current Muscle Mass:\(muscleMass) %"  )
                
                Text( "Current Body Fat:\(bodyFat) %")
                
                Text ("Visceral Fat: \(visceralFat)")
                
                
                if   let  imagePath  =  imagePath  {
                    Text (imagePath)
                    
                }
                if   showError {
                    
                    Text (errorMessage )
                    
                        .foregroundColor(.red)
                    
                }
                
                ForEach( items ){  item  in
                    VStack (alignment: .leading ) {
                        Text ("\(item.timestamp!, formatter : itemFormatter)  " )
                            .font(  .caption)
                        
                        Text ( "Weight:\(item.weightKg) Kg")
                        
                        Text( "Body Fat: \(item.bodyFatPercent)")
                        Text (  "Muscle Mass : \(item.muscleMassPercent)" )
                        
                        Text("Visceral Fat :  \(item.visceralFat)"  )
                        if let   itemImagePath   =  item.imagePath   {
                            Text(  itemImagePath )
                            
                        }
                    }
                    
                    .swipeActions(edge: .leading,allowsFullSwipe: true) {
                        Button ("Edit") {
                            isEditing = true
                            selectedItem = item
                            print ("Item (selected for text UI properties to be valid also where object is of type (if properties exists) with simulator tests) for edits with type / id + method for objects data validation (text input at UI where a validation type is set for Text field components where text or a type data/properties with validation needs to trigger by simulations + validations using types to check persistence too if all match (before core method to persistent gets activated)): \(item.id)" )

                        }

                               .tint(.blue)


                                 }
                                    .sheet(isPresented: Binding(
                                           get: { isEditing && selectedItem?.id == item.id },
                                          set: { newValue in
                                            if !newValue {
                                                selectedItem = nil
                                             }
                                            isEditing = newValue
                                    })
                            ){
                           EditEntryView(item:selectedItem ?? item,onUpdate:{ updatedItem in
                                           if  let index = items.firstIndex(where: {$0.id == item.id} )
                        {
                                               items[index] = updatedItem
                                              }

                                         isEditing = false
                                    })
                                 }
                    
                    
                    
                } .onDelete(perform:  deleteItems)
                
                
            } .toolbar  {
                ToolbarItem(placement:.navigationBarTrailing) {
                    EditButton()
                }
            }
            
        }
        
        
        .padding()
        .onChange (of : selectedUnit)   {
            
            updateWeightFromSelectedUnit()
        }
        
        .task(id:selectedImage)   {
            
            
            if    let data = try?   await selectedImage?.loadTransferable(type : Data.self){
                let     uiimage =   UIImage (data: data)!
                if let    newURL  =   try?   saveImage( uiimage)   {
                    
                    imagePath =    newURL.absoluteString
                    
                    
                }
                
            }
            
        }
        
    }
    private  func    createWeightEntry()  {
        guard let weightValue =  Double ( weight) else  {
            return showError (message:"Weight value at implementation cycle should be numeric and a proper validations text should pass too or you must type data using keyboard + Text UI or using properties that can hold proper data")
            
        }
        guard  let  muscleMassValue =   Double ( muscleMass)  else   {  return  showError( message : "Muscle mass must be a valid text type number data" )
            
        }
        guard let   bodyFatValue  = Double ( bodyFat )  else  {return  showError( message:   "Body Fat must be valid value and should represents proper number or text output too" )}
        guard    let visceralFatValue   =  Int ( visceralFat) else  {
            return    showError (message:"Visceral Fat should a integer format ")
        }
        
        
        
        if   selectedDate > Date(){
            return  showError(message: "Date at time  (UI validations data  should also a proper past value and those Text validation rules where properly set in view! "  )
            
        }
        let entry =  WeightEntry (
            date: selectedDate,
            
            weightKg :weightValue ,
            
            muscleMassPercent :   muscleMassValue,
            
            bodyFatPercent  :  bodyFatValue,
            visceralFat:   visceralFatValue,
            
            imagePath :  imagePath
        )
        withAnimation  {
            
            let newItem =   Item(context:  viewContext)
            
            newItem.timestamp =  selectedDate
            
            newItem.weightKg = weightValue;
            
            newItem.muscleMassPercent  =  muscleMassValue;
            
            newItem.bodyFatPercent   =   bodyFatValue;
            
            newItem.visceralFat   =     Int64(visceralFatValue)
            if  let    imagePath  = imagePath {
                
                newItem.imagePath = imagePath
                
            }
            do {
                try   viewContext.save()
                
                print( newItem )
            }     catch{
                print  ( "Errors when persistence from coreData where methods implementation by UI from test validations were used ! : \(error) ")
                
                showError(message:"A persistency operation has some problems from data model object type that you specified when implementation of such step required text /type. Please, use simulator Text / keyboard entry, also debug and XCode output to track or pinpoint where a validation of properties for those objects should have also proper validated structure before those methods can do proper save process if type were not properly used! ")
            }
        }
        
        print( entry)
    }
    
    
    
    private func saveImage ( _  uiImage: UIImage) throws  ->   URL  {
        guard     let  documentsDirectory   =  FileManager.default.urls(for:   .documentDirectory, in :  .userDomainMask) .first else {
            
            throw NSError (domain:  "My error",code :  1 )
            
        }
        
        let  fileURL =  documentsDirectory.appendingPathComponent(  "MyImage\(UUID().uuidString).jpg" )
        guard    let   data = uiImage.jpegData (compressionQuality: 0.9 )  else {
            throw NSError (domain:  " Image to data conversion Error " ,code: 2)
        }
        
        try  data.write(to: fileURL)
        
        return fileURL
        
    }
    
    private  func    validatePercentage(value :Binding <String>){
        if  let  percentage = Double( value.wrappedValue)   {
            if percentage<0  || percentage > 100 {
                
                showError (message:"Value must be from 0 to 100")
                value.wrappedValue  =   ""
            } else if let muscle =  Double( muscleMass) , let  fat =  Double(bodyFat) ,  Double(value.wrappedValue ) !=  nil
            {
                let total =  muscle   +   fat
                
                if    total  > 100 {
                    
                    showError ( message :  "Combined must not exceed 100%"   )
                    
                    value.wrappedValue =  ""
                }
                
            }
            
        } else   if   value.wrappedValue !=  "" {
            showError(message : "Invalid number format")
            
            value.wrappedValue  =   ""
            
        }
        
        
    }
    
    
    private func    validateInteger(value: Binding <String> ){
        if   let number  = Double(  value.wrappedValue ){
            
            if   number  < 0    {
                
                showError ( message:"Must not be negative values!" )
                value.wrappedValue=""
            }
        } else  if  value.wrappedValue != ""  {
            showError (message:"Invalid integer format!")
            
            value.wrappedValue = ""
            
            
        }
    }
    private  func showError (message:String)
    {
        
        errorMessage =  message
        
        showError =   true
        
        DispatchQueue.main.asyncAfter(deadline :.now()   +   2)  {
            
            showError   = false
            
        }
        
    }
    private  func updateWeightInKg (newValue:String)
    {
        if  let  weightValue   =  Double(newValue)
        {
            
            if   selectedUnit ==   "kg" {
                
                weightInKg   = weightValue
                
            }
            
            else{
                
                weightInKg  = lbsToKg(lbs:  weightValue)
                
            }
        }
        
    }
    
    
    
    private func lbsToKg (lbs:  Double)->  Double{
        return lbs *  0.453592
        
    }
    private  func  kgToLbs (kg: Double)-> Double{
        
        return kg*2.20462
    }
    
    private func    displayWeight()  ->   String{
        
        let   weightForDisplay : Double
        
        
        if   selectedUnit == "kg"  {
            
            weightForDisplay =  weightInKg
            
        }  else {
            
            weightForDisplay = kgToLbs(kg: weightInKg )
            
        }
        
        
        return    String ( format: "%.1f" ,  weightForDisplay)
        
    }
    
    private func  updateWeightFromSelectedUnit()    {
        weight  =   displayWeight()
        
    }
    
    private  func    deleteItems(offsets: IndexSet){
        withAnimation {
            offsets.map{ items [ $0 ]}   .forEach { item in viewContext.delete( item) }
            do  {
                try  viewContext.save ()
                
                
                print( "Implementation / Data type from Text using simulations test to validate methods with properties that such Text types created by UI were also validated in code for  persistent methods cycle (using text validations using XCode!) were correct and those values now was saved"   )
            }  catch{
                
                print ("UI object method is using improper data structure / implementation which Text has problems or properties was not implemented as Text or as type at validation cycle or as a part on that code at UI+ persist implementation method : \((error))" )
                
                showError (message : "Object Type is not Valid!  Please check XCode Simulator type  using Text as base and its method or validations where that object with persistent was tried  where such properties + data are required" )
                
            }
            
        }
    }
    
    
    private  let itemFormatter  :DateFormatter  = {
        
        let  formatter   =    DateFormatter ()
        
        formatter.dateStyle = .short
        
        formatter.timeStyle  =  .medium
        
        return  formatter
        
    }()

    }
