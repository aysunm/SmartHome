//
//  HomeData.swift
//  SmartHome
//
//  Created by Aysun Molla on 30.06.2021.
//

import Foundation

//struct ResultArray: Decodable {
//    let results = [HomeData]
//}

struct HomeData: Decodable {
    let action: String
    let action_needed: String
    let category: String
    let question: String
    let sub_category: String
    let time: String
}
