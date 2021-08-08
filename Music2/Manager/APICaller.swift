//
//  APICaller.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import Foundation


final class APICaller {
    static let shared = APICaller()
    
    private init () {}
    
    struct Constants {
        static let baseURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    // MARK: - Albums
    
    public func getAlbumDetails(for albumID: String, completion: @escaping (Result<AubumDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/albums/\(albumID)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AubumDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Playlists
    
    public func getPlaylistDetails(for playlistID: String, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/playlists/\(playlistID)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getArtistTopTracksData(for artistID: String, completion: @escaping (Result<[AudioTrack], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/artists/\(artistID)/top-tracks?market=JP"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(ArtistTopTracksDataResponse.self, from: data)
                    completion(.success(result.tracks))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - profile
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/me"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Browse
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>)) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/new-releases?limit=50&country=JP"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
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
        createRequest(with: URL(string: Constants.baseURL + "/browse/featured-playlists?limit=20&country=JP"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
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
        createRequest(with: URL(string: Constants.baseURL + "/recommendations?seed_artists=&seed_genres=\(seeds)&seed_tracks="), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
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
        createRequest(with: URL(string: Constants.baseURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
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
    
    // MARK: - Category
    
    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/categories?limit=20"), type: .GET) { [weak self] request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoryPlayList(categoryID: String, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/categories/\(categoryID)/playlists"), type: .GET) { [weak self] request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(CategoryPlayListResponse.self, from: data)
                    completion(.success(result.playlists.items))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Search
    
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/search?limit=10&type=album,artist,playlist,track&market=JP&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { [weak self] request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)

                    let tracks = (result.tracks.items.compactMap{ SearchResult.track(model: $0)})
                    let albums = (result.albums.items.compactMap{ SearchResult.album(model: $0)})
                    let artists = (result.artists.items.compactMap{ SearchResult.artist(model: $0)})
                    let playlists = (result.playlists.items.compactMap{ SearchResult.playlist(model: $0)})

                    let searchResults: [SearchResult] = tracks + albums + artists + playlists
                    completion(.success(searchResults))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Private
    
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    )  {
        AuthManager.shared.withValidToken { [weak self] token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        } 
    }
}
