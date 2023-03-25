//
//  RangeSlider.swift
//  PumpyLibrary
//
//  Created by Jack Vanderpump on 14/03/2023.
//

import SwiftUI

struct RangeSlider: View {
    /// The RangeSlider is a custom view in SwiftUI that allows the user to select a range of values by dragging two sliders. The slider ranges from 0.0 to 1.0 and increments according to the step parameter
    /// - Parameters:
    ///   - lowerValue: A binding to the lower value of the range slider. This value will be updated as the user drags the left slider.
    ///   - upperValue: A binding to the upper value of the range slider. This value will be updated as the user drags the right slider.
    ///   - step: An optional parameter that sets the step value for the range slider. The default value is 0.01.
    ///
    /// ```
    /// @State private var lowerValue = 0.2
    /// @State private var upperValue = 0.8
    ///
    /// var body: some View {
    ///    RangeSlider(lowerValue: $lowerValue, upperValue: $upperValue)
    /// }
    ///
    /// ```
    /// The step parameter provides incremental steps along the path of the slider. Set to 0.01 by default values, the slider increments 0.00, 0.01, 0.02, and so on.
    ///
    /// Changing the step to 0.1 would result in the slider incrementing 0.0, 0.1, 0.2 and so on.
    /// ```
    /// @State private var lowerValue = 0.2
    /// @State private var upperValue = 0.8
    ///
    /// var body: some View {
    ///    RangeSlider(lowerValue: $lowerValue,
    ///                upperValue: $upperValue,
    ///                step: 0.1)
    /// }
    /// ```
    public init(lowerValue: Binding<Double>,
                upperValue: Binding<Double>,
                step: Double = 0.01) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.step = step
    }
    
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    var step: Double = 0.01
    private let debouncer = Debouncer(0.005)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 0) {
                    componentSlider
                        .foregroundColor(.primary.opacity(0.1))
                        .frame(width: lowerValue * geo.size.width)
                    componentSlider
                        .foregroundColor(.accentColor)
                        .frame(width: (upperValue - lowerValue) * geo.size.width)
                    componentSlider
                        .foregroundColor(.primary.opacity(0.1))
                        .frame(width: (1-upperValue) * geo.size.width)
                }
                .cornerRadius(2)
                thumb.offset(x: (lowerValue - 0.5) * geo.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged{ gesture in
                                respondToGesture(changingUpperValue: false,
                                                 gesture: gesture, geo: geo)
                            }
                    )
                thumb.offset(x: (upperValue - 0.5) * geo.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged{ gesture in
                                respondToGesture(changingUpperValue: true,
                                                 gesture: gesture, geo: geo)
                            }
                    )
            }
        }
        .frame(height: 30, alignment: .center)
    }
    
    private var componentSlider: some View {
        Rectangle()
            .frame(height: 4)
    }
    
    private var thumb: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.white)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 4, y: 2)
            .frame(width: 25, height: 25)
    }
    
    private func respondToGesture(changingUpperValue: Bool,
                                  gesture: DragGesture.Value,
                                  geo: GeometryProxy) {
        
        debouncer.handle {
            let percentageOfSlider = gesture.location.x / geo.size.width + 0.5
            var valueChanging = max(min(percentageOfSlider, 1), 0)
            let rounder = 1 / step
            valueChanging = round(valueChanging * rounder) / rounder

            
            if changingUpperValue {
                upperValue = valueChanging
            } else {
                lowerValue = valueChanging
            }

            if changingUpperValue {
                if upperValue < lowerValue {
                    lowerValue = upperValue
                }
            } else {
                if lowerValue > upperValue {
                    upperValue = lowerValue
                }
            }
        }
    }
}

struct RangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
    
    struct DemoView: View {
        @State var lowerValue = 0.25
        @State var upperValue = 0.75
        
        var body: some View {
            VStack {
                RangeSlider(lowerValue: $lowerValue,
                            upperValue: $upperValue)
                    .padding(40)
                HStack(spacing: 40) {
                    Text("Lower Value: \(lowerValue, specifier: "%.2f")")
                    Text("Upper Value: \(upperValue, specifier: "%.2f")")
                }
            }
        }
    }
    
}

class Debouncer {
    
    private let timeInterval: TimeInterval
    private var timer: Timer?
    typealias Handler = () -> Void
    
    /// Call this method passing it the function that you want debounced.
    /// - Parameter callback: The function to be debounced.
    func handle(_ callback: @escaping Handler) {
        handler = callback
    }
    
    /// Initalise the Debouncer class
    /// - Parameter time: The amount of time to wait before allowing the function to be fired.
    init(_ time: TimeInterval = 0.3) {
        timeInterval = time
    }
    
    private var handler: Handler? {
        didSet {
            renewInterval()
        }
    }
    
    private func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] (timer) in
            self?.timeIntervalDidFinish(for: timer)
        }
    }
    
    private func timeIntervalDidFinish(for timer: Timer) {
        guard timer.isValid else {
            return
        }
        timer.invalidate()
        handler?()
        handler = nil
    }
    
}
