//
//  YoutubePlayerView.swift
//  YoutubePlayerView
//
//  Copyright (c) 2018 Mukesh Yadav <mails4ymukesh@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#if os(iOS)
import UIKit
import WebKit

public protocol YoutubePlayerViewDelegate: class {
    /// Invoked when the player view is ready to receive API calls.
    ///
    /// - Parameter playerView: The `YoutubePlayerView` instance that has become ready.
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView)
    
    /// Callback invoked when player state has changed, e.g. stopped or started playback.
    ///
    /// - Parameters:
    ///   - playerView: The `YoutubePlayerView` instance where playback state has changed.
    ///   - state: `YoutubePlayerState` designating the new playback state.
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState)
    
    /// Callback invoked when playback quality has changed.
    ///
    /// - Parameters:
    ///   - playerView: The `YoutubePlayerView` instance where playback quality has changed.
    ///   - quality: `YoutubePlaybackQuality` designating the new playback quality.
    func playerView(_ playerView: YoutubePlayerView, didChangeToQuality quality: YoutubePlaybackQuality)
    
    /// Callback invoked when an error has occured.
    ///
    /// - Parameters:
    ///   - playerView: The `YoutubePlayerView` instance where the error has occurred.
    ///   - error: `YoutubePlayerError` containing the error state.
    func playerView(_ playerView: YoutubePlayerView, receivedError error: Error)
    
    /// Callback invoked frequently when playBack is plaing.
    ///
    /// - Parameters:
    ///   - playerView: The `YoutubePlayerView` instance where the error has occurred.
    ///   - time: containing curretn playback time.
    func playerView(_ playerView: YoutubePlayerView, didPlayTime time: Float)
    
    /// Callback invoked when setting up the webview to allow custom colours so it fits in with app color schemes. If a transparent view is required specify clearColor and the code will handle the opacity etc.
    ///
    /// - Parameter playerView: `YoutubePlayerView` setting up.
    /// - Returns: A `UIColor` object that represents the background color of the webview.
    func playerViewPreferredBackgroundColor(_ playerView: YoutubePlayerView) -> UIColor
}

public extension YoutubePlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YoutubePlayerView) { }
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) { }
    func playerView(_ playerView: YoutubePlayerView, didChangeToQuality quality: YoutubePlaybackQuality) { }
    func playerView(_ playerView: YoutubePlayerView, receivedError error: Error) { }
    func playerView(_ playerView: YoutubePlayerView, didPlayTime time: Float) { }
    func playerViewPreferredBackgroundColor(_ playerView: YoutubePlayerView) -> UIColor { return .systemBackground }
    func playerViewPreferredInitialLoadingView(_ playerView: YoutubePlayerView) -> UIView? { return nil }
}

open class YoutubePlayerView: WKWebView {
    public weak var delegate: YoutubePlayerViewDelegate?
    
    public required init?(coder: NSCoder) {
        var config: WKWebViewConfiguration {
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            
            let webConfiguration = WKWebViewConfiguration()
            webConfiguration.preferences = preferences
            
            if #available(iOS 10.0, *) {
                webConfiguration.mediaTypesRequiringUserActionForPlayback = []
            } else {
                webConfiguration.requiresUserActionForMediaPlayback = false
            }
            
            webConfiguration.allowsInlineMediaPlayback = true
            return webConfiguration
        }
        
        super.init(frame: .zero, configuration: config)
        
