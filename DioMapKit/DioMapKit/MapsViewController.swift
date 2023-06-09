//
//  MapsViewController.swift
//  DioMapKit
//
//  Created by Rodrigo Ferreira Pereira on 25/05/23.
//

import UIKit
import MapKit

class MapsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var lastLocation: CLLocationCoordinate2D? = nil
    
    var selectedAddress: Address? = nil
    
    @IBOutlet weak var addressTextField: UITextField!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        mapView.delegate = self
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestLocation()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        if let address = selectedAddress {
            showRoute(address)
        }
    }
    
    @IBAction func tappedShowAddress(_ sender: Any) {
        getPossibleAddressesFromText()
    }
    
    private func getPossibleAddressesFromText() {
        var Addresses: [Address] = []
        CLGeocoder().geocodeAddressString(addressTextField.text!) { (placemarks, error) in
            if error == nil {
                for placemark in placemarks! {
                    Addresses.append(self.convertToAddress(placemark: placemark))
                }
                self.showAddressTable(addresses: Addresses)
            } else {
                let controller = UIAlertController(title: "Error", message: "Problem Trying to fetch addresses from the text", preferredStyle: UIAlertController.Style.alert)
                self.present(controller, animated: true)
            }
        }
    }
    
    private func convertToAddress(placemark: CLPlacemark) -> Address {
        return Address(name: placemark.postalAddress!.street, placemark: placemark, postalAddress: placemark.postalAddress!);
    }
    
    private func showAddressTable(addresses: [Address]) {
        let addressesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddressesTableViewController") as! AddressesTableViewController
        addressesVC.addresses = addresses
        addressesVC.selectedAddress = { address in
            self.selectedAddress = address
        }
        self.navigationController?.pushViewController(addressesVC, animated: true)
    }
    
    private func showRoute (_ address: Address) {
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = address.placemark.location!.coordinate
        destinationAnnotation.title = address.name
        self.mapView.addAnnotation(destinationAnnotation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation!))
        request.destination = MKMapItem(placemark: MKPlacemark(placemark: address.placemark))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, error) in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
}

extension MapsViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            DispatchQueue.main.async { [weak self] in
                self?.locationManager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        self.lastLocation = location?.coordinate
        mapView.centerCoordinate = location!.coordinate
        let region = mapView.regionThatFits(MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 600.0, longitudinalMeters: 600.0))
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension MapsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .systemPink
        renderer.lineWidth = 5.0
        return renderer
    }
}
