//
//  ReceiveController.swift
//  ECashKit-Example
//
//  Created by Sun on 2024/8/21.
//

import UIKit
import Combine

import BitcoinCore

class ReceiveController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet var addressLabel: UILabel?

    private var adapters = [BaseAdapter]()
    private let segmentedControl = UISegmentedControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Receive"

        addressLabel?.layer.cornerRadius = 8
        addressLabel?.clipsToBounds = true

        Manager.shared.adapterSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateAdapters()
            }
            .store(in: &cancellables)

        updateAdapters()
        segmentedControl.addTarget(self, action: #selector(onSegmentChanged), for: .valueChanged)
    }

    private func updateAdapters() {
        segmentedControl.removeAllSegments()

        adapters = Manager.shared.adapters

        for (index, adapter) in adapters.enumerated() {
            segmentedControl.insertSegment(withTitle: adapter.coinCode, at: index, animated: false)
        }

        navigationItem.titleView = segmentedControl

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        segmentedControl.sendActions(for: .valueChanged)
    }

    @objc func onSegmentChanged() {
        updateAddress()

        currentAdapter?.printDebugs()
    }

    func updateAddress() {
        addressLabel?.text = "  \(currentAdapter?.receiveAddress() ?? "")  "
    }

    @IBAction func onAddressTypeChanged(_: Any) {
        updateAddress()
    }

    @IBAction func copyToClipboard() {
        if let address = addressLabel?.text?.trimmingCharacters(in: .whitespaces) {
            UIPasteboard.general.setValue(address, forPasteboardType: "public.plain-text")

            let alert = UIAlertController(title: "Success", message: "Address copied", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
        }
    }

    private var currentAdapter: BaseAdapter? {
        guard segmentedControl.selectedSegmentIndex != -1, adapters.count > segmentedControl.selectedSegmentIndex else {
            return nil
        }

        return adapters[segmentedControl.selectedSegmentIndex]
    }
}