        scrollView.isScrollEnabled = false
        contentMode = .scaleAspectFit
        scrollView.bounces = false
        navigationDelegate = self
    }
    
    private func createVideoUrlString(_ videoId: String, from args: [String: Any]?) -> (String, String) {
        let params = args?.reduce("") { prev, next in
            var value = next.value
            
            if let string = (value as? String)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                value = string
            }
            
            return prev! + "\(next.key)=\(value)&"
        } ?? ""
        
        return ("https://www.youtube.com/embed/"+videoId+"?\(params)enablejsapi=1",
            (args?["origin"] as? String) ?? "")
    }
    
    private func createPlaylistUrlString(_ playlistId: String, from args: [String: Any]?) -> (String, String) {
        let params = args?.reduce("") { prev, next in
            var value = next.value
            
            if let string = value as? String {
                value = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) as Any
            }
            
            return prev! + "\(next.key)=\(value)&"
            } ?? ""
        
        return ("https://www.youtube.com/embed?listType=playlist&list=\(playlistId)&\(params)enablejsapi=1",
            (args?["origin"] as? String) ?? "")
    }
    
    private func loadPlayer(with url: (String, String)) {
        
        func load(with url: (String, String)) {
            if let color = delegate?.playerViewPreferredBackgroundColor(self) {
                backgroundColor = color
                if color == UIColor.clear {
                    isOpaque = false
                }
            }
            
            let htmlString = String(format: YoutubePlayerUtils.htmlString, url.0)
            loadHTMLString(htmlString, baseURL: URL(string: url.1))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { () -> Void in
            load(with: url)
        })
    }
    
    /// This method loads the player with the given video ID and player variables. Player variables
    /// specify optional parameters for video playback. For instance, to play a YouTube
    /// video inline, the following playerVars dictionary would be used:
    ///
    /// let vars = ["playsinline" : 1]
    ///
    /// Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
    /// both strings and integers are valid values. The full list of parameters is defined at:
    ///   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
    ///
    ///
    /// This method reloads the entire contents of the `WKWebView` and regenerates its HTML contents.
    /// To change the currently loaded video without reloading the entire `WKWebView`, use the
    /// `cueVideoById(_:startSeconds:suggestedQuality:)` family of methods.
    ///
    /// - Parameters:
    ///   - videoId: The YouTube video ID of the video to load in the player view.
    ///   - parArgs: A `Dictionary` of player parameters.
    public func loadWithVideoId(_ videoId: String, with parArgs: [String: Any]? = nil) {
        let link = createVideoUrlString(videoId, from: parArgs)
        loadPlayer(with: link)
    }
    
    /// This method loads the player with the given playlist ID and player variables. Player variables
    /// specify optional parameters for video playback. For instance, to play a YouTube
    /// video inline, the following playerVars dictionary would be used:
    ///
    /// let vars = ["playsinline" : 1]
    ///
    /// Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
    /// both strings and integers are valid values. The full list of parameters is defined at:
    ///   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
    ///
    ///
    /// This method reloads the entire contents of the `WKWebView` and regenerates its HTML contents.
    /// To change the currently loaded video without reloading the entire `WKWebView`, use the
    /// `cueVideoById(_:startSeconds:suggestedQuality:)` family of methods.
    ///
    /// - Parameters:
    ///   - playlistId: The YouTube playlist ID of the playlist to load in the player view.
    ///   - parArgs: A `Dictionary` of player parameters.
    public func loadWithPlaylistId(_ playlistId: String, with parArgs: [String: Any]? = nil) {
        let link = createPlaylistUrlString(playlistId, from: parArgs)
        loadPlayer(with: link)
    }
}

extension YoutubePlayerView {
    /// Starts or resumes playback on the loaded video. Corresponds to this method from
    /// the JavaScript API:
    ///   `https://developers.google.com/youtube/iframe_api_reference#playVideo`
    public func play() {
        evaluateJavaScript("player.playVideo();", completionHandler: nil)
    }
    
    /// Pauses playback on a playing video. Corresponds to this method from
    /// the JavaScript API:
    ///   `https://developers.google.com/youtube/iframe_api_reference#pauseVideo`
    public func pause() {
        notifyDelegate(for: URL(string: "ytplayer://onStateChange?data=\(YoutubePlayerState.paused.rawValue)")!)
        evaluateJavaScript("player.pauseVideo();", completionHandler: nil)
    }
    
