//: [Previous](@previous)
/*:

## Dijkstra's solution using semaphore's
 
Dijkstra found a solution that is synchronizing the consumer and producer thread. When the buffer is full producer thread is suspended when the buffer is empty consumer thread is suspended. He does this using his famouse Semaphore's...

 ![Semaphore](Semaphore.jpg)
 
### Algorithm:
 
The buffer can store N portions or elements. His solution is using two semaphor's and a mutex. The first semaphor counts down the number of empty locations in the buffer - it is called the "NumberOfEmptySlots" semaphore. If it reaches 0 the next producer will be suspended and has to wait - there is now more space in the buffer. The second semaphor counts down the number of filled positions in the buffer - it is calle the "NumberOFFilledSlots" sempahor. If it reaches zero each consumer trying to pop has to wait.
 
*/
import Foundation

class CoordinatedBuffer {
    
    private var list: [Int]
    private var size: Int
    
    private let notFull: DispatchSemaphore  // semaphor counter represents free slots
    private let notEmpty: DispatchSemaphore // semaphor counter represents items in buffer
    private let mutex: DispatchSemaphore    // semaphore to protect list manipulation
    
    public init(size: Int) {
        self.size = size
        self.list = [Int]()
        self.notFull = DispatchSemaphore(value: size)
        self.notEmpty = DispatchSemaphore(value: 0)
        self.mutex = DispatchSemaphore(value: 1)
    }
    
    public func push(value: Int) {
        notFull.wait()
        mutex.wait()
        list.append(value) // critical section
        mutex.signal()
        notEmpty.signal()
    }
    
    public func pop() -> Int  {
        notEmpty.wait()
        mutex.wait()
        let rtn =  list.removeFirst() // critical section
        mutex.signal()
        notFull.signal()
        return rtn
    }

}

class Executor {
    
    let id: String
    let buffer: CoordinatedBuffer
    
    init(id: String, buffer: CoordinatedBuffer) {
        self.id = id
        self.buffer = buffer
    }
    
    func run()  {
        assertionFailure("Needs to be implented by subclass")
    }
    
    func start()  {
        Task {
            while true {
                run()
            }
        }
    }
}

class Producer: Executor {
    var counter = 0
    override func run()  -> Void {
        buffer.push(value: counter)
        print("\(id) push \(counter)")
        counter += 1
    }
}

class Consumer: Executor {
    override func run()  -> Void {
        let nextInt =  buffer.pop()
        print("\(id) pop \(nextInt)")
    }
}

var buffer = CoordinatedBuffer(size: 20)

let p1 = Producer(id: "P1", buffer: buffer)
let c1 = Consumer(id: "C1", buffer: buffer)

let p2 = Producer(id: "P2", buffer: buffer)
let c2 = Consumer(id: "C2", buffer: buffer)

p1.start()
c1.start()

p2.start()
c2.start()
//: [Next](@next)
