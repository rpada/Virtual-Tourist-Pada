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

class PhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionPhotos: UICollectionView!
    @IBOutlet weak var Map: MKMapView!
    // https://developer.apple.com/forums/thread/112480
    fileprivate let cellSize = UIScreen.main.bounds.width / 2
    var selectedPin: CLLocationCoordinate2D?
    //  var pins: [Pin] = []
    var dataController: DataController!
    var page: Int = 0
    var cellsPerRow = 0
    var photos: [Photo] = []
    var APIPhotoVar: [APIPhoto] = []
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionPhotos.delegate = self
        let annotation = MKPointAnnotation()
        print(pin)
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
        loadfetchedPhotos()
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
        //  showActivityIndicator()
        PhotoSearch.searchPhotos(lat: selectedPin?.latitude ?? 0.0, lon: selectedPin?.longitude ?? 0.0, page: page) { response, error in
            if let response = response {
                print(response, "SUCCESS")
                let downloadedURLs = response.photos.photo
//                let randomPage = Int.random(in: 1...response.photos.pages)
//                self.page = randomPage
                for photo in self.photos {
                    let APIPhoto = APIPhoto(context: self.dataController.viewContext)
                    APIPhoto.imageUrl = photo.urlm
                    APIPhoto.pin = self.pin
                    self.APIPhotoVar.append(APIPhoto)
                    do {
                        try self.dataController.viewContext.save()
                    } catch {
                        print("Unable to get image url")
                    }
                }
                DispatchQueue.main.async {
                    self.collectionPhotos.reloadData()
                }
                self.collectionPhotos.reloadData()
            } else {
                print("Photos could not load")
            }
        }
    }
    
    func downloadPhotos(url: URL, _ indexPath: IndexPath, _ cell: ImageCellView){
        let cellImage = APIPhotoVar[indexPath.row]
        PhotoSearch.downloadPhoto(url: url) { (data, error) in
            if (data != nil) {
                DispatchQueue.main.async {
                    cellImage.image = data
                    cellImage.pin = self.pin
                    do {
                        try self.dataController.viewContext.save()
                    } catch {
                        print("There was an error saving photos")
                    }
                    DispatchQueue.main.async {
                        cell.PhotoCell?.image = UIImage(data: data!)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlertAction(title: "There was an error downloading photos", message: "Sorry")
                }
                
            }
            DispatchQueue.main.async {
                print("Photos loaded")
            }
        }
    }
    // https://classroom.udacity.com/nanodegrees/nd003/parts/9f3d04d4-d74a-4032-bf01-8887182fee62/modules/bbdd0d82-ac18-46b4-8bd4-246082887515/lessons/62c0b010-315c-4a1c-9bab-de477fff1aab/concepts/49036d1d-4810-4bec-b973-abe80a5dee6b
    func loadfetchedPhotos(){
        let fetchRequest: NSFetchRequest<APIPhoto> = APIPhoto.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        do {
            let fetchphotos = try dataController.viewContext.fetch(fetchRequest)
            APIPhotoVar = fetchphotos
            for persistedPhotos in photos {
                photos.append(persistedPhotos)
                collectionPhotos.reloadData()
            }
        } catch {
            showAlertAction(title: "Error", message: "Could not load photos")
        }
    }

    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return APIPhotoVar.count
    }
    
    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellView", for: indexPath) as! ImageCellView
        let cellImage = APIPhotoVar[indexPath.row]
        
        if cellImage.image != nil {
            cell.PhotoCell.image = UIImage(data: cellImage.image!)
        } else {
            if cellImage.imageUrl != nil {
                let url = URL(string: cellImage.imageUrl ?? "")
                downloadPhotos(url: url!, indexPath, cell)
            }
        }
        return cell
    }
    
    
    // MARK: Collection View Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
         let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
         let size = Int((collectionPhotos.bounds.width - totalSpace) / CGFloat(cellsPerRow))
         return CGSize(width: size, height: size)
    }
}
