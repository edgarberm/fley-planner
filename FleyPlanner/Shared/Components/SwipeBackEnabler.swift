//
//  SwipeBackEnabler.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 13/2/26.
//

import SwiftUI

struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
}
