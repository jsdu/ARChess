//
//  JDMaterial.swift
//  ARKitExample
//
//  Created by Jason Du on 7/23/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

enum material {
    case granite
}
class JDMaterial {
    static func createMaterial(materialType: material) -> SCNMaterial {
        let name: String
        switch materialType {
        case .granite:
            name = "granitesmooth"
        }
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = UIImage(named: "./Assets.scnassets/Materials/\(name)/\(name)-albedo.png")
        mat.roughness.contents = UIImage(named: "./Assets.scnassets/Materials/\(name)/\(name)-roughness.png")
        mat.metalness.contents = UIImage(named: "./Assets.scnassets/Materials/\(name)/\(name)-metal.png")
        mat.normal.contents = UIImage(named: "./Assets.scnassets/Materials/\(name)/\(name)-normal.png")
        mat.diffuse.wrapS = .repeat
        mat.diffuse.wrapT = .repeat
        mat.roughness.wrapS = .repeat
        mat.roughness.wrapT = .repeat
        mat.metalness.wrapS = .repeat
        mat.metalness.wrapT = .repeat
        mat.normal.wrapS = .repeat
        mat.normal.wrapT = .repeat
        return mat
    }
}
