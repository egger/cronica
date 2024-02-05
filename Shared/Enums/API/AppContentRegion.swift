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
        case .br: NSLocalizedString("Brazil", comment: "Country")
        case .us: NSLocalizedString("United States", comment: "Country")
        case .ae: NSLocalizedString("United Arab Emirates", comment: "Country")
        case .ar: NSLocalizedString("Argentina", comment: "Country")
        case .at: NSLocalizedString("Austria", comment: "Country")
        case .au: NSLocalizedString("Australia", comment: "Country")
        case .be: NSLocalizedString("Belgium", comment: "Country")
        case .bg: NSLocalizedString("Bulgaria", comment: "Country")
        case .ca: NSLocalizedString("Canada", comment: "Country")
        case .ch: NSLocalizedString("Switzerland", comment: "Country")
        case .cz: NSLocalizedString("Czech Republic", comment: "Country")
        case .de: NSLocalizedString("Germany", comment: "Country")
        case .dk: NSLocalizedString("Denmark", comment: "Country")
        case .ee: NSLocalizedString("Estonia", comment: "Country")
        case .es: NSLocalizedString("Spain", comment: "Country")
        case .fi: NSLocalizedString("Finland", comment: "Country")
        case .fr: NSLocalizedString("France", comment: "Country")
        case .gb: NSLocalizedString("United Kingdom", comment: "Country")
        case .hk: NSLocalizedString("Hong Kong", comment: "Country")
        case .hr: NSLocalizedString("Croatia", comment: "Country")
        case .hu: NSLocalizedString("Hungary", comment: "Country")
        case .id: NSLocalizedString("Indonesia", comment: "Country")
        case .ie: NSLocalizedString("Ireland", comment: "Country")
        case .india: NSLocalizedString("India", comment: "Country")
        case .it: NSLocalizedString("Italy", comment: "Country")
        case .jp: NSLocalizedString("Japan", comment: "Country")
        case .kr: NSLocalizedString("South Korea", comment: "Country")
        case .lt: NSLocalizedString("Lithuania", comment: "Country")
        case .mx: NSLocalizedString("Mexico", comment: "Country")
        case .nl: NSLocalizedString("Netherlands", comment: "Country")
        case .no: NSLocalizedString("Norway", comment: "Country")
        case .nz: NSLocalizedString("New Zealand", comment: "Country")
        case .ph: NSLocalizedString("Philippines", comment: "Country")
        case .pl: NSLocalizedString("Poland", comment: "Country")
        case .pt: NSLocalizedString("Portugal", comment: "Country")
        case .rs: NSLocalizedString("Serbia", comment: "Country")
        case .se: NSLocalizedString("Sweden", comment: "Country")
        case .sk: NSLocalizedString("Slovakia", comment: "Country")
        case .tr: NSLocalizedString("Turkey", comment: "Country")
        case .za: NSLocalizedString("South Africa", comment: "Country")
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
