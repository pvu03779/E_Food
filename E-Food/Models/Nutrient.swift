//
//  Nutrient.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import Foundation

struct Nutrient: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let amount: Double
    let unit: String
}
