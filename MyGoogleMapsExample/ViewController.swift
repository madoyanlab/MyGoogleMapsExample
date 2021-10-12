//
//  ViewController.swift
//  MyGoogleMapsExample
//
//  Created by Hayk Madoyan on 22.09.2021.
//

import UIKit
import GooglePlaces
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating {
    
    let manager = CLLocationManager()
    var mapView : GMSMapView?
    let searchVC = UISearchController(searchResultsController: ResultsViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Maps"
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        GMSServices.provideAPIKey("AIzaSyCMdrSkRE_q6MWmr-jmA9oJ6inDpN8vRJo")
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        let coordinate = location.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 9.0)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapView!.frame = CGRect(x: 0, y: view.safeAreaInsets.top,
                               width: view.frame.size.width,
                               height: view.frame.size.height - view.safeAreaInsets.top)
        view.addSubview(mapView!)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.icon = GMSMarker.markerImage(with: .red)
        marker.opacity = 0.6//
        marker.icon = UIImage(named: "unnamed")
        marker.map = mapView!
        manager.stopUpdatingLocation()
    }

    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty,
        let resultsVC = searchController.searchResultsController as? ResultsViewController else {
            return
        }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
            
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension ViewController: ResultsViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
        // Remove all map pins
//        mapView.remove
        guard mapView != nil else { return }
        // Add a map pin
        let pin = GMSMarker()
        pin.position = coordinates
        mapView!.camera = GMSCameraPosition(
              target: coordinates,
              zoom: 15,
              bearing: 0,
              viewingAngle: 0)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.opacity = 0.8//
        marker.map = mapView!
        
//        let marke = GMSMarker()
//        marke.position = CLLocationCoordinate2D(latitude: coordinates.latitude + 0.001, longitude: coordinates.longitude + 0.001)
//        marke.title = "Sydney"
//        marke.snippet = "Australia"
//        marke.map = mapView!
        
    }
    
    
}
