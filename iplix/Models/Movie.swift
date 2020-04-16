//
//  Movie.swift
//  iplix
//
//  Created by TEMP on 4/7/20.
//  Copyright © 2020 aldovernando. All rights reserved.
//

import Foundation

// model to fetch JSON object result
struct Results: Decodable {
    let page: Int
    let results: [Movie]
}


// model to fetch JSON object movie
struct Movie: Decodable {
    let popularity: Double?
    let vote_count: Int?
    let poster_path: String?
    let id: Int?
    let backdrop_path: String?
    let title: String?
    let genre_ids: [Int]?
    let overview: String?
    let release_date: String?
    let vote_average: Double?
}
