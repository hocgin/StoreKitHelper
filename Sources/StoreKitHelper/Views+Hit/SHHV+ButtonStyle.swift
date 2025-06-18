//
//  StoreHitHelperView+ButtonStyle.swift
//  StoreKitHelper
//
//  Created by hocgin on 2025/4/27.
//

import SwiftUI

extension StoreHitHelperView {
    struct ProductButtonStyle: ButtonStyle {
        @Environment(\.controlSize) var controlSize
        var background: Color
        init(_ background: Color = Color.black.opacity(0.2)) {
            self.background = background
        }

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(.white)
                .font(.headline)
                .padding(.vertical, padding())
                .font(getFontSize())
                .background(background)
                .cornerRadius(10)
                .shadow(radius: 2)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                )
                .compositingGroup()
                .overlay(
                    VStack {
                        if configuration.isPressed {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .blendMode(.hue)
                        }
                    }
                )
                .shadow(
                    color: .black.opacity(0.1),
                    radius: configuration.isPressed ? 1 : 5,
                    x: 0,
                    y: configuration.isPressed ? 0 : 3
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(), value: configuration.isPressed)
        }

        func padding() -> Double {
            let unit: CGFloat = 4
            switch controlSize {
                case .regular:
                    return unit * 2
                case .large:
                    return unit * 3
                case .mini:
                    return unit / 2
                case .small:
                    return unit
                case .extraLarge:
                    return unit
                @unknown default:
                    return unit
            }
        }

        func getPadding() -> EdgeInsets {
            let unit: CGFloat = 4
            switch controlSize {
                case .regular:
                    return EdgeInsets(top: unit * 2, leading: unit * 4, bottom: unit * 2, trailing: unit * 4)
                case .large:
                    return EdgeInsets(top: unit * 3, leading: unit * 5, bottom: unit * 3, trailing: unit * 5)
                case .mini:
                    return EdgeInsets(top: unit / 2, leading: unit * 2, bottom: unit / 2, trailing: unit * 2)
                case .small:
                    return EdgeInsets(top: unit, leading: unit * 3, bottom: unit, trailing: unit * 3)
                case .extraLarge:
                    fatalError()
                @unknown default:
                    fatalError()
            }
        }

        func getFontSize() -> Font {
            switch controlSize {
                case .regular:
                    return .body
                case .large:
                    return .title3
                case .small:
                    return .callout
                case .mini:
                    return .caption2
                case .extraLarge:
                    fatalError()
                @unknown default:
                    fatalError()
            }
        }
    }
}
