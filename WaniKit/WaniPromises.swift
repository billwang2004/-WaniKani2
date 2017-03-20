//
//  WaniPromises.swift
//  WaniKani
//
//  Created by Andriy K. on 3/17/17.
//  Copyright © 2017 haawa. All rights reserved.
//

import Foundation
import Promise

public struct WaniPromises {

  public static func newFetchPromise(url: URL) -> Promise<(Data, HTTPURLResponse)> {
    return Promise<(Data, HTTPURLResponse)>(work: { fulfill, reject in
      self.dataTask(url: url, completionHandler: { data, response, error in
        if let error = error {
          reject(error)
        } else if let data = data, let response = response as? HTTPURLResponse {
          fulfill((data, response))
        } else {
          fatalError("Something has gone horribly wrong.")
        }
      }).resume()
    })
  }

  public static func newParsePromise(data: Data) -> Promise<(WaniParsedData)> {
    return Promise<(WaniParsedData)>(work: { fulfill, reject in
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      guard let root = json as? [String : Any] else {
        reject(ParsingError.noRoot)
        return
      }
      try fulfill(WaniParsedData(root: root))
    })
  }

  private static func dataTask(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    let request = URLRequest(url: url)
    return session.dataTask(with: request, completionHandler: completionHandler)
  }
}
