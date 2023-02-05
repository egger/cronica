//
//  WatchProviderOption.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 14/01/23.
//

import Foundation

enum WatchProviderOption: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case ae, ar, at, au, be, bg, br,
    ca, ch, cz, de, dk, ee, es, fi,
    fr, gb, hk, hr, hu, id, ie, india, it,
    jp, kr, lt, mx, nl, no, nz, ph, pl,
    pt, rs, se, sk, tr, us, za
    var localizableTitle: String {
        switch self {
        case .br:
            return NSLocalizedString("watchProviderBr", comment: "")
        case .us:
            return NSLocalizedString("watchProviderUs", comment: "")
        case .ae:
            return NSLocalizedString("watchProviderAe", comment: "")
        case .ar:
            return NSLocalizedString("watchProviderAr", comment: "")
        case .at:
            return NSLocalizedString("watchProviderAt", comment: "")
        case .au:
            return NSLocalizedString("watchProviderAu", comment: "")
        case .be:
            return NSLocalizedString("watchProviderBe", comment: "")
        case .bg:
            return NSLocalizedString("watchProviderBg", comment: "")
        case .ca:
            return NSLocalizedString("watchProviderCa", comment: "")
        case .ch:
            return NSLocalizedString("watchProviderCh", comment: "")
        case .cz:
            return NSLocalizedString("watchProviderCz", comment: "")
        case .de:
            return NSLocalizedString("watchProviderDe", comment: "")
        case .dk:
            return NSLocalizedString("watchProviderDk", comment: "")
        case .ee:
            return NSLocalizedString("watchProviderEe", comment: "")
        case .es:
            return NSLocalizedString("watchProviderEs", comment: "")
        case .fi:
            return NSLocalizedString("watchProviderFi", comment: "")
        case .fr:
            return NSLocalizedString("watchProviderFr", comment: "")
        case .gb:
            return NSLocalizedString("watchProviderGb", comment: "")
        case .hk:
            return NSLocalizedString("watchProviderHk", comment: "")
        case .hr:
            return NSLocalizedString("watchProviderHr", comment: "")
        case .hu:
            return NSLocalizedString("watchProviderHu", comment: "")
        case .id:
            return NSLocalizedString("watchProviderId", comment: "")
        case .ie:
            return NSLocalizedString("watchProviderIe", comment: "")
        case .india:
            return NSLocalizedString("watchProviderIndia", comment: "")
        case .it:
            return NSLocalizedString("watchProviderIt", comment: "")
        case .jp:
            return NSLocalizedString("watchProviderJp", comment: "")
        case .kr:
            return NSLocalizedString("watchProviderKr", comment: "")
        case .lt:
            return NSLocalizedString("watchProviderLt", comment: "")
        case .mx:
            return NSLocalizedString("watchProviderMx", comment: "")
        case .nl:
            return NSLocalizedString("watchProviderNl", comment: "")
        case .no:
            return NSLocalizedString("watchProviderNo", comment: "")
        case .nz:
            return NSLocalizedString("watchProviderNz", comment: "")
        case .ph:
            return NSLocalizedString("watchProviderPh", comment: "")
        case .pl:
            return NSLocalizedString("watchProviderPl", comment: "")
        case .pt:
            return NSLocalizedString("watchProviderPt", comment: "")
        case .rs:
            return NSLocalizedString("watchProviderRs", comment: "")
        case .se:
            return NSLocalizedString("watchProviderSe", comment: "")
        case .sk:
            return NSLocalizedString("watchProviderSk", comment: "")
        case .tr:
            return NSLocalizedString("watchProviderTr", comment: "")
        case .za:
            return NSLocalizedString("watchProviderZa", comment: "")
        }
    }
}