    /// Stops playback on a playing video. Corresponds to this method from
    /// the JavaScript API:
    ///   `https://developers.google.com/youtube/iframe_api_reference#stopVideo`
    public func stop() {
        evaluateJavaScript("player.stopVideo();", completionHandler: nil)
    }
    
    /// Seek to a given time on a playing video. Corresponds to this method from
    /// the JavaScript API:
    ///   `https://developers.google.com/youtube/iframe_api_reference#seekTo`
    ///
    /// - Parameters:
    ///   - seconds: The time in seconds to seek to in the loaded video.
    ///   - allowSeekAhead: Whether to make a new request to the server if the time is outside what is currently buffered. Recommended to set to YES.
    public func seek(to seconds: Float, allowSeekAhead: Bool) {
        let command = "player.seekTo(\(seconds), \(allowSeekAhead));"
        evaluateJavaScript(command, completionHandler: nil)
    }
}

// MARK:- Cueing methods
extension YoutubePlayerView {
    
    /// Loads a given video by its video ID for playback starting at the given time and with the
    /// suggested quality. Loading a video both loads it and begins playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#loadVideoById`
    ///
    /// - Parameters:
    ///   - videoId: A video ID to load and begin playing.
    ///   - startSeconds: Time in seconds to start the video when `play` is called.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func loadVideoById(_ videoId: String, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        let command = "player.loadVideoById('\(videoId)', \(startSeconds), '\(quality.rawValue)');"
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Loads a given video by its video ID for playback starting and ending at the given times
    /// with the suggested quality. Loading a video both loads it and begins playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#loadVideoById`
    ///
    /// - Parameters:
    ///   - videoId: A video ID to load and begin playing.
    ///   - startSeconds: Time in seconds to start the video when `play` is called.
    ///   - endSeconds: Time in seconds to end the video after it begins playing.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func loadVideoById(_ videoId: String, startSeconds: Float, endSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        let command = "player.loadVideoById({'videoId': '\(videoId)', 'startSeconds': \(startSeconds), 'endSeconds': \(endSeconds), 'suggestedQuality': '\(quality.rawValue)'});"
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Cues a given video by its video ID for playback starting at the given time and with the
    /// suggested quality. Cueing loads a video, but does not start video playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#cueVideoById`
    ///
    /// - Parameters:
    ///   - videoId: A video ID to cue.
    ///   - startSeconds: Time in seconds to start the video when `play` is called.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func cueVideoById(_ videoId: String, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        let command = "player.cueVideoById('\(videoId)', \(startSeconds), '\(quality.rawValue)');"
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Cues a given video by its video ID for playback starting and ending at the given times with the
    /// suggested quality. Cueing loads a video, but does not start video playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#cueVideoById`
    ///
    /// - Parameters:
    ///   - videoId: A video ID to cue.
    ///   - startSeconds: Time in seconds to start the video when `play` is called.
    ///   - endSeconds: Time in seconds to end the video after it begins playing.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func cueVideoById(_ videoId: String, startSeconds: Float, endSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        let command = "player.cueVideoById({'videoId': '\(videoId)', 'startSeconds': \(startSeconds), 'endSeconds': \(endSeconds), 'suggestedQuality': '\(quality.rawValue)'});"
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Loads a given video by its video ID for playback starting and ending at the given times
    /// with the suggested quality. Loading a video both loads it and begins playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#loadVideoByUrl`
    ///
    /// - Parameters:
    ///   - videoId: A video ID to load and begin playing.
    ///   - startSeconds: Time in seconds to start the video when `play` is called.
    ///   - endSeconds: Time in seconds to end the video after it begins playing.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func loadVideoByUrl(_ videoUrl: String, startSeconds: Float, endSeconds: Float? = nil, suggestedQuality quality: YoutubePlaybackQuality) {
        let command: String
        if let endSeconds = endSeconds {
            command = "player.loadVideoByUrl('\(videoUrl)', \(startSeconds), \(endSeconds), '\(quality.rawValue)');"
        } else {
            command = "player.loadVideoByUrl('\(videoUrl)', \(startSeconds), '\(quality.rawValue)');"
        }
        
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Cues a given video by its URL on YouTube.com for playback starting at the given time
    /// and with the suggested quality. Cueing loads a video, but does not start video playback.
    /// This method corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#cueVideoByUrl`
    ///
    /// - Parameters:
    ///   - videoId: A video ID to cue.
    ///   - startSeconds: Time in seconds to start the video when `play` is called.
    ///   - endSeconds: Time in seconds to end the video after it begins playing.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func cueVideoByUrl(_ videoUrl: String, startSeconds: Float, endSeconds: Float? = nil, suggestedQuality quality: YoutubePlaybackQuality) {
        let command: String
        if let endSeconds = endSeconds {
            command = "player.cueVideoByUrl('\(videoUrl)', \(startSeconds), \(endSeconds), '\(quality.rawValue)');"
        } else {
            command = "player.cueVideoByUrl('\(videoUrl)', \(startSeconds), '\(quality.rawValue)');"
        }
        
