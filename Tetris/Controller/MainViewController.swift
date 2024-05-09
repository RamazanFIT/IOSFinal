import UIKit
import SwiftUI

class MainViewController: UIViewController, GameServiceDelegate {

    private var boardViewController = BoardViewController()
    private var nextTetrominoViewController = NextTetrominoViewController()
    private var gameService : GameServiceProtocol! = nil
    private var buttonFireModeTimer: Timer?
    private var fireTimerInterval: Float = 0.1
    private let defaults = UserDefaults.standard

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var gameOverButton: UIButton!
    @IBOutlet weak var nextTetrominoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.add(boardViewController, view: gameView)
        self.add(nextTetrominoViewController, view: nextTetrominoView)
        
        leftButton.addTarget(self, action: #selector(leftButtonPressed), for: .touchDown)
        leftButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])
        rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchDown)
        rightButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])
        downButton.addTarget(self, action: #selector(downButtonPressed), for: .touchDown)
        downButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])

    }
    
    override func viewDidAppear(_ animated: Bool) {
        addServicesToLocator()
        loadDependencies()
        setScoreLabels()
    }
    
    private func addServicesToLocator(){
        ServiceLocator.shared.addService(service: TimerService())
        ServiceLocator.shared.addService(service: BoardService())
        ServiceLocator.shared.addService(service: TetrominoHelper())
        ServiceLocator.shared.addService(service: GameService())
    }
    
    public func loadDependencies(
                                 gameService : GameServiceProtocol? = nil){
        
        self.gameService = gameService ?? ServiceLocator.shared.getService()! as GameServiceProtocol
        self.gameService.delegate = self
    }
    
    private func setScoreLabels(){
        bestScoreLabel.text = String(defaults.integer(forKey: StoreKeys.bestScore))
        currentScoreLabel.text = String(0)
    }
    
    @objc private func leftButtonPressed(_ sender: UIButton) {
        askMovement(.left)
    }
    
    @objc private func rightButtonPressed(_ sender: UIButton) {
        askMovement(.right)
    }
    
    @objc private func downButtonPressed(_ sender: UIButton) {
        askMovement(.down)
    }
    
    private func askMovement(_ direction: MovementDirectionEnum){
        var selector: Selector?
        switch direction {
        case .left:
            askLeftMovement()
            selector = #selector(askLeftMovement)
        case .right:
            askRightMovement()
            selector = #selector(askRightMovement)
        case .down:
            askDownMovement()
            selector = #selector(askDownMovement)
        case .rotation:
            askRotation()
        }
        
        if selector != nil {
            buttonFireModeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(fireTimerInterval), target: self, selector: selector!, userInfo: nil, repeats: true)
        }
    }
    
    @objc private func askLeftMovement() {
        gameService.moveLeft()
    }
    
    @objc private func askRightMovement() {
        gameService.moveRight()
    }
    
    @objc private func askDownMovement() {
        gameService.moveDown()
    }
    
    private func askRotation(){
        gameService.rotate()
    }

    @objc private func buttonReleased() {
        buttonFireModeTimer?.invalidate()
    }

    @IBAction private func startButtonPressed(_ sender: UIButton) {
        print("play button")
        if gameService.currentState == .stopped{
            print("During stop state pressed")
            gameOverButton.isHidden = true
            setScoreLabels()
            gameService.startGame()
            nextTetrominoViewController.drawNextTetromino(gameService.nextTetromino!)
            boardViewController.clearBoard()
            boardViewController.startBoard()
        }
    }
    
    
    @IBAction private func rotateButtonPressed(_ sender: UIButton) {
        askMovement(.rotation)
    }
    
    func tetrominoHasMoved() {
        boardViewController.drawTetrominoMovement()
    }
    
    func newTetrominoAdded() {
        nextTetrominoViewController.drawNextTetromino(gameService.nextTetromino!)
        boardViewController.drawNewTetrominoAdded()
    }
    
    func gameOver() {
        gameOverButton.isHidden = false
        if gameService.currentScore > defaults.integer(forKey: StoreKeys.bestScore){
            defaults.set(gameService.currentScore, forKey: StoreKeys.bestScore)
        }
    }
    
    func fullRowCleared() {
        boardViewController.drawEntireBoard()
        currentScoreLabel.text = String(gameService.currentScore)
    }
    
}
