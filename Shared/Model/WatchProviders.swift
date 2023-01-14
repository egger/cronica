//
//  WatchProviders.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 14/01/23.
//

import Foundation

struct WatchProviders: Codable, Hashable {
    var results: Results?
}

struct Results: Codable, Hashable {
    var ae: AE?
    var ag: Ag?
    var al, ar, at, au: AE?
    var ba: AE?
    var bb: Bb?
    var be, bg, bh, bo: AE?
    var br: AE?
    var bs: Bb?
    var ca, ch, cl, co: AE?
    var cr, cz, de, dk: AE?
    var resultsDO: AE?
    var dz: Bb?
    var ec, ee, eg, es: AE?
    var fi, fr, gb: AE?
    var gf: Bb?
    var gr, gt, hk, hn: AE?
    var hr, hu, id, ie: AE?
    var resultsIN: AE?
    var iq: Bb?
    var resultsIS, it, jm, jo: AE?
    var jp: AE?
    var kr: Ag?
    var kw: Bb?
    var lb, lt, lv: AE?
    var ly, ma: Bb?
    var md, mk: AE?
    var mt: Ag?
    var mx, my, nl, no: AE?
    var nz, om, pa, pe: AE?
    var ph, pl: AE?
    var ps: Bb?
    var pt, py: AE?
    var qa, ro, rs: Bb?
    var sa, se, sg, si: AE?
    var sk, sv, th: AE?
    var tn: Bb?
    var tr, tt, tw, us: AE?
    var uy, ve: AE?
    var ye: Bb?
    var za: Ag?

    enum CodingKeys: String, CodingKey {
        case ae = "AE"
        case ag = "AG"
        case al = "AL"
        case ar = "AR"
        case at = "AT"
        case au = "AU"
        case ba = "BA"
        case bb = "BB"
        case be = "BE"
        case bg = "BG"
        case bh = "BH"
        case bo = "BO"
        case br = "BR"
        case bs = "BS"
        case ca = "CA"
        case ch = "CH"
        case cl = "CL"
        case co = "CO"
        case cr = "CR"
        case cz = "CZ"
        case de = "DE"
        case dk = "DK"
        case resultsDO = "DO"
        case dz = "DZ"
        case ec = "EC"
        case ee = "EE"
        case eg = "EG"
        case es = "ES"
        case fi = "FI"
        case fr = "FR"
        case gb = "GB"
        case gf = "GF"
        case gr = "GR"
        case gt = "GT"
        case hk = "HK"
        case hn = "HN"
        case hr = "HR"
        case hu = "HU"
        case id = "ID"
        case ie = "IE"
        case resultsIN = "IN"
        case iq = "IQ"
        case resultsIS = "IS"
        case it = "IT"
        case jm = "JM"
        case jo = "JO"
        case jp = "JP"
        case kr = "KR"
        case kw = "KW"
        case lb = "LB"
        case lt = "LT"
        case lv = "LV"
        case ly = "LY"
        case ma = "MA"
        case md = "MD"
        case mk = "MK"
        case mt = "MT"
        case mx = "MX"
        case my = "MY"
        case nl = "NL"
        case no = "NO"
        case nz = "NZ"
        case om = "OM"
        case pa = "PA"
        case pe = "PE"
        case ph = "PH"
        case pl = "PL"
        case ps = "PS"
        case pt = "PT"
        case py = "PY"
        case qa = "QA"
        case ro = "RO"
        case rs = "RS"
        case sa = "SA"
        case se = "SE"
        case sg = "SG"
        case si = "SI"
        case sk = "SK"
        case sv = "SV"
        case th = "TH"
        case tn = "TN"
        case tr = "TR"
        case tt = "TT"
        case tw = "TW"
        case us = "US"
        case uy = "UY"
        case ve = "VE"
        case ye = "YE"
        case za = "ZA"
    }
}

struct AE: Codable, Hashable {
    var link: String?
    var buy, rent, flatrate, free: [Buy]?
}

struct Buy: Codable, Hashable {
    var logoPath: String?
    var providerId: Int?
    var providerName: String?
    var displayPriority: Int?
}

extension Buy {
    var contentId: String {
        return UUID().uuidString
    }
    var providerTitle: String {
        providerName ?? "Not Found"
    }
    var providerImage: URL? {
        return NetworkService.urlBuilder(size: .medium, path: logoPath)
    }
    var listPriority: Int {
        return displayPriority ?? 10
    }
}

struct Ag: Codable, Hashable {
    var link: String?
    var buy: [Buy]?
}

struct Bb: Codable, Hashable {
    var link: String?
    var flatrate: [Buy]?
}
