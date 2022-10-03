//
//  MapViewController.swift
//  Virtual-Tourist-Pada
//
//  Created by Brenna Pada on 9/19/22.
//
import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var MapView: MKMapView!
    
    // https://classroom.udacity.com/nanodegrees/nd003/parts/9f3d04d4-d74a-4032-bf01-8887182fee62/modules/bbdd0d82-ac18-46b4-8bd4-246082887515/lessons/62c0b010-315c-4a1c-9bab-de477fff1aab/concepts/aec3cd9c-cf56-453d-b066-93738a9041db
    
    var pins: [Pin] = []
    var dataController: DataController!
    
    //https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
    override func viewDidLoad() {
        super.viewDidLoad()
        // https://knowledge.udacity.com/questions/249077
        let tapGesture = UILongPressGestureRecognizer(target: self, action:#selector(MapViewController.handleTap(_:)))
        tapGesture.delegate = self
        MapView.addGestureRecognizer(tapGesture)
        MapView.delegate = self // make pins appear as stylized
        loadPins()
    }
    
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
    // https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
    @objc func handleTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == UIGestureRecognizer.State.ended {
            
            let touchPoint = sender.location(in: MapView)
            let touchCoordinate = MapView.convert(touchPoint, toCoordinateFrom: MapView)
            let annotation = MKPointAnnotation()
            // https://classroom.udacity.com/nanodegrees/nd003/parts/9f3d04d4-d74a-4032-bf01-8887182fee62/modules/bbdd0d82-ac18-46b4-8bd4-246082887515/lessons/62c0b010-315c-4a1c-9bab-de477fff1aab/concepts/a65a1e8d-4237-460a-a953-9d0ab8575dd3
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = touchCoordinate.latitude
            pin.longitude = touchCoordinate.longitude
            try? dataController.viewContext.save()
            annotation.coordinate = touchCoordinate
            annotation.title = "New pin"
            MapView.addAnnotation(annotation) //drops the pin
            pins.append(pin)
        }
    }
    func loadPins(){
        // https://classroom.udacity.com/nanodegrees/nd003/parts/9f3d04d4-d74a-4032-bf01-8887182fee62/modules/bbdd0d82-ac18-46b4-8bd4-246082887515/lessons/62c0b010-315c-4a1c-9bab-de477fff1aab/concepts/49036d1d-4810-4bec-b973-abe80a5dee6b
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let fetchpins = try? dataController.viewContext.fetch(fetchRequest){
            pins = fetchpins
            // iteration https://knowledge.udacity.com/questions/346334
            for persistedPins in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: persistedPins.latitude, longitude: persistedPins.longitude)
                self.MapView.addAnnotation(annotation)
            }
        } else {
            self.showAlertAction(title: "Error!", message: "Could not load pins. Please try again.")
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        // https://knowledge.udacity.com/questions/209471
        // https://classroom.udacity.com/nanodegrees/nd003/parts/4674db75-a1fd-4134-aedf-387f74357fe0/modules/480a4cc0-6e64-4979-b1e6-15ce588850ee/lessons/751f4590-576f-4091-aa8b-3b0edd2cd3e8/concepts/d4f21dca-dd2e-4a3b-b0c1-5c55db1b0ca5
        let photosController = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        //https://stackoverflow.com/questions/7213346/get-latitude-and-longitude-from-annotation-view
            photosController.selectedPin = annotation?.coordinate
        
        for pin in pins {
            // from https://knowledge.udacity.com/questions/521585
            // I wasn't passing this correctly which caused the same photos to be showed for every single pin. 
            if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude {
                photosController.pin = pin
            }
        }
            photosController.dataController = dataController
            mapView.deselectAnnotation(view.annotation, animated:true)
            self.navigationController?.pushViewController(photosController, animated: true)
        }
        
        // make the pins more stylized
        // from On the Map project
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
    }
    
