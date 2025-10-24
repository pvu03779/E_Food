//
//  ApiService.swift
//  E-Food
//

import Foundation

// Just some basic errors I might need
enum ApiError: Error {
    case badUrl
    case failedRequest
    case badData
    case decodeError
}

class ApiService {
    
    let apiKey = "5e0356f3b7bd454886811a57765cecf9"
    let baseURL = "https://api.spoonacular.com"
    
    // Decoder thing for JSON
    let decoder = JSONDecoder()
    
    // I made this function to try and reuse it for multiple requests
    private func makeRequest<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        
        // make the url
        guard var components = URLComponents(string: baseURL + endpoint) else {
            throw ApiError.badUrl
        }
        
        var items = queryItems
        items.append(URLQueryItem(name: "apiKey", value: apiKey))
        components.queryItems = items
        
        guard let url = components.url else {
            throw ApiError.badUrl
        }
        
        // actually send it
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // decode json
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            print("decode failed:", error)
            throw ApiError.decodeError
        }
    }
    
    // Trying to get multiple recipes by IDs
    func getRecipesByIds(_ ids: [Int]) async throws -> [RecipeDetail] {
        if ids.isEmpty {
            return []
        }
        
        let joinedIds = ids.map { "\($0)" }.joined(separator: ",")
        let items = [
            URLQueryItem(name: "ids", value: joinedIds)
        ]
        
        let result: [RecipeDetail] = try await makeRequest(
            endpoint: "/recipes/informationBulk",
            queryItems: items
        )
        return result
    }
    
    // search recipes
    func searchRecipes(name: String? = nil, cuisine: String? = nil) async throws -> [Recipe] {
        var items = [
            URLQueryItem(name: "number", value: "10"),
            URLQueryItem(name: "addRecipeInformation", value: "true")
        ]
        
        if let name = name, !name.isEmpty {
            items.append(URLQueryItem(name: "query", value: name))
        } else if let cuisine = cuisine {
            items.append(URLQueryItem(name: "cuisine", value: cuisine))
        }
        
        let response: ApiResponse = try await makeRequest(
            endpoint: "/recipes/complexSearch",
            queryItems: items
        )
        
        return response.results
    }
    
    // get one recipe
    func getRecipeDetails(id: Int) async throws -> RecipeDetail {
        let items = [
            URLQueryItem(name: "includeNutrition", value: "true")
        ]
        
        let recipe: RecipeDetail = try await makeRequest(
            endpoint: "/recipes/\(id)/information",
            queryItems: items
        )
        return recipe
    }
    
    // video fetching (not sure if this works)
    func getVideo(query: String) async throws -> VideoInfo? {
        let items = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "number", value: "1")
        ]
        
        let response: VideoSearchResponse = try await makeRequest(
            endpoint: "/food/videos/search",
            queryItems: items
        )
        
        return response.videos.first
    }
}
