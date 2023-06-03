//
//  AddressesTableViewController.swift
//  DioMapKit
//
//  Created by Rodrigo Ferreira Pereira on 02/06/23.
//

import UIKit

class AddressesTableViewController: UITableViewController {
    
    var addresses: [Address] = []
    
    var selectedAddress: ((Address) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return addresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
        let Address = addresses[indexPath.row]
        
        cell.textLabel?.text = Address.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = addresses[indexPath.row]
        selectedAddress!(address)
        self.navigationController?.popViewController(animated: true)
    }
}
