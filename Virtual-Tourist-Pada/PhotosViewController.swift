//
//  PhotosViewController.swift
//  Virtual-Tourist-Pada
//
//  Created by Brenna Pada on 9/20/22.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var collectionPhotos: UICollectionView!
    @IBOutlet weak var Map: MKMapView!
    // https://developer.apple.com/forums/thread/112480
    var selectedPin: CLLocationCoordinate2D?
    var pins: [Pin] = []
    var dataController: DataController!
    var page: Int = 0
    var cellsPerRow = 0
    var photos: [Photo] = []
    var APIPhotoVar: [APIPhoto] = []
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let annotation = MKPointAnnotation()
        // https://stackoverflow.com/questions/7213346/get-latitude-and-longitude-from-annotation-view
        annotation.coordinate.latitude = selectedPin?.latitude ?? 0.0
        annotation.coordinate.longitude = selectedPin?.longitude ?? 0.0
        let span = MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        Map.addAnnotation(annotation)
        self.Map.setRegion(region, animated: false)
        // not working
        Map.delegate = self // make pins appear as stylized
        loadPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPhotos()
    }
    // MARK: Map pins
    // from https://stackoverflow.com/questions/24195310/how-to-add-an-action-to-a-uialertview-button-using-swift-ios
    
    // stack overflow said to use DispatchQueue: https://stackoverflow.com/questions/58087536/modifications-to-the-layout-engine-must-not-be-performed-from-a-background-thr
        
        
    func showAlertAction(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                print("Action")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
  
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    // // from https://classroom.udacity.com/nanodegrees/nd003/parts/2b0b0f37-f10b-41dc-abb4-a346f293027a/modules/4b26ca51-f2e8-45a3-92df-a1797f597a19/lessons/3283ae8e-5dd5-483b-9c49-2faac7c53276/concepts/126b0978-f775-480a-bac0-68a1396aa81a
    // similar logic to Udacity's API- call it from the Client, assign the correct variables, handle errors 
     func loadPhotos() {
         PhotoSearch.searchPhotos(lat:selectedPin?.latitude ?? 0.0, lon:selectedPin?.latitude ?? 0.0, page: page) { response, error in
            if let response = response {
                print("success")
                } else {
            self.showAlertAction(title: "Error", message: "Could not load photos")
            }
        }
    }
}
