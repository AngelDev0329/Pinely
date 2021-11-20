//
//  String+playSoung.swift
//  Pinely
//
//  Created by Alexander Nekrasov on 19.08.21.
//  Copyright © 2021 Francisco de Asis Jimenez Tirado. All rights reserved.
//

import Foundation

class SoundPlayer {
    static var player: [String: AVAudioPlayer] = [:]
}

extension String {
    func prepareSound() {
        if let url = Bundle.main.url(forResource: self, withExtension: "mp3"),
           let player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue) {
            player.prepareToPlay()
            SoundPlayer.player[self] = player
        }
    }

    func playSound() {
        SoundPlayer.player[self]?.play()
    }
}
