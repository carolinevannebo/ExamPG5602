//
//  FlagAPIClient.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 26/11/2023.
//

import Foundation
import UIKit

struct FlagAPIClient {
    
    static func getFlag(countryCode: CountryCode, flagStyle: FlagStyle, flagSize: FlagSize) async throws -> UIImage? {
        do {
            let fullEndpoint = "https://flagsapi.com/\(countryCode)/\(flagStyle)/\(flagSize).png"
            
            let data = try await APIClient.getJson(endpoint: fullEndpoint)
            
            guard let uiImage = UIImage(data: data) else {
                throw FlagAPIClientError.invalidImageData
            }
            
            return uiImage
        } catch {
            print("Unexpected error when fetching flag: \(error)")
            return nil
        }
    }
    
    enum FlagAPIClientError: Error {
        case invalidImageData
    }
    
    enum FlagStyle: String {
        case flat
        case shiny
    }
    
    enum FlagSize: String {
        case xsmall = "16"
        case small = "24"
        case regular = "32"
        case large = "48"
        case xlarge = "64"
    }
    
    enum CountryCode: String {
        case american = "US"
        case british = "GB"
        case canadian = "CA"
        case chinese = "CN"
        case croatian = "HR"
        case dutch = "NL"
        case egyptian = "EG"
        case filipino = "PH"
        case french = "FR"
        case greek = "GR"
        case indian = "IN"
        case irish = "IE"
        case italian = "IT"
        case jamaican = "JM"
        case japanese = "JP"
        case kenyan = "KE"
        case malaysian = "MY"
        case mexican = "MX"
        case moroccan = "MA"
        case polish = "PL"
        case portuguese = "PT"
        case russian = "RU"
        case spanish = "ES"
        case thai = "TH"
        case tunisian = "TN"
        case turkish = "TR"
        case vietnamese = "VN"
        case unknown
    }

}