        evaluateJavaScript(command, completionHandler: nil)
    }
}

// MARK:- Cueing methods for lists
extension YoutubePlayerView {
    /// Cues a given playlist with the given ID. The |index| parameter specifies the 0-indexed
    /// position of the first video to play, starting at the given time and with the
    /// suggested quality. Cueing loads a playlist, but does not start video playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#cuePlaylist`
    ///
    /// - Parameters:
    ///   - playlistId: Playlist ID of a YouTube playlist to cue.
    ///   - index: A 0-indexed position specifying the first video to play.
    ///   - startSeconds: Time in seconds to start the video when YTPlayerView::playVideo is called.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func cuePlaylistByPlaylistId(_ playlistId: String, index: Int=0, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        cuePlaylist("'\(playlistId)'", index: index, startSeconds: startSeconds, suggestedQuality: quality)
    }
    
    /// Cues a playlist of videos with the given video IDs. The |index| parameter specifies the
    /// 0-indexed position of the first video to play, starting at the given time and with the
    /// suggested quality. Cueing loads a playlist, but does not start video playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#cuePlaylist`
    ///
    /// - Parameters:
    ///   - videoIds: An `Array` of video IDs to compose the playlist of.
    ///   - index: A 0-indexed position specifying the first video to play.
    ///   - startSeconds: Time in seconds to start the video when YTPlayerView::playVideo is called.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func cuePlaylistByVideos(_ videoIds: [String], index: Int=0, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        cuePlaylist("'\(videoIds.description)'", index: index, startSeconds: startSeconds, suggestedQuality: quality)
    }
    
    private func cuePlaylist(_ playlistIdString: String, index: Int, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        let command = "player.cuePlaylist(\(playlistIdString), \(index), \(startSeconds), '\(quality.rawValue)');"
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Loads a given playlist with the given ID. The |index| parameter specifies the 0-indexed
    /// position of the first video to play, starting at the given time and with the
    /// suggested quality. Loading a playlist starts video playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#loadPlaylist`
    ///
    /// - Parameters:
    ///   - playlistId: Playlist ID of a YouTube playlist to load.
    ///   - index: A 0-indexed position specifying the first video to play.
    ///   - startSeconds: Time in seconds to start the video when YTPlayerView::playVideo is called.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func loadPlaylistPlaylistId(_ playlistId: String, index: Int=0, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        loadPlaylist("'\(playlistId)'", index: index, startSeconds: startSeconds, suggestedQuality: quality)
    }
    
    /// Loads a playlist of videos with the given video IDs. The |index| parameter specifies the
    /// 0-indexed position of the first video to play, starting at the given time and with the
    /// suggested quality. Loading a playlist starts video playback. This method
    /// corresponds with its JavaScript API equivalent as documented here:
    ///    `https://developers.google.com/youtube/iframe_api_reference#loadPlaylist`
    ///
    /// - Parameters:
    ///   - videoIds: An `Array` of video IDs to compose the playlist of.
    ///   - index: A 0-indexed position specifying the first video to play.
    ///   - startSeconds: Time in seconds to start the video when YTPlayerView::playVideo is called.
    ///   - quality: `YoutubePlaybackQuality` value suggesting a playback quality.
    public func loadPlaylistByVideos(_ videoIds: [String], index: Int=0, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        loadPlaylist("'\(videoIds.description)'", index: index, startSeconds: startSeconds, suggestedQuality: quality)
    }
    
    private func loadPlaylist(_ playlistIdString: String, index: Int, startSeconds: Float, suggestedQuality quality: YoutubePlaybackQuality) {
        let command = "player.loadPlaylist(\(playlistIdString), \(index), \(startSeconds), '\(quality.rawValue)');"
        evaluateJavaScript(command, completionHandler: nil)
    }
}

