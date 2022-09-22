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
    func loadPhotos() {
        PhotoSearch.grabPhotos(lat: selectedPin?.latitude ?? 0.0, lon: selectedPin?.longitude ?? 0.0, page: page, completion: { (photos, error) in
            if (photos != nil) {
                if photos?.pages == 0 {
                self.showAlertAction(title: "Sorry!", message: "Could not find any photos for this location.")
                } else {
                    // test
                    self.showAlertAction(title: "Success!", message: "Photos will be retrieved")
                    self.photos = (photos?.photo)!
                    let randomPage = Int.random(in: 1...photos!.pages)
                    self.page = randomPage
                    print(self.page)
                }
            } else {
            self.showAlertAction(title: "Error", message: "Could not retrieve photos")
            }
        })
    }
  
}
