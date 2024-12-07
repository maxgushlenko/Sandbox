//
//  Untitled.swift
//  Sandbox
//
//  Created by Maksym on 05/12/2024.
//

import Foundation

final class BootCamp {
    let taskHandler = TaskHandler()
    
    init () {
        let intTaskItem = TaskItem { completion in
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1, execute: {
                let result: Result<Any, Error> = .success(2)
                completion(result)
            })
        }
        taskHandler.addTaskItem(intTaskItem)
        
        let stringTaskItem = TaskItem { completion in
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.5, execute: {
                let result: Result<Any, Error> = .success("Hello World")
                completion(result)
            })
        }
        taskHandler.addTaskItem(stringTaskItem)
        
        taskHandler.executeAll { [weak self] in
            self?.taskHandler.taskItems.forEach { print($0.result?.ejectSuccess!) }
        }
    }
}

final class TaskItem: Identifiable {
    private var executeClosure: ExecuteClosure
    private(set) var result: ExecuteResult?
    
    var completion: ResultClosure?
    
    init(_ executeClosure: @escaping ExecuteClosure) {
        self.executeClosure = executeClosure
    }
    
    func execute() {
        executeClosure(executeHandler)
    }
    
    private func executeHandler(result: ExecuteResult) {
        self.result = result
        let value = result.ejectSuccess!
        completion?(result)
    }
}

final class TaskHandler {
    var taskItems: [TaskItem] = []
    
    private let group = DispatchGroup()
    
    func addTaskItem(_ taskItem: TaskItem) {
        taskItems.append(taskItem)
    }
    
    func executeAll(completion: @escaping Closure) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            for item in self?.taskItems ?? [] {
                self?.group.enter()
                item.completion = { _ in
                    self?.group.leave()
                }
                item.execute()
            }
            
            self?.group.notify(queue: .main) {
                completion()
            }
        }
    }
}

typealias Closure = () -> Void

extension TaskItem {
    typealias ExecuteResult = Result<Any, Error>
    typealias ExecuteClosure = (@escaping ResultClosure) -> Void
    typealias ResultClosure = (ExecuteResult) -> Void
}

extension Result {
    var ejectSuccess: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }
    
    var ejectError: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}
