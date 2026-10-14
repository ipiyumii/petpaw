//
//  healthAnalysisService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-14.
//


import Vision
import CoreML
import UIKit

struct HealthScanResult {
    let condition: String
    let confidence: Double
}

protocol HealthAnalysisServiceProtocol {
    func analyze(_ image: UIImage) async throws -> HealthScanResult
}

class HealthAnalysisService: HealthAnalysisServiceProtocol {

    enum AnalysisError: LocalizedError {
        case invalidImage
        case noResult

        var errorDescription: String? {
            switch self {
                case .invalidImage:
                    return "Couldn't read this photo."
                case .noResult:
                    return "Couldn't find anything to report."
                }
        }
    }

    func analyze(_ image: UIImage) async throws -> HealthScanResult {

        guard let cgImage = image.cgImage 
        else 
        {
            throw AnalysisError.invalidImage
        }

        let result = try await Task.detached {
            let config = MLModelConfiguration()
            let coreModel = try PetConditionClassifier_1(configuration: config)
            let model = try VNCoreMLModel(for: coreModel.model)

            let request = VNCoreMLRequest(model: model)
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            try handler.perform([request])

            guard let results = request.results as? [VNClassificationObservation],let first = results.first 
            else 
            {
                throw AnalysisError.noResult
            }

            return HealthScanResult(
                condition: first.identifier,
                confidence: Double(first.confidence)
            )
        }.value

        return result
    }
}

