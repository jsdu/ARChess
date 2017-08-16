//
//  ChessBoard.swift
//  ARKitExample
//
//  Created by Jason Du on 7/18/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit

class SquareNode: SCNNode {
    var location: Location

    init (geometry: SCNGeometry, location: Location) {
        self.location = location
        super.init()
        self.geometry = geometry
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PieceNode: SCNNode {
    var location: Location
    var color: Color
    var move: Move?
    init (geometry: SCNGeometry, location: Location, color: Color) {
        self.location = location
        self.color = color
        super.init()
        self.geometry = geometry
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func raise() {
        self.position.y += 0.3
    }

    func drop() {
        self.position.y -= 0.3
    }
}

class TappableNode: SCNNode {
    var isSelectable: Bool
    var location: Location
    var move: Move?
    var isLastMove: Bool
    init (geometry: SCNGeometry, location: Location) {
        self.isSelectable = false
        self.isLastMove = false
        self.location = location
        super.init()
        self.geometry = geometry
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeTappable() {
        self.isSelectable = true
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = GameManager.shared.greenColor
        self.geometry?.firstMaterial = greenMaterial
    }

    func makeClear(wipeLastMove: Bool) {
        self.isSelectable = false
        if wipeLastMove {
            self.isLastMove = false
        }
        let clearMaterial = SCNMaterial()
        clearMaterial.diffuse.contents = UIColor.clear
        self.geometry?.firstMaterial = clearMaterial
    }

    func makeLastMove() {
        self.isLastMove = true
        let goldMaterial = SCNMaterial()
        goldMaterial.diffuse.contents = GameManager.shared.goldColor
        self.geometry?.firstMaterial = goldMaterial
    }
}

class ChessBoard: VirtualObject {

    override init() {
        super.init(modelName: "vase", fileExtension: "scn", thumbImageFilename: "vase", title: "Vase")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadModel(board: Board) {
        let lightSquare = SCNBox(width: 1.0, height: 0.2, length: 1.0, chamferRadius: 0.0)
        let lightMaterial = SCNMaterial()
        lightMaterial.diffuse.contents = UIColor(colorLiteralRed: 0.9, green: 0.85, blue: 0.8, alpha: 1)
        lightSquare.firstMaterial = lightMaterial

        let darkSquare = SCNBox(width: 1.0, height: 0.2, length: 1.0, chamferRadius: 0.0)
        let darkMaterial = SCNMaterial()
        darkMaterial.diffuse.contents = UIColor(white: 0.15, alpha: 1)
        darkSquare.firstMaterial = darkMaterial

        let boardNode: SCNNode = SCNNode()
        for rank in 1...8 {
            for file in 1...8 {
                let isBlack = (rank + file) % 2 != 0
                let geometry: SCNGeometry = isBlack ? darkSquare : lightSquare

                let fileStruct = File(rawValue: file)!
                let rankStruct = Rank(integerLiteral: rank)

                let squareNode = SquareNode(geometry: geometry, location:Location(file: fileStruct, rank: rankStruct))
                squareNode.position = SCNVector3Make(Float(file) - 4.5, 0, Float(rank) - 4.5)
                GameManager.shared.sceneBoard.append(squareNode)
                boardNode.addChildNode(squareNode)

                // Add tappable
                let tappableSquare = SCNBox(width: 1.0, height: 0.01, length: 1.0, chamferRadius: 0.0)
                let greenMaterial = SCNMaterial()
                greenMaterial.diffuse.contents = UIColor.clear
                tappableSquare.firstMaterial = greenMaterial

                let tappableNode = TappableNode(geometry: tappableSquare, location: Location(fileStruct, rankStruct))
                tappableNode.position = squareNode.position
                tappableNode.position.y += Float(lightSquare.height)/2.0

                GameManager.shared.tappableBoard.append(tappableNode)
                boardNode.addChildNode(tappableNode)
            }
        }

        for square in board {
            if let piece = square.piece {
                let scene = SCNScene(named: "art.scnassets/chess pieces.dae")
                if let pieceDaeNode = scene?.rootNode.childNode(withName: piece.kind.name, recursively: true) {
                    let pieceNode = PieceNode(geometry: pieceDaeNode.geometry!, location: square.location, color: piece.color)
                    pieceNode.geometry?.firstMaterial = JDMaterial.createMaterial(materialType: .granite)
                    if piece.color == .black {
                        let blackMaterial = pieceNode.geometry?.firstMaterial
                        blackMaterial?.diffuse.contents = UIColor(white: 0.35, alpha: 1)
                        pieceNode.geometry?.firstMaterial = blackMaterial
                    }
                    for sceneSquare in GameManager.shared.sceneBoard {
                        if sceneSquare.location == square.location{
                            pieceNode.position = sceneSquare.position
                            pieceNode.position.y += 0.11
                        }
                    }
                    pieceNode.scale = SCNVector3(x: 0.67, y: 0.67, z: 0.67)
                    pieceNode.rotation = SCNVector4Make(1, 0, 0, Float.pi/2)

                    boardNode.addChildNode(pieceNode)
                    GameManager.shared.scenePieces.append(pieceNode)
                }

            }
        }
        
        boardNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        super.addChildNode(boardNode)
    }
}

