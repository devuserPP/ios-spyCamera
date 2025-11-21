//
//  ManualScanViewController.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import UIKit
import SwiftUI

final class ManualScanViewController: ViewController {
    private let viewModel: ManualScanViewModel
    weak var coordinator: ManualScanCoordinator?
    
    init(viewModel: ManualScanViewModel, coordinator: ManualScanCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        let host = UIHostingController(rootView: ManualScanView(viewModel: viewModel))
        host.view.backgroundColor = .clear
        addChild(host)
        host.didMove(toParent: self)
        view.addSubview(host.view)
        host.view.fitSuperviewConstraint()
    }
}
