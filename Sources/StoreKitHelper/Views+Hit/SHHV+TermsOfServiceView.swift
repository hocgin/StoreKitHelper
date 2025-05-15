//
//  TermsOfService.swift
//  StoreKitHelper
//
//  Created by wong on 3/28/25.
//

import SwiftUI

// MARK: 服务条款 & 隐私政策

extension StoreHitHelperView {
    struct TermsOfServiceView: View {
        @Environment(\.termsOfServiceHandle) private var termsOfServiceHandle
        @Environment(\.privacyPolicyHandle) private var privacyPolicyHandle

        @Environment(\.termsOfServiceLabel) private var termsOfServiceLabel
        @Environment(\.privacyPolicyLabel) private var privacyPolicyLabel
        @Environment(\.locale) var locale
        var body: some View {
            if termsOfServiceHandle != nil || privacyPolicyHandle != nil {
                HStack(spacing: 4) {
                    Spacer()
                    if let action = termsOfServiceHandle {
                        Button(action: action, label: {
                            let text = termsOfServiceLabel.isEmpty == true ? "terms_of_service".localized(locale: locale) : termsOfServiceLabel
                            Text(text)
                        })
                        .foregroundStyle(.white.opacity(0.8))
                    }

                    if let termsOfServiceHandle, let privacyPolicyHandle {
                        Text("&")
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.horizontal, 4)
                    }

                    if let action = privacyPolicyHandle {
                        Button(action: action, label: {
                            let text = privacyPolicyLabel.isEmpty == true ? "privacy_policy".localized(locale: locale) : privacyPolicyLabel
                            Text(text)
                        })
                        .foregroundStyle(.white.opacity(0.8))
                    }
                    Spacer()
                }
                .font(.footnote)
                .padding(.horizontal, 8)
            }
        }
    }
}
