//
//  DetailViewController.swift
//  IAPExample
//
//  Created by Thi Nguyen Tam on 4/1/19.
//  Copyright © 2019 Thi Nguyen Tam. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?
    
    var image: UIImage? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        imageView?.image = image
    }

}
