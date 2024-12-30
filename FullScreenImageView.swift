import SwiftUI

struct FullscreenImageView: View {
    @Environment(\.presentationMode) var presentationMode
    var image: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Image not available")
                    .foregroundColor(.white)
            }

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

        }
        
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
}

#Preview {
    if let image = UIImage(systemName: "photo") {
    return FullscreenImageView(image: image)
    } else {
        return FullscreenImageView(image: UIImage())
    }
}
