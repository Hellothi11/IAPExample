//
//  Products.swift
//  IAPExample
//
//  Created by Thi Nguyen Tam on 4/1/19.
//  Copyright © 2019 Thi Nguyen Tam. All rights reserved.
//

import Foundation

public struct Products {
    public static let Mazda6 = "mazda6"
    public static let OneGallon = "1gallon"

    private static let productIdentifiers: Set<ProductIdentifier> = [Products.Mazda6, Products.OneGallon]

    public static let store = IAPHelper(productIds: Products.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
