//
//  ViewController.swift
//  TextDectector
//
//  Created by Brian Surgenor on 08/06/2020.
//  Copyright © 2020 Brian Surgenor. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController {

    @IBOutlet weak var resultsLabel: UILabel!
    let documentCameraViewController = VNDocumentCameraViewController()
    var textRecognitionRequest = VNRecognizeTextRequest()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        documentCameraViewController.delegate = self
        
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: detectedTextHandler)
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.revision = VNRecognizeTextRequestRevision1
        textRecognitionRequest.usesLanguageCorrection = true
        
        resultsLabel.lineBreakMode = .byWordWrapping
        resultsLabel.numberOfLines = 0
    }

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        resultsLabel.text = ""
        self.present(documentCameraViewController, animated: true)
    }
    
    //Get the image from the controller and try to kick off the text recognition handler
    private func recognizeTextInImage(_ image: UIImage?) {
        guard let cgImage = image?.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            print(error)
            return
        }
    }
    
    private func detectedTextHandler(request: VNRequest?, error: Error?) {
        if let error = error {
            //Should prolly do something proper
            print("ERROR: \(error)")
            return
        }
        
        guard let results = request?.results, !results.isEmpty else {
            //Should prolly do something proper
            print("No text found")
            return
        }
        
        var scannedText = ""
        for result in results {
            guard let observation = result as? VNRecognizedTextObservation else { return }
            guard let candidiate = observation.topCandidates(1).first else { return }
            
            do {
                let box = try candidiate.boundingBox(for: candidiate.string.range(of: candidiate.string)!)
                let doubley = Double(box!.topLeft.y)
                let doublex = round(100*Double(box!.topLeft.x))/100
                
                scannedText.append(contentsOf: "text: \(candidiate.string) \n")
            } catch {
                //Should prolly do something proper
                print(error)
            }
        }
        
        self.resultsLabel.text = scannedText
        print(scannedText)
    }
}

extension ViewController: VNDocumentCameraViewControllerDelegate {
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) {
            DispatchQueue.main.async {
                let image = scan.imageOfPage(at: 0)
                self.recognizeTextInImage(image)
            }
        }
    }
}

