//
//  Tag.swift
//  MetaImageParsing
//
//  Created by inforex on 2022/11/14.
//

import Foundation

enum Tag{
    case content
    case image
    case title
    case description
    case url
    case host
    case appURL
    case appStoreID
    case appName

    var query : String{
        switch self{
        case .content: return "content"
        case .image: return "meta[property=og:image]"
        case .title: return "meta[property=og:title]"
        case .description: return "meta[property=og:description]"
        case .url: return "meta[property=og:url]"
        case .host: return ""
        case .appURL: return "meta[property=al:ios:url]"
        case .appStoreID: return "meta[property=al:ios:app_store_id]"
        case .appName: return "meta[property=al:ios:app_name]"
        }
    }
}
