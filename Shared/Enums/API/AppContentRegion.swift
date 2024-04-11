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
        case .ae: "ar-AE"
        case .ar: "es-AR"
        case .at: "de-AT"
        case .au: "en-AU"
        case .be: "nl-BE"
        case .bg: "bg-BG"
        case .br: "pt-BR"
        case .ca: "en-CA"
        case .ch: "de-CH"
        case .cz: "cs-CZ"
        case .de: "de-DE"
        case .dk: "da-DK"
        case .ee: "et-EE"
        case .es: "es-ES"
        case .fi: "fi-FI"
        case .fr: "fr-FR"
        case .gb: "en-GB"
        case .hk: "zh-HK"
        case .hr: "hr-HR"
        case .hu: "hu-HU"
        case .id: "id-ID"
        case .ie: "en-IE"
        case .india: "hi-IN"
        case .it: "it-IT"
        case .jp: "ja-JP"
        case .kr: "ko-KR"
        case .lt: "lt-LT"
        case .mx: "es-MX"
        case .nl: "nl-NL"
        case .no: "nb-NO"
        case .nz: "en-NZ"
        case .ph: "en-PH"
        case .pl: "pl-PL"
        case .pt: "pt-PT"
        case .rs: "sr-RS"
        case .se: "sv-SE"
        case .sk: "sk-SK"
        case .tr: "tr-TR"
        case .us: "en-US"
        case .za: "en-ZA"
        }
    }
}
