//
//  ViewController.swift
//  IAPExample
//
//  Created by Thi Nguyen Tam on 2/25/19.
//  Copyright © 2019 Thi Nguyen Tam. All rights reserved.
//

import UIKit
import StoreKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.gray
        return refreshControl
    }()
    
    let showDetailSegueIdentifier = "showDetail"
    var products: [SKProduct] = []
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == showDetailSegueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return false
            }
            
            let product = products[(indexPath as NSIndexPath).row]
            
            return Products.store.isProductPurchased(product.productIdentifier)
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDetailSegueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let product = products[(indexPath as NSIndexPath).row]
            
            if let name = resourceNameForProductIdentifier(product.productIdentifier),
                let detailViewController = segue.destination as? DetailViewController {
                let image = UIImage(named: name)
                detailViewController.image = image
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleRefresh(nil)
    }

    @objc func handleRefresh(_ sender: Any?) {
        products = []
        
        tableView.reloadData()
        
        Products.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
                
                self.tableView.reloadData()
            }
            
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func restoreTapped(_ sender: AnyObject) {
        Products.store.restorePurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.index(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }

}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductCell
        
        let product = products[(indexPath as NSIndexPath).row]
        
        cell.product = product
        cell.buyButtonHandler = { product in
            Products.store.buyProduct(product)
        }
        
        return cell
    }
    
}

