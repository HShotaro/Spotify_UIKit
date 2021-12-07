//
//  APIManager.swift
//  Music2
//
//  Created by Shotaro Hirano on 2021/12/01.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {
        
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    static let baseURL = "https://api.spotify.com/v1"
    
    enum APIError: Error {
        case badURL
        case httpResponseError
    }
    
    private func urlRequest(
        with url: URL?,
        type: HTTPMethod
    ) async throws -> URLRequest  {
        return try await withCheckedThrowingContinuation { continuation in
            AuthManager.shared.withValidToken { token in
                guard let apiURL = url else {
                    continuation.resume(throwing: APIError.badURL)
                    return
                }
                var request = URLRequest(url: apiURL)
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.httpMethod = type.rawValue
                request.timeoutInterval = 30
                continuation.resume(returning: request)
            }
        }
    }
    
    private func urlRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    )  {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    // MARK: - Albums
    
    public func getAlbumDetails(for albumID: String) async throws -> AlbumDetailsResponse {
        let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/albums/\(albumID)"), type: .GET)
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func getCurrentUserAlbums() async throws -> [Album] {
        let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/me/albums"), type: .GET)
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(LibraryAlbumResponse.self, from: data)
                        continuation.resume(returning: result.items.map { $0.album })
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func saveAlbum(album: Album) async throws -> Void {
        let baseRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/me/albums?ids=\(album.id)"), type: .PUT)
        var urlRequest = baseRequest
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                    guard
                        data != nil,
                        error == nil,
                        let code = (response as? HTTPURLResponse)?.statusCode,
                        code >= 200, code <= 202
                    else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    continuation.resume(returning: ())
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func deleteAlbum(album: Album) async throws -> Void {
        let baseRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/me/albums?ids=\(album.id)"), type: .DELETE)
        var urlRequest = baseRequest
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                    guard
                        data != nil,
                        error == nil,
                        let code = (response as? HTTPURLResponse)?.statusCode,
                        code >= 200, code <= 202
                    else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    continuation.resume(returning: ())
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Playlists
    
    public func getCategoryPlayList(categoryID: String) async throws -> [Playlist] {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/browse/categories/\(categoryID)/playlists"), type: .GET)
            
            if #available(iOS 15.0, *) {
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    throw APIError.httpResponseError
                }
                let result = try JSONDecoder().decode(CategoryPlayListResponse.self, from: data)
                return result.playlists.items
            } else {
                return try await withCheckedThrowingContinuation { continuation in
                    let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                        guard let data = data, error == nil else {
                            continuation.resume(throwing: APIError.httpResponseError)
                            return
                        }
                        do {
                            let result = try JSONDecoder().decode(CategoryPlayListResponse.self, from: data)
                            continuation.resume(returning: result.playlists.items)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    task.resume()
                }
            }
        } catch {
            throw error
        }
    }
    
    public func getPlaylistDetails(for playlistID: String) async throws -> PlaylistDetailsResponse {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/playlists/\(playlistID)"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func getArtistTopTracksData(for artistID: String) async throws -> [AudioTrack] {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/artists/\(artistID)/top-tracks?market=JP"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(ArtistTopTracksDataResponse.self, from: data)
                        continuation.resume(returning: result.tracks)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func getCurrentUserPlaylists() async throws -> [Playlist] {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/me/playlists"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(LibraryPlaylistsResponse.self, from: data)
                        continuation.resume(returning: result.items)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func addTrackToPlaylists(track: AudioTrack, playlist: Playlist) async throws -> Void {
        do {
            let baseRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/playlists/\(playlist.id)/tracks"), type: .POST)
            var urlRequest = baseRequest
            let json = [
                "uris": [
                    "spotify:track:\(track.id)"
                ]
            ]
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                            continuation.resume(returning: ())
                        } else {
                            continuation.resume(throwing: APIError.httpResponseError)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func removeTrackFromPlaylists(track: AudioTrack, playlistID: String) async throws -> Void {
        do {
            let baseRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/playlists/\(playlistID)/tracks"), type: .DELETE)
            var urlRequest = baseRequest
            let json: [String: Any] = [
                "tracks":[
                    [
                        "uri": "spotify:track:\(track.id)"
                    ]
                ]
            ]
                
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                            continuation.resume(returning: ())
                        } else {
                            continuation.resume(throwing: APIError.httpResponseError)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func createPlaylists(with name: String) async throws -> Void {
        do {
            let profile = try await getCurrentUserProfile()
            let baseRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/users/\(profile.id)/playlists"), type: .POST)
            var urlRequest = baseRequest
            let json = [
                "name": name
            ]
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let response = result as? [String: Any], response["id"] as? String != nil {
                            continuation.resume(returning: ())
                        } else {
                            continuation.resume(throwing: APIError.httpResponseError)
                        }
                        
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
            
        } catch {
            throw error
        }
    }
    
    
    // MARK: - profile
    
    public func getCurrentUserProfile() async throws -> UserProfile {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/me"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(UserProfile.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Category
    
    public func getCategories() async throws -> [Category] {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/browse/categories?limit=20"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                        continuation.resume(returning: result.categories.items)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Search
    
    public func search(with query: String) async throws -> [SearchResult] {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/search?limit=10&type=album,artist,playlist,track&market=JP&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)

                        let tracks = (result.tracks.items.compactMap{ SearchResult.track(model: $0)})
                        let albums = (result.albums.items.compactMap{ SearchResult.album(model: $0)})
                        let artists = (result.artists.items.compactMap{ SearchResult.artist(model: $0)})
                        let playlists = (result.playlists.items.compactMap{ SearchResult.playlist(model: $0)})

                        let searchResults: [SearchResult] = tracks + albums + artists + playlists
                        continuation.resume(returning: searchResults)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Browse
    
    public func getNewReleases() async throws -> NewReleasesResponse {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/browse/new-releases?limit=50&country=JP"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func getFeaturedPlaylists() async throws -> FeaturedPlaylistsResponse {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/browse/featured-playlists?limit=20&country=JP"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func getRecommendations(genres: Set<String>) async throws -> RecommendationResponse {
        let seeds = genres.joined(separator: ",")
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/recommendations?seed_artists=&seed_genres=\(seeds)&seed_tracks="), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    public func getRecommendationGenres() async throws -> RecommendedGenresResponse {
        do {
            let urlRequest = try await urlRequest(with: URL(string: APIManager.baseURL + "/recommendations/available-genre-seeds"), type: .GET)
            
            return try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        continuation.resume(throwing: APIError.httpResponseError)
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Browse by completion handler
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>)) -> Void) {
        urlRequest(with: URL(string: APIManager.baseURL + "/browse/new-releases?limit=50&country=JP"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.httpResponseError))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(completion: @escaping ((Result<FeaturedPlaylistsResponse, Error>) -> Void)) {
        urlRequest(with: URL(string: APIManager.baseURL + "/browse/featured-playlists?limit=20&country=JP"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.httpResponseError))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationResponse, Error>) -> Void)) {
        let seeds = genres.joined(separator: ",")
        urlRequest(with: URL(string: APIManager.baseURL + "/recommendations?seed_artists=&seed_genres=\(seeds)&seed_tracks="), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.httpResponseError))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationGenres(completion: @escaping ((Result<RecommendedGenresResponse, Error>) -> Void)) {
        urlRequest(with: URL(string: APIManager.baseURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.httpResponseError))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
}
