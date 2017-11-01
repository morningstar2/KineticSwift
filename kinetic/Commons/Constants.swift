//
//  Constants.swift
//  dataconnect
//
//  Created by hienng on 9/25/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit

/// The total animation duration of the splash animation
let kAnimationDuration: TimeInterval = 3.0

/// The length of the second part of the duration
let kAnimationDurationDelay: TimeInterval = 0.5

/// The offset between the AnimatedULogoView and the background Grid
let kAnimationTimeOffset: CFTimeInterval = 0.35 * kAnimationDuration

/// The ripple magnitude. Increase by small amounts for amusement ( <= .2) :]
let kRippleMagnitudeMultiplier: CGFloat = 0.025


let HTTPS: String = "https://"
let POST: String = "POST"
let GET: String = "GET"
let DATACONNECT_API_KEY: String = "x_gwaas_api_key"
let API_ROOT: String = "/api"
let API_VERSION_2: String = "/v2"
let API_VERSION_1: String = "/v1"
let API_KEY = "api_key"
let SELECTED_ORG_ID = "selected_org_id"
let SELECTED_GATEWAY_ID = "selected_gateway_id"

struct SERVICE_URL{
    static let GATEWAYS = API_ROOT + API_VERSION_2 + "/gate_ways"
    static let ORGANIZATIONS = API_ROOT + API_VERSION_1 + "/organizations"
    static let ORGANIZATIONS2 = API_ROOT + API_VERSION_2 + "/organizations"
    static let SESSIONS = API_ROOT + API_VERSION_1 + "/sessions"
    static let CLAIM = "/claims"
    static let ORGANIZATION_FOR_CLAIM = API_ROOT + API_VERSION_1 + "/organizations"
}

struct SEGUE {
    static let LOGIN = "LOGIN_SEGUE"
}

let KINETIC_DB_STATUS_CHANGED = "kineticDBStatusChanged"
