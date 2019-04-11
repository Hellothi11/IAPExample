//
//  Products.swift
//  IAPExample
//
//  Created by Thi Nguyen Tam on 4/1/19.
//  Copyright © 2019 Thi Nguyen Tam. All rights reserved.
//

import Foundation

public struct Products {
    public static let Premium = "thi.nguyen.test.certificate.premium"
    public static let OneHundredCoins = "thi.nguyen.test.certificate.100.coins"
    public static let VIP3 = "thi.nguyen.test.certificate.vip3"
    public static let LoveWinter = "thi.nguyen.test.certificate.lovewinter"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [Products.Premium, Products.OneHundredCoins, Products.VIP3, Products.LoveWinter]

    public static let store = IAPHelper(productIds: Products.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