// MARK:- Setting the playback rate
extension YoutubePlayerView {
    /// Gets the playback rate. The default value is 1.0, which represents a video
    /// playing at normal speed. Other values may include 0.25 or 0.5 for slower
    /// speeds, and 1.5 or 2.0 for faster speeds. This method corresponds to the
    /// JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate`
    public func fetchPlaybackRate(_ handler: @escaping (Float?)->()) {
        evaluateJavaScript("player.getPlaybackRate();") { (data, _) in
            handler(data as? Float)
        }
    }
    
    /// Sets the playback rate. The default value is 1.0, which represents a video
    /// playing at normal speed. Other values may include 0.25 or 0.5 for slower
    /// speeds, and 1.5 or 2.0 for faster speeds. To fetch a list of valid values for
    /// this method, call `getAvailablePlaybackRates`. This method does not
    /// guarantee that the playback rate will change.
    /// This method corresponds to the JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#setPlaybackRate`
    ///
    /// - Parameter rate: A playback rate to suggest for the player.
    public func setPlaybackRate(_ rate: Float) {
        evaluateJavaScript("player.setPlaybackRate(\(rate));", completionHandler: nil)
    }
    
    /// Gets a list of the valid playback rates, useful in conjunction with
    /// `setPlaybackRate`. This method corresponds to the
    /// JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate`
    ///
    public func fetchAvailablePlaybackRates(_ handler: @escaping ([Float]?)->()) {
        evaluateJavaScript("player.getPlaybackRate();") { (data, _) in
            if let stringValue = (data as? String)?.data(using: .utf8) {
                if let rates = ((try? JSONSerialization.jsonObject(with: stringValue, options: []) as? [Float]) as [Float]??) {
                    handler(rates)
                    return
                }
            }
            handler(nil)
        }
    }
    
    public func setSize(_ width: Int, height: Int) {
        evaluateJavaScript("player.setSize(\(width), \(height));", completionHandler: nil)
    }
}

// MARK:- Setting playback behavior for playlists
extension YoutubePlayerView {
    /// Sets whether the player should loop back to the first video in the playlist
    /// after it has finished playing the last video. This method corresponds to the
    /// JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#loopPlaylist`
    ///
    /// - Parameter isLoop: A boolean representing whether the player should loop.
    public func setLoop(_ isLoop: Bool) {
        let command = "player.setLoop(\(isLoop));"
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Sets whether the player should shuffle through the playlist. This method
    /// corresponds to the JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#shufflePlaylist`
    ///
    /// - Parameter isShuffle: A boolean representing whether the player should shuffle through the playlist.
    public func setShuffle(_ isShuffle: Bool) {
        let command = "player.setShuffle(\(isShuffle));"
        evaluateJavaScript(command, completionHandler: nil)
    }
}

// MARK:- Playback status
extension YoutubePlayerView {
    /// Returns a number between 0 and 1 that specifies the percentage of the video
    /// that the player shows as buffered. This method corresponds to the
    /// JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getVideoLoadedFraction`
    ///
    public func fetchVideoLoadedFraction(_ completionHandler: @escaping (Float?) -> ()) {
        evaluateJavaScript("player.getVideoLoadedFraction();") { (data, _) in
            completionHandler(data as? Float)
        }
    }
    
