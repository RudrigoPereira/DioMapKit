//
//  Address.swift
//  DioMapKit
//
//  Created by Rodrigo Ferreira Pereira on 01/06/23.
//

import Foundation
import Contacts
import CoreLocation

struct Address {
    var name: String
    var placemark: CLPlacemark
    var postalAddress: CNPostalAddress
    
    init(name: String, placemark: CLPlacemark, postalAddress: CNPostalAddress) {
        self.name = name
        self.placemark = placemark
        self.postalAddress = postalAddress
    }
}
