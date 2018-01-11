//
//  ViewController.swift
//  Swift-Upload
//
//  Created by Ivan Almada on 11/01/2018.
//  Copyright © 2018 Ivan. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    var responseData = Data()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let filename = "image_uploaded_from_ios2"

        let bundle = Bundle.main
        let path = bundle.path(forResource: filename, ofType: "mp4")
        let url = URL(fileURLWithPath: path!)

        do {
            let data = try Data(contentsOf: url)
            let fileString = "http://127.0.0.1:8000/\(filename)"
            var request = URLRequest(url: URL(string: fileString)!)
            request.httpMethod = "POST"
            request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")

            // If you have a large file better use streaming upload with chunked header
            // request.setValue(“application/octet-stream”, forHTTPHeaderField: “Content-Type”)
            // request.HTTPBodyStream = NSInputStream(data: data)

            // If the request fails then the session will not able to rewind the stream
            // so you must provide a new stream in the event the session must retry the request
            // by providing the method: URLSession:task:needNewBodyStream:.


            uploadFiles(request, data: data)
        } catch {
            print("Failed to create the data to upload.")
        }

    }

    // MARK: - Upload

    func uploadFiles(_ request: URLRequest, data: Data) {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.uploadTask(with: request, from: data)
        task.resume()
    }

    // MARK: - URLSession task delegate

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("session \(session) occurred error \(error.localizedDescription)")
        } else {
            let string = String(data: responseData, encoding: String.Encoding.utf8)!
            print("session \(session) upload completed, response \(string)")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress = Double(totalBytesSent) / Double(totalBytesExpectedToSend) * 100
        print("session \(session) uploaded \(uploadProgress)%.")
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("session \(session), received response \(response)")
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData.append(data)
    }

}
