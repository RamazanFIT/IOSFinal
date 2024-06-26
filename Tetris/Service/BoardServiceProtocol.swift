import Foundation
import UIKit

protocol BoardServiceProtocol{
    var board: Board? { get }
    var tetrominoStartingColumn: Int { get }
    var tetrominoStartingRow: Int { get }
    
    func initBoardMap(rows: Int, columns: Int)
    func setNewTetrominoInBoard(squares: TetrominoSquares, color: UIColor?) -> Bool
    func moveTetromino(original: TetrominoSquares?, desired: TetrominoSquares, color: UIColor?) -> Bool
    func clearFullRows(_ squares: TetrominoSquares) -> Int
    func clearBoard()
}
