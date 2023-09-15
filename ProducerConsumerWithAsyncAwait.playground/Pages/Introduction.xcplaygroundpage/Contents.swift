/*:
# The Producer Consumer Problem
In computing, the producer-consumer problem (also known as the bounded-buffer problem) is a family of problems described by Edsger W. Dijkstra since 1965.

## Problem

We have “Producers” and “Consumers” sharing a “Common Buffer” of data. All the Producers and the Consumers
will be running on their separate Threads - while producers are inserting and consumers are removing from the buffer.
However the buffer has a maximum number of items it is available to store. So before another producer
can write to the shared buffer he has to wait until another consumer did remove an item and vice versa.

 ![Consumer-Producer](OneProducer-OneConsumer.jpg)
 
## Producer — Consumer code WITHOUT ANY synchronization
  A straight forward approach is to check the queue level before each push and pop operation. When the buffer is full and a  producer tries to push it skips it's operation and retries after a moment. When the buffer is empty and a consumer tries to pop it skips the current operation and waits before he a retry. Of course this algorithm is far from optimal as after a while consumer or producer start polling.
*/
import Foundation

actor Buffer {
    
    private var list: [Int]
    private var size: Int
    
    public init(size: Int = 5) {
        self.size = size
        self.list = [Int]()
    }
    
    public func push(value: Int) -> Bool  {
        guard list.count < size else {
            return false
        }
        list.append(value)
        return true
    }
    
    public func pop() -> (Int?) {
        guard list.count >= 1 else {
            return (nil)
        }
        return (list.removeFirst())
    }

}

// Try here with different buffer sizes
var buffer = Buffer(size: 10)

// Producer lifecycle
Task {
    var counter = 0
    while true {
        if await buffer.push(value: counter) {
            print("push \(counter)")
            counter += 1
        } else {
            print("push of \(counter) failed!")
        }
        sleep(UInt32.random(in: 0...100)/100)
    }
}

// Consumer lifecycle
Task {
    while true {
        let result = await buffer.pop()
        if let result {
            print("pop \(result)")
        } else {
            print("pop failed!")
        }
        sleep(UInt32.random(in: 0...100)/100)
    }
}
/*:
 - Note:
 "When you run producer and consumer you will see that after a while consumer and producer start to fail. The number of fails is more or less the same for producer and consumer - assuming producer and consumer have the same random distribution. We are able to reduce the number of fails by increasing the buffer size. This is the case as the buffer is eleminating random differences in `pop` or `push` operation sequence."
 
 
 So this is a quite good solution when you know the producer and consumer have the same distributions and you did choose the buffer big enough.
 
 This solution is bad when consumer or producer need to be synchronized in some kind. Without sychronization producer or consumer start polling.
 
 */
//: [Next](@next)
