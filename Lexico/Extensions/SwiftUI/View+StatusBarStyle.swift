//
//  View+StatusBarStyle.swift
//  Lexico
//
//  Created by Codex on 2/19/26.
//

import SwiftUI
import UIKit

extension View {
    func statusBarStyle(_ style: UIStatusBarStyle) -> some View {
        background(StatusBarStyleConfigurator(style: style))
    }
}

private struct StatusBarStyleConfigurator: UIViewControllerRepresentable {
    let style: UIStatusBarStyle

    func makeUIViewController(context: Context) -> StatusBarStyleViewController {
        StatusBarStyleViewController()
    }

    func updateUIViewController(_ viewController: StatusBarStyleViewController, context: Context) {
        viewController.apply(style: style)
    }
}

private final class StatusBarStyleViewController: UIViewController {
    private var appliedStyle: UIStatusBarStyle?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apply(style: appliedStyle ?? .default)
    }

    func apply(style: UIStatusBarStyle) {
        appliedStyle = style

        guard let targetController = parent ?? navigationController ?? presentingViewController else {
            return
        }

        switch style {
        case .lightContent:
            targetController.overrideUserInterfaceStyle = .dark
        case .darkContent:
            targetController.overrideUserInterfaceStyle = .light
        default:
            targetController.overrideUserInterfaceStyle = .unspecified
        }

        targetController.setNeedsStatusBarAppearanceUpdate()
        targetController.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
}
