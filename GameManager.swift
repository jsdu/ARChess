//
//  GameManager.swift
//  ARKitExample
//
//  Created by Jason Du on 7/24/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit
final class GameManager {

    private init() { }

    static let shared = GameManager()
    let greenColor = UIColor(red: 0.0420, green: 1, blue: 0.024, alpha: 0.8)
    let goldColor = UIColor(red: 0.976, green: 0.796, blue: 0.271, alpha: 1.00)
    var sceneBoard: [SquareNode] = []
    var scenePieces: [PieceNode] = []
    var tappableBoard: [TappableNode] = []
    var selectedPiece: PieceNode?
    var game = Game()

    static func move(tappedSquare: TappableNode) {
        if let selectedPiece = GameManager.shared.selectedPiece {
            if !tappedSquare.isSelectable {
                clearTappable(wipeLastMove: false)
                animate { selectedPiece.drop() }
            } else if let move = tappedSquare.move {
                do {
                    try GameManager.shared.game.execute(uncheckedMove: move)
                } catch {
                    print("move invalid error")
                }
                if move.isCastle() {
                    let castleSquares = move._castleSquares()
                    let rook = getPiece(location: castleSquares.old.location)
                    rook.location = castleSquares.new.location
                    let rookSquare = getSquare(location: castleSquares.new.location)
                    animateMove(selectedPiece: rook, tappedObject: rookSquare, lastMoveSquare: rookSquare, clear: false)
                }
                selectedPiece.location = tappedSquare.location
                animateMove(selectedPiece: selectedPiece, tappedObject: tappedSquare, lastMoveSquare: tappedSquare, clear: true)
            }
        }
    }

    static func getPiece(location: Location) -> PieceNode {
        for piece in GameManager.shared.scenePieces {
            if piece.location == location {
                return piece
            }
        }
        fatalError()
    }

    static func getSquare(location: Location) -> TappableNode {
        for square in GameManager.shared.tappableBoard {
            if square.location == location {
                return square
            }
        }
        fatalError()
    }

    // User has tapped on a PIECE
    static func move(tappedPiece: PieceNode) {
        if let selectedPiece = GameManager.shared.selectedPiece {
            // User taps on its selected piece, just drop it
            if selectedPiece == tappedPiece {
                GameManager.clearTappable(wipeLastMove: false)
                animate { selectedPiece.drop() }
            // User eats a piece
            } else if let move = tappedPiece.move {
                print("There is a possible move for the selected piece")
                do {
                    try GameManager.shared.game.execute(uncheckedMove: move)
                } catch {
                    print("Can't eat that")
                }
                selectedPiece.location = tappedPiece.location
                let tappedSquare = GameManager.getSquare(location: tappedPiece.location)
                animateMove(selectedPiece: selectedPiece, tappedObject: tappedPiece, lastMoveSquare: tappedSquare, clear: true)
            } else {
                // User tapped on a piece without a valid move
                GameManager.clearTappable(wipeLastMove: false)
                animate { selectedPiece.drop() }
            }
        }
        GameManager.raise(tappedPiece: tappedPiece)
    }

    // Raise selected piece and assign move to the piece
    // Highlight available moves
    static func raise(tappedPiece: PieceNode) {
        print(GameManager.shared.game.board.ascii)

        // TODO: Dont raise when the user from the opposite side selects the piece
        GameManager.shared.selectedPiece = tappedPiece
        animate { tappedPiece.raise() }

        let availableMoves = GameManager.shared.game.movesForPiece(at: tappedPiece.location)
        print("Available moves for selected piece: \(availableMoves)")
        for move in availableMoves {
            let endLocation = move.end.location
            // If the available move goes to a piece
            if GameManager.shared.game.board.space(at: endLocation).piece != nil {
                GameManager.getPiece(location: endLocation).move = move
            }
            // Available move is an empty square
            let tappableSquare = getSquare(location: endLocation)
            tappableSquare.makeTappable()
            tappableSquare.move = move
        }
    }

    static func clearTappable(wipeLastMove: Bool) {
        print("CLEARED DATA")
        for tappable in GameManager.shared.tappableBoard {
            if !tappable.isLastMove || (tappable.isLastMove && wipeLastMove) {
                tappable.makeClear(wipeLastMove: wipeLastMove)
            }
            tappable.move = nil
        }
        for piece in GameManager.shared.scenePieces {
            piece.move = nil
        }
        GameManager.shared.selectedPiece = nil
    }

    static func animateMove(selectedPiece:PieceNode, tappedObject: SCNNode, lastMoveSquare: TappableNode, clear: Bool) {
        animate {
            var position = tappedObject.position
            position.y += 0.1
            selectedPiece.position = position
            if tappedObject is PieceNode {
                tappedObject.removeFromParentNode()
            }
        }
        if clear {
            GameManager.clearTappable(wipeLastMove: true)
            lastMoveSquare.makeLastMove()
        }
    }
}

func animate(action:() -> ()) {
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0.5
    action()
    SCNTransaction.commit()
}
