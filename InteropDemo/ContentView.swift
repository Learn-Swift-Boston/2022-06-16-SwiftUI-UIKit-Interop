//
//  ContentView.swift
//  InteropDemo
//
//  Created by Zev Eisenberg on 6/16/22.
//

import SwiftUI
import PhotosUI

struct ContentView: View {

    @State var value: Float = 2
    @State var isShowingPhotoPicker = true
    @State var photos: [UIImage] = []

    var body: some View {
        Form {
            Section {
                Slider(value: $value, in: 1...10)
            }
            Section {
                MyCustomSlider(value: $value, in: 1...10)
            }
            Section {
                Text("\(value)")
            }
            Section {
                Button("Pick Photo (value: \(isShowingPhotoPicker.description))") {
                    isShowingPhotoPicker = true
                }
                HStack {
                    ForEach(photos, id: \.self) { photo in
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            MyPhotoPicker(
                allowsMultipleSelection: true,
                didFinishPicking: { results in
                    processResults(results)
                    isShowingPhotoPicker = false
                }
            )
        }
    }

    func processResults(_ results: [PHPickerResult]) {
        photos = []
        results
            .map(\.itemProvider)
            .forEach { provider in
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { providerReading, error in
                        DispatchQueue.main.async {
                            if let image = providerReading as? UIImage {
                                photos.append(image)
                            } else {
                                print("error loading image: \(error?.localizedDescription ?? "no error")")
                            }
                        }
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MyPhotoPicker: UIViewControllerRepresentable {

    let allowsMultipleSelection: Bool
    var didFinishPicking: ([PHPickerResult]) -> Void

    func makeCoordinator() -> PickerDelegate {
        PickerDelegate(didFinishPicking: didFinishPicking)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let library = PHPhotoLibrary.shared()
        var config = PHPickerConfiguration(photoLibrary: library)
        config.selectionLimit = allowsMultipleSelection ? 0 : 1
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ picker: PHPickerViewController, context: Context) {
    }

}

final class PickerDelegate: PHPickerViewControllerDelegate {

    var didFinishPicking: ([PHPickerResult]) -> Void

    init(didFinishPicking: @escaping ([PHPickerResult]) -> Void) {
        self.didFinishPicking = didFinishPicking
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        self.didFinishPicking(results)
    }
}

struct MyCustomSlider<Value>: UIViewRepresentable where Value: BinaryFloatingPoint
{
    let range: ClosedRange<Value>
    @Binding var value: Value

    init(
        value: Binding<Value>,
        in range: ClosedRange<Value>
    ) {
        self._value = value
        self.range = range.lowerBound...range.upperBound
    }

    func makeUIView(context: Context) -> UISlider {
        UISlider(
            frame: .zero,
            primaryAction: .init(
                handler: { action in
                    guard let slider = action.sender as? UISlider else {
                        return
                    }
                    self.value = Value(slider.value)
                }
            )
        )
    }

    func updateUIView(_ slider: UISlider, context: Context) {
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
    }
}
