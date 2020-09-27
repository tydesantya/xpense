//
//  APIService.swift
//  Covid-ID
//
//  Created by Teddy Santya on 1/5/20.
//  Copyright © 2020 Teddy Santya. All rights reserved.
//

import Foundation


extension APIManager {

    static let newsAPIKey:String = "e24d881cdf90482ca185e1a3cfbaf22f"
    
    enum Service: TargetType {
        
        var baseURL: String {
            let githubNovelCovidAPI = "https://corona.lmao.ninja"
            let kawalCovidAPI = "https://api.kawalcorona.com"
            let newsAPI = "https://newsapi.org"
            
            switch self {
            case .todayIndonesiaCase:
                return githubNovelCovidAPI
            case .provinceCases:
                return kawalCovidAPI
            case .indonesiaHeadlinesNews, .indonesiaHeadlinesNewsCovid:
                return newsAPI
            }
        }
        
        var headers: [String:String]? {
            return ["Accept":"application/json"]
        }
        
        // cases
        case todayIndonesiaCase
        case provinceCases
        case indonesiaHeadlinesNews
        case indonesiaHeadlinesNewsCovid
        
        var path: String {
            switch self {
            case .todayIndonesiaCase:
                return "/v2/countries/Indonesia?yesterday=false&strict=true&query="
            case .provinceCases:
                return "/indonesia/provinsi"
            case .indonesiaHeadlinesNews:
                return "/v2/top-headlines?country=id&apiKey=\(APIManager.newsAPIKey)&q=corona"
            case .indonesiaHeadlinesNewsCovid:
                return "/v2/top-headlines?country=id&apiKey=\(APIManager.newsAPIKey)&q=covid"
            }
        }
        
        var method: APIMethod {
            switch self {
            default:
                return .get
            }
        }
    }
}
