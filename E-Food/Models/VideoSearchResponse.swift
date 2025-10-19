//
//  VideoSearchResponse.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import Foundation

// Represents the top-level response from the video search API.
struct VideoSearchResponse: Decodable {
    let videos: [VideoInfo]
}

struct VideoInfo: Decodable, Identifiable {
    let title: String
    let youTubeId: String

    var id: String { youTubeId }
}
