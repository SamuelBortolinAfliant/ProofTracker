//
//  ImageClassifier.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import Foundation
import UIKit
import Vision
import CoreML

final class ImageClassifier {
    
    static func classify(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(ImageClassifierError.invalidImage))
            return
        }
        
        // Create a Vision request for FastViTMA36F16 classification
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all  // Use all available compute units
            config.allowLowPrecisionAccumulationOnGPU = true  // Allow GPU optimization
            
            let model = try VNCoreMLModel(for: FastViTMA36F16(configuration: config).model)
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Process FastViTMA36F16 results - it returns classification results
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    completion(.failure(ImageClassifierError.noResults))
                    return
                }
                
                // Return the top classification identifier
                let classification = topResult.identifier
                completion(.success(classification))
            }
            
            // Configure the request for FastViTMA36F16
            // FastViTMA36F16 expects 256x256 images and uses center crop
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
            
            // Create a request handler and perform the request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Custom Errors
enum ImageClassifierError: Error, LocalizedError {
    case invalidImage
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The provided image is invalid or cannot be processed."
        case .noResults:
            return "No classification results were found for the image."
        }
    }
}
