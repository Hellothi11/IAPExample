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
    let SECRET = "36915f96204244b498fdc0e28e0f50f8"
    
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
                detailViewController.text = name
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        // verifyReceipt()
    }
    
    func verifyReceipt() {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            let data = try? Data(contentsOf: receiptURL) {
            print("receiptURL: \(receiptURL)")
            let base64 = data.base64EncodedString()
            let dictionary = ["receipt-data": base64, "password": SECRET]
            if let requestData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
                if let requestURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt") {
                    var request = URLRequest(url: requestURL)
                    request.httpMethod = "POST"
                    let session = URLSession.shared
                    let task = session.uploadTask(with: request, from: requestData) {
                        data, response, error in
                        if let data = data, let dataString = String(data: data, encoding: .utf8) {
                            print(" verifyReceipt response: \(dataString)")
                        }
                    }
                    task.resume()
                }
            }
        }
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
        print("Tapped restore");
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

