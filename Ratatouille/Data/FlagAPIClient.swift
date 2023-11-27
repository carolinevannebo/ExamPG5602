//
//  FlagAPIClient.swift
//  Ratatouille
//
//  Created by Caroline Vannebo on 26/11/2023.
//

import Foundation
import UIKit
import Nuke

struct FlagAPIClient {
    
    static func getFlag(countryCode: CountryCode, flagStyle: FlagStyle, flagSize: FlagSize) async throws -> UIImage? {
        do {
            let endpoint: String = "https://flagsapi.com/\(countryCode.rawValue)/\(flagStyle)/\(flagSize.rawValue).png"
            
            let url: URL = URL(string: endpoint)!
            
            let response = try await ImagePipeline.shared.image(for: url)
            
            return response
            
        } catch {
            print("Unexpected error when fetching flag: \(error)")
            throw FlagAPIClientError.invalidImageData
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

    enum CountryCode: String, CodingKey {
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
        
        static let nameToCode: [String: CountryCode] = [
            "american": .american,
            "british": .british,
            "canadian": .canadian,
            "chinese": .chinese,
            "croatian": .croatian,
            "dutch": .dutch,
            "egyptian": .egyptian,
            "filipino": .filipino,
            "french": .french,
            "greek": .greek,
            "indian": .indian,
            "irish": .irish,
            "italian": .italian,
            "jamaican": .jamaican,
            "japanese": .japanese,
            "kenyan": .kenyan,
            "malaysian": .malaysian,
            "mexican": .mexican,
            "moroccan": .moroccan,
            "polish": .polish,
            "portuguese": .portuguese,
            "russian": .russian,
            "spanish": .spanish,
            "thai": .thai,
            "tunisian": .tunisian,
            "turkish": .turkish,
            "vietnamese": .vietnamese
        ]

    }

}
