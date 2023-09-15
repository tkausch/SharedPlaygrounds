//: [Previous](@previous)
/*:
 ## AsyncBuffer with Swift's Actor model
  
 The actor model in computer science is a mathematical model of concurrent computation that treats an actor as the basic building block of concurrent computation.
 
 ![Actor Model](actors.jpg)
 
 Swift actors are a new concurrency feature introduced in Swift 5.5 that provide a safe and efficient way to manage shared mutable state. Actors are a type of object that can be accessed concurrently from multiple threads, but ensure that access to their mutable state is serialized and thread-safe.
 
 - Note:
 Even if acess is serialized there can be many threads within the same actor waiting.
 
 To wait for conditions within an  actor a thread can yield control (when this condition is not met). So another thread can enter the actor to fulfill the condition or wait as well for the same condition. When an actor has waiting threads but no running threads the scheduler will wake one of the waitng one's up. The woken up thread will check his condition again and has the chance to proceed or yield again - when condition is not met. Which thread a scheduler will choose is  non deterministc.
 
 Knowing this makes it straight forward to implement a `AsyncBuffer` Actor. The drawback of the choosen algorithm is it is not deterministic - scheduler will choose the waiting producer/consumer randomly. And it could be the scheduler is waking up the wrong thread. However in our sample we have only two conditions threads can be waiting for. And as these conditions are completely distinct he will always pick a right one! There will be no delay by waking up the wrong thread!
 
 */
import Foundation

actor AsyncBuffer {
    
    var list: [Int]
    let size: Int
    
    init(size: Int = 10) {
        self.list = Array<Int>()
        self.size = size
    }
    
    func push(value: Int) async {
        while list.count == size  {
            await Task.yield()
        }
        // Postcondition: At least one free position in buffer
        assert(list.count < size)
        list.append(value)
    }
    
    func pop() async -> Int {
        while list.count == 0 {
            await Task.yield()
        }
        // Postcondition: At least one item in buffer
        assert(list.count > 0)
        return list.removeLast()
    }
}

class Executor {
    
    let id: String
    let buffer: AsyncBuffer
    
    init(id: String, buffer: AsyncBuffer) {
        self.id = id
        self.buffer = buffer
    }
    
    func run() async {
        assertionFailure("Needs to be implented by subclass")
    }
    
    func start()  {
        Task {
            while true {
                await run()
            }
        }
    }
}

class Producer: Executor {
    var counter = 0
    override func run() async -> Void {
        await buffer.push(value: counter)
        print("\(id) push \(counter)")
        counter += 1
    }
}

class Consumer: Executor {
    override func run() async -> Void {
        let nextInt =  await buffer.pop()
        print("\(id) pop \(nextInt)")
    }
}

var buffer = AsyncBuffer(size: 20)

let p1 = Producer(id: "P1", buffer: buffer)
let c1 = Consumer(id: "C1", buffer: buffer)

let p2 = Producer(id: "P2", buffer: buffer)
let c2 = Consumer(id: "C2", buffer: buffer)

p1.start()
c1.start()

p2.start()
c2.start()
//: [Next](@next)
