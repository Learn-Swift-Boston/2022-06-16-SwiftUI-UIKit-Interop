//
//  ContentView.swift
//  InteropDemo
//
//  Created by Zev Eisenberg on 6/16/22.
//

import SwiftUI

struct ContentView: View {

    @State var value: Float = 2

    var body: some View {
        Form {
            Section("SwiftUI Native") {
                Slider(value: $value, in: 1...10)
            }
            Section("UIKit Wrapped") {
                MyCustomSlider(value: $value, in: 1...10)
            }
            Section("Value") {
                Text("\(value)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
