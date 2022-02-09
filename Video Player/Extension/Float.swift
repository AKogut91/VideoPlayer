//
//  Float.swift
//  Video Player
//
//  Created by Alex Kogut on 09.02.2022.
//

import Foundation

extension Float {
    
    func getTimeString() -> String {
        var components = DateComponents()
        components.second = Int(max(0.0, self))
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: components) ?? ""
    }
}
