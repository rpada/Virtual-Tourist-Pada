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

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
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
        // https://classroom.udacity.com/nanodegrees/nd003/parts/9f3d04d4-d74a-4032-bf01-8887182fee62/modules/bbdd0d82-ac18-46b4-8bd4-246082887515/lessons/62c0b010-315c-4a1c-9bab-de477fff1aab/concepts/49036d1d-4810-4bec-b973-abe80a5dee6b
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            pins = result
            // MapView.reloadData()
        }
    }
// https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
    @objc func handleTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == UIGestureRecognizer.State.ended {

            let touchPoint = sender.location(in: MapView)
            let touchCoordinate = MapView.convert(touchPoint, toCoordinateFrom: MapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Event place"
            print(touchCoordinate.latitude)
            print(touchCoordinate.longitude)
            MapView.removeAnnotations(MapView.annotations)
            MapView.addAnnotation(annotation) //drops the pin
      }
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