    /// Returns the state of the player. This method corresponds to the
    /// JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getPlayerState`
    ///
    public func fetchPlayerState(_ completionHandler: @escaping (YoutubePlayerState) -> ()) {
        evaluateJavaScript("player.getPlayerState().toString();") { (data, _) in
            if let stringValue = data as? String, let state = YoutubePlayerState(rawValue: stringValue) {
                completionHandler(state)
            } else {
                completionHandler(.unknown)
            }
        }
    }
    
    /// Returns the elapsed time in seconds since the video started playing. This
    /// method corresponds to the JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getCurrentTime`
    ///
    public func fetchCurrentTime(_ completionHandler: @escaping (Double?) -> ()) {
        evaluateJavaScript("player.getCurrentTime();") { (data, _) in
            completionHandler(data as? Double)
        }
    }
}

// MARK:- Playback quality
extension YoutubePlayerView {
    /// Returns the playback quality. This method corresponds to the
    /// JavaScript API defined here:
    ///   https://developers.google.com/youtube/iframe_api_reference#getPlaybackQuality
    ///
    public func fetchPlaybackQuality(_ completionHandler: @escaping (YoutubePlaybackQuality) -> ()) {
        evaluateJavaScript("player.getPlaybackQuality();") { (data, _) in
            if let stringValue = data as? String, let state = YoutubePlaybackQuality(rawValue: stringValue) {
                completionHandler(state)
            } else {
                completionHandler(.unknown)
            }
        }
    }
    
    /// Suggests playback quality for the video. It is recommended to leave this setting to
    /// |default|. This method corresponds to the JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#setPlaybackQuality`
    ///
    /// - Parameter quality: `YoutubePlaybackQuality` value to suggest for the player.
    public func setPlaybackQuality(_ quality: YoutubePlaybackQuality) {
        let command = "player.setPlaybackQuality('\(quality.rawValue)');"
        evaluateJavaScript(command, completionHandler: nil)
    }
    
    /// Gets a list of the valid playback quality values, useful in conjunction with
    /// `setPlaybackQuality`. This method corresponds to the
    /// JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getAvailableQualityLevels`
    ///
    public func fetchAvailableQualities(_ completionHandler: @escaping ([YoutubePlaybackQuality]?) -> ()) {
        evaluateJavaScript("player.getAvailableQualityLevels().toString();") { (data, _) in
            if let qualities = (data as? String)?.components(separatedBy: ",").compactMap(YoutubePlaybackQuality.init) {
                completionHandler(qualities)
            } else {
                completionHandler(nil)
            }
        }
    }
}

// MARK:- Video information methods
extension YoutubePlayerView {
    /// Returns the duration in seconds since the video of the video. This
    /// method corresponds to the JavaScript API defined here:
    ///   https://developers.google.com/youtube/iframe_api_reference#getDuration
    ///
    public func fetchDuration(_ completionHandler: @escaping (TimeInterval?) -> ()) {
        evaluateJavaScript("player.getDuration();") { (data, _) in
            completionHandler(data as? Double)
        }
    }
    
    /// Returns the YouTube.com URL for the video. This method corresponds
    /// to the JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getVideoUrl`
    ///
    public func fetchVideoUrl(_ completionHandler: @escaping (String?) -> ()) {
        evaluateJavaScript("player.getVideoUrl();") { (data, _) in
            completionHandler(data as? String)
        }
    }
    
