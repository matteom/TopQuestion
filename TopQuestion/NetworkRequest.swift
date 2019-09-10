//
//  NetworkRequest.swift
//  TopQuestion
//
//  Created by Matteo Manferdini on 12/09/2019.
//  Copyright © 2019 Matteo Manferdini. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkRequest: AnyObject {
	associatedtype ModelType
	func decode(_ data: Data) -> ModelType?
	func load(withCompletion completion: @escaping (ModelType?) -> Void)
}

extension NetworkRequest {
	fileprivate func load(_ url: URL, withCompletion completion: @escaping (ModelType?) -> Void) {
		let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
		let task = session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
			guard let data = data else {
				completion(nil)
				return
			}
			completion(self?.decode(data))
		})
		task.resume()
	}
}

class ImageRequest {
	let url: URL
	
	init(url: URL) {
		self.url = url
	}
}

extension ImageRequest: NetworkRequest {
	func decode(_ data: Data) -> UIImage? {
		return UIImage(data: data)
	}
	
	func load(withCompletion completion: @escaping (UIImage?) -> Void) {
		load(url, withCompletion: completion)
	}
}

class APIRequest<Resource: APIResource> {
	let resource: Resource
	
	init(resource: Resource) {
		self.resource = resource
	}
}

extension APIRequest: NetworkRequest {
	func decode(_ data: Data) -> [Resource.ModelType]? {
		let wrapper = try? JSONDecoder().decode(Wrapper<Resource.ModelType>.self, from: data)
		return wrapper?.items
	}
	
	func load(withCompletion completion: @escaping ([Resource.ModelType]?) -> Void) {
		load(resource.url, withCompletion: completion)
	}
}

protocol APIResource {
	associatedtype ModelType: Decodable
	var methodPath: String { get }
}

extension APIResource {
	var url: URL {
		var components = URLComponents(string: "https://api.stackexchange.com/2.2")!
		components.path = methodPath
		components.queryItems = [
			URLQueryItem(name: "site", value: "stackoverflow"),
			URLQueryItem(name: "order", value: "desc"),
			URLQueryItem(name: "sort", value: "votes"),
			URLQueryItem(name: "tagged", value: "ios")
		]
		return components.url!
	}
}

struct QuestionsResource: APIResource {
	typealias ModelType = Question
	let methodPath = "/questions"
}
