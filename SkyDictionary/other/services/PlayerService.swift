//
//  PlayerService.swift
//  SkyDictionary
//
//  Created by Никита Черников on 19/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import AVFoundation

class PlayerService {
    static let shared = PlayerService()
    
    private var player: AVAudioPlayer?
    
    func play(url: URL) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player?.prepareToPlay()
            self.player?.volume = 1.0
            self.player?.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        } catch {
            self.player = nil
            print("AVAudioPlayer init failed")
        }
    }
}
