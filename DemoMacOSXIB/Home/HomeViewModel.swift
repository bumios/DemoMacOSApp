//
//  HomeViewModel.swift
//  DemoMacOSXIB
//
//  Created by Duy Tran N. on 24/05/2022.
//

import Foundation
import AppKit

struct HomeViewModel {

    var users: [HomeUser] = [
        HomeUser(name: "Duy Tran", age: 12, gender: .male, identityInfo: IdentityInformation(cardNumber: "123456789", date: Date(), place: "Da Nang", status: .active)),
        HomeUser(name: "Connor", age: 23, gender: .male, identityInfo: IdentityInformation(cardNumber: "198765412", date: Date(), place: "Quang Binh", status: .inactive)),
        HomeUser(name: "Brian", age: 24, gender: .female, identityInfo: IdentityInformation(cardNumber: "472323487", date: Date(), place: "Hue", status: .expired)),
        HomeUser(name: "Nhat Duy", age: 32, gender: .male, identityInfo: IdentityInformation(cardNumber: "123871321", date: Date(), place: "Sai Gon", status: .active)),
        HomeUser(name: "Bumios", age: 52, gender: .female, identityInfo: IdentityInformation(cardNumber: "123563632", date: Date(), place: "Ha Noi", status: .inactive)),
    ]

    func numberOfRows() -> Int {
        return users.count
    }

    func getUser(at row: Int) -> HomeUser {
        return users[row]
    }
}

struct HomeUser {
    let name: String?
    let age: Int?
    let gender: Gender?
    let identityInfo: IdentityInformation?

    enum Gender {
        case male
        case female

        var displayValue: String {
            switch self {
            case .male:
                return "Male"
            case .female:
                return "Female"
            }
        }

        var iconImage: NSImage? {
            switch self {
            case .male:
                return NSImage(systemSymbolName: "mustache.fill", accessibilityDescription: nil)
            case .female:
                return NSImage(systemSymbolName: "mouth.fill", accessibilityDescription: nil)
            }
        }

        var iconTintColor: NSColor {
            guard self == .male else { return NSColor.systemPink }
            return NSColor.systemGreen
        }
    }
}

struct IdentityInformation {
    let cardNumber: String?
    let date: Date?
    let place: String?
    let status: CardStatus?

    enum CardStatus: String, CaseIterable {
        case active
        case inactive
        case expired
    }
}
