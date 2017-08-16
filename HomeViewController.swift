//
//  HomeViewController.swift
//  ARKitExample
//
//  Created by Jason Du on 7/31/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit
class HomeViewController: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ViewController else { return }
        if segue.identifier == "human" {

        } else if segue.identifier == "computer" {

        }
    }
}
