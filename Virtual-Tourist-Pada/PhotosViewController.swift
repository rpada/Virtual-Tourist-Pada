

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

class PhotosViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var NewCollection: UIButton!
    @IBOutlet weak var collectionPhotos: UICollectionView!
    @IBOutlet weak var Map: MKMapView!
    // https://developer.apple.com/forums/thread/112480
    fileprivate let cellSize = UIScreen.main.bounds.width / 2
    var selectedPin: CLLocationCoordinate2D?
    var dataController: DataController!
    var page: Int = 0
    let numberOfCellsPerRow: CGFloat = 4
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
        APIPhotoVar = fetchFlickrPhotos()
        if APIPhotoVar.count > 0 {
            fetchFlickrPhotos()
        } else {
            loadPhotos()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  loadPhotos()
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
        PhotoSearch.searchPhotos(lat: selectedPin?.latitude ?? 0.0, lon: selectedPin?.longitude ?? 0.0, page: page, completion: { (response, error) in
            if let response = response {
                if response.photos.pages == 0 {
                    self.showAlertAction(title: "Error", message: "No photos found for this location.")
                } else {
                    print("loading for the first time")
                    self.photos = (response.photos.photo)
                    let numberofPages = response.photos.pages
                    self.page = Int.random(in: 1...(numberofPages))
                    for photo in self.photos {
                        let newPhoto = APIPhoto(context: self.dataController.viewContext)
                        newPhoto.imageUrl = photo.urlm
                        newPhoto.pin = self.pin
                        self.APIPhotoVar.append(newPhoto)
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            self.showAlertAction(title: "Error", message: "Could not load image URL")
                        }
                    }
                    self.collectionPhotos.reloadData()
                }
            } else {
                self.showAlertAction(title: "There was an error retrieving photos", message: "Sorry")
            }
        })
    }
    @IBAction func loadNewCollection(_ sender: Any) {
        APIPhotoVar = []
        loadPhotos()
        collectionPhotos.reloadData()
    }
    
//    func downloadPhotos(url: URL, _ indexPath: IndexPath, _ cell: ImageCellView){
//        let cellImage = APIPhotoVar[indexPath.row]
//
//        PhotoSearch.downloadPhoto(url: url) { (data, error) in
//            if let data = data{
//                cellImage.image = data
//                cellImage.pin = self.pin
//                do {
//                    try self.dataController.viewContext.save()
//                } catch {
//                    print("There was an error saving photos")
//                }
//                    DispatchQueue.main.async {
//                        cell.PhotoCell?.image = UIImage(data: data)
//                    }
//            } else {
//                self.showAlertAction(title: "Error", message: "Could not download photo")
//            }
//        }
//    }
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil{
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    // https://classroom.udacity.com/nanodegrees/nd003/parts/9f3d04d4-d74a-4032-bf01-8887182fee62/modules/bbdd0d82-ac18-46b4-8bd4-246082887515/lessons/62c0b010-315c-4a1c-9bab-de477fff1aab/concepts/49036d1d-4810-4bec-b973-abe80a5dee6b
    // photo fetch request (PERSISTENCE)
      func fetchFlickrPhotos() -> [APIPhoto] {
          let fetchRequest: NSFetchRequest<APIPhoto> = APIPhoto.fetchRequest()
          let predicate = NSPredicate(format: "pin == %@", pin)
          fetchRequest.predicate = predicate
          do {
              let result = try dataController.viewContext.fetch(fetchRequest)
              APIPhotoVar = result
              for newPhoto in APIPhotoVar {
                  APIPhotoVar.append(newPhoto)
                  print("showing fetched photos")
                  collectionPhotos.reloadData()
              }
          } catch {
              showAlertAction(title: "There was an error retrieving photos", message: "Sorry")
          }
          return APIPhotoVar
      }
    
    // MARK: Collection View Data Source
    //from Udacity Lession 8.8 Setup the Sent Memes Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return APIPhotoVar.count
    }
    //from Udacity Lession 8.8 Setup the Sent Memes Collection View
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCellView", for: indexPath) as! ImageCellView

        let cellImage = APIPhotoVar[indexPath.row]
       
        if cellImage.imageUrl != nil{
            let url = URL(string: cellImage.imageUrl ?? "")
            downloadImage(imagePath: url!.absoluteString) {(data, error) in
                DispatchQueue.main.async{
                    cell.PhotoCell.image = UIImage(data: data!)
                }
            }
        } else {
            cell.PhotoCell.image = UIImage(systemName: "photo")
        }
        return cell
    }
    // from Meme Me 2.0
    // https://stackoverflow.com/questions/38028013/how-to-set-uicollectionviewcell-width-and-height-programmatically
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
       {
          return CGSize(width: 100.0, height: 100.0)
       }
    // with help from Udacity mentor https://knowledge.udacity.com/questions/848663
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
