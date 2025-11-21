//
//  ManualScanCoordinator.swift
//  HiddenCamera
//
//  Created by Codex on 2025-01-??.
//

import UIKit

final class ManualScanCoordinator: NavigationBasedCoordinator {
    private var viewController: ManualScanViewController?
    
    override func start() {
        super.start()
        let vm = ManualScanViewModel()
        let vc = ManualScanViewController(viewModel: vm, coordinator: self)
        self.viewController = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
        navigationController.popViewController(animated: true)
    }
}