    /// Returns the embed code for the current video. This method corresponds
    /// to the JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getVideoEmbedCode`
    ///
    public func fetchVideoEmbedCode(_ completionHandler: @escaping (String?) -> ()) {
        evaluateJavaScript("player.getVideoEmbedCode();") { (data, _) in
            completionHandler(data as? String)
        }
    }
}

// MARK:- Playlist methods
extension YoutubePlayerView {
    /// Returns an ordered array of video IDs in the playlist. This method corresponds
    /// to the JavaScript API defined here:
    ///   `https://developers.google.com/youtube/iframe_api_reference#getPlaylist`
    ///
    public func fetchPlaylist(_ handler: @escaping ([String]?)->()) {
        evaluateJavaScript("player.getPlaylist();") { (data, _) in
            if let stringValue = (data as? String)?.data(using: .utf8) {
                if let rates = ((try? JSONSerialization.jsonObject(with: stringValue, options: []) as? [String]) as [String]??) {
                    handler(rates)
                    return
                }
            }
            handler(nil)
        }
    }
    
    /// Returns the 0-based index of the currently playing item in the playlist.
    /// This method corresponds to the JavaScript API defined here:
    ///   https://developers.google.com/youtube/iframe_api_reference#getPlaylistIndex
    ///
    public func fetchPlaylistIndex(_ completionHandler: @escaping (Int?) -> ()) {
        evaluateJavaScript("player.getPlaylistIndex();") { (data, _) in
            completionHandler(data as? Int)
        }
    }
}

// MARK:- Playing a video in a playlist
extension YoutubePlayerView {
    /// Loads and plays the next video in the playlist. Corresponds to this method from
    /// the JavaScript API:
    ///   `https://developers.google.com/youtube/iframe_api_reference#nextVideo`
    public func nextVideo() {
        evaluateJavaScript("player.nextVideo();", completionHandler: nil)
    }
    
    /// Loads and plays the previous video in the playlist. Corresponds to this method from
    /// the JavaScript API:
    ///   `https://developers.google.com/youtube/iframe_api_reference#previousVideo`
    public func previousVideo() {
        evaluateJavaScript("player.previousVideo();", completionHandler: nil)
    }
    
    /// Loads and plays the video at the given 0-indexed position in the playlist.
    /// Corresponds to this method from the JavaScript API:
    ///
    /// - Parameter index: The 0-indexed position of the video in the playlist to load and play.
    public func playVideo(at index: Int) {
        evaluateJavaScript("player.playVideoAt(\(index));", completionHandler: nil)
    }
}

extension YoutubePlayerView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.request.url?.scheme == "ytplayer" {
            notifyDelegate(for: navigationAction.request.url!)
            decisionHandler(.cancel)
        } else {
           decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
}

extension YoutubePlayerView {
    fileprivate func notifyDelegate(for url: URL) {
        guard let actionString = url.host, let action = Callback(rawValue: actionString)  else {
            return
        }
        
        let data = url.query?.components(separatedBy: "=").last
        
        switch action {
        case .onReady:
            play()
            delegate?.playerViewDidBecomeReady(self)
        case .onStateChange:
            if let data = data, let state = YoutubePlayerState(rawValue: data) {
                delegate?.playerView(self, didChangedToState: state)
            }
        case .onPlaybackQualityChange:
            if let data = data, let quality = YoutubePlaybackQuality(rawValue: data) {
                delegate?.playerView(self, didChangeToQuality: quality)
            }
        case .onError:
            if let data = data, let error = YoutubePlayerError(rawValue: data) {
                delegate?.playerView(self, receivedError: error)
            } else {
                delegate?.playerView(self, receivedError: YoutubePlayerError.unknown)
            }
        case .onPlayTime:
            if let data = data, let time = Float(data) {
                delegate?.playerView(self, didPlayTime: time)
            }
        case .onYouTubeIframeAPIFailedToLoad:
            break
        }
    }
}

#endif
