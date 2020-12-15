//
//  ProgressTask.swift
//  
//
//  Created by Gal Yedidovich on 15/12/2020.
//

import Foundation
public class ProgressTask {
	public let progress: Progress
	public let task: URLSessionTask?
	
	public init(totalUnitCount count: Int64) {
		progress = Progress(totalUnitCount: count)
		task = nil
	}
	
	public init(from task: URLSessionTask) {
		progress = task.progress
		self.task = task
	}
	
	public func cancel() {
		task?.cancel()
		progress.cancel()
	}
}
