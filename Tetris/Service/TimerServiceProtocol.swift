import Foundation

protocol TimerServiceProtocol{
    var delegate: TimerServiceDelegate? { get set }
    var timer: Timer? { get }
    
    func start(intervalSeconds: Double)
    func stop()
    func incrementSpeed(_ incrementSeconds: Double)
}
