//
//  WatchProviderOption.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 14/01/23.
//  swiftlint:disable identifier_name

import Foundation

enum AppContentRegion: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case ae, ar, at, au, be, bg, br,
         ca, ch, cz, de, dk, ee, es, fi,
         fr, gb, hk, hr, hu, id, ie, india, it,
         jp, kr, lt, mx, nl, no, nz, ph, pl,
         pt, rs, se, sk, tr, us, za
    var localizableTitle: String {
        switch self {
        case .br:
            return NSLocalizedString("Brazil", comment: "")
        case .us:
            return NSLocalizedString("United States", comment: "")
        case .ae:
            return NSLocalizedString("United Arab Emirates", comment: "")
        case .ar:
            return NSLocalizedString("Argentina", comment: "")
        case .at:
            return NSLocalizedString("Austria", comment: "")
        case .au:
            return NSLocalizedString("Australia", comment: "")
        case .be:
            return NSLocalizedString("Belgium", comment: "")
        case .bg:
            return NSLocalizedString("Bulgaria", comment: "")
        case .ca:
            return NSLocalizedString("Canada", comment: "")
        case .ch:
            return NSLocalizedString("Switzerland", comment: "")
        case .cz:
            return NSLocalizedString("Czech Republic", comment: "")
        case .de:
            return NSLocalizedString("Germany", comment: "")
        case .dk:
            return NSLocalizedString("Denmark", comment: "")
        case .ee:
            return NSLocalizedString("Estonia", comment: "")
        case .es:
            return NSLocalizedString("Spain", comment: "")
        case .fi:
            return NSLocalizedString("Finland", comment: "")
        case .fr:
            return NSLocalizedString("France", comment: "")
        case .gb:
            return NSLocalizedString("United Kingdom", comment: "")
        case .hk:
            return NSLocalizedString("Hong Kong", comment: "")
        case .hr:
            return NSLocalizedString("Croatia", comment: "")
        case .hu:
            return NSLocalizedString("Hungary", comment: "")
        case .id:
            return NSLocalizedString("Indonesia", comment: "")
        case .ie:
            return NSLocalizedString("Ireland", comment: "")
        case .india:
            return NSLocalizedString("India", comment: "")
        case .it:
            return NSLocalizedString("Italy", comment: "")
        case .jp:
            return NSLocalizedString("Japan", comment: "")
        case .kr:
            return NSLocalizedString("South Korea", comment: "")
        case .lt:
            return NSLocalizedString("Lithuania", comment: "")
        case .mx:
            return NSLocalizedString("Mexico", comment: "")
        case .nl:
            return NSLocalizedString("Netherlands", comment: "")
        case .no:
            return NSLocalizedString("Norway", comment: "")
        case .nz:
            return NSLocalizedString("New Zealand", comment: "")
        case .ph:
            return NSLocalizedString("Philippines", comment: "")
        case .pl:
            return NSLocalizedString("Poland", comment: "")
        case .pt:
            return NSLocalizedString("Portugal", comment: "")
        case .rs:
            return NSLocalizedString("Serbia", comment: "")
        case .se:
            return NSLocalizedString("Sweden", comment: "")
        case .sk:
            return NSLocalizedString("Slovakia", comment: "")
        case .tr:
            return NSLocalizedString("Turkey", comment: "")
        case .za:
            return NSLocalizedString("South Africa", comment: "")
        }
    }

    var bcp47Identifier: String {
        switch self {
        case .ae:
            return "ar-AE"
        case .ar:
            return "es-AR"
        case .at:
            return "de-AT"
        case .au:
            return "en-AU"
        case .be:
            return "nl-BE"
        case .bg:
            return "bg-BG"
        case .br:
            return "pt-BR"
        case .ca:
            return "en-CA"
        case .ch:
            return "de-CH"
        case .cz:
            return "cs-CZ"
        case .de:
            return "de-DE"
        case .dk:
            return "da-DK"
        case .ee:
            return "et-EE"
        case .es:
            return "es-ES"
        case .fi:
            return "fi-FI"
        case .fr:
            return "fr-FR"
        case .gb:
            return "en-GB"
        case .hk:
            return "zh-HK"
        case .hr:
            return "hr-HR"
        case .hu:
            return "hu-HU"
        case .id:
            return "id-ID"
        case .ie:
            return "en-IE"
        case .india:
            return "hi-IN"
        case .it:
            return "it-IT"
        case .jp:
            return "ja-JP"
        case .kr:
            return "ko-KR"
        case .lt:
            return "lt-LT"
        case .mx:
            return "es-MX"
        case .nl:
            return "nl-NL"
        case .no:
            return "nb-NO"
        case .nz:
            return "en-NZ"
        case .ph:
            return "en-PH"
        case .pl:
            return "pl-PL"
        case .pt:
            return "pt-PT"
        case .rs:
            return "sr-RS"
        case .se:
            return "sv-SE"
        case .sk:
            return "sk-SK"
        case .tr:
            return "tr-TR"
        case .us:
            return "en-US"
        case .za:
            return "en-ZA"
        }
    }
}
