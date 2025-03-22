import UIKit
import AVFoundation
import MapKit
import CoreLocation
import Alamofire


class ApprovalPageVc: UIViewController, CLLocationManagerDelegate, AVCapturePhotoCaptureDelegate,UITabBarDelegate {
    
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var inoutview: UIView!
    @IBOutlet weak var punchinview: UIView!
    @IBOutlet weak var punchoutview: UIView!
    @IBOutlet weak var Mapview: MKMapView!
    @IBOutlet weak var tabbarview: UITabBar!
    @IBOutlet weak var historyview: UIView!
    @IBOutlet weak var tabbartableview: UITableView!
    @IBOutlet weak var currentlocationview: UIView!
    @IBOutlet weak var currentlocationlbl: UILabel!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let manager = CLLocationManager()
    var photoOutput: AVCapturePhotoOutput!
    var capturedImage: UIImage?

   
    var tableData: [[String]] = [
        ["Entry 1", "Entry 2"],
        ["Entry A", "Entry B"],
        ["Item X", "Item Y"] ,
        ["Item X", "Item Y"],
        ["Item X", "Item Y"]
    ]

    var sectionHeaders: [String] = ["First Section", "Second Section", "Third Section", "test", "Tesfvsi"]
    var currentCameraPosition: AVCaptureDevice.Position = .front
    var capturedImageView: UIImageView!
    var currentAddress: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupCamera()
        inoutview.isHidden = false
        inoutview.layer.cornerRadius = 8
        punchinview.layer.cornerRadius = 8
        punchoutview.layer.cornerRadius = 8
        currentlocationview.layer.cornerRadius = 8
        historyview.isHidden = true
        
        setupCapturedImageView()
        tabbarview.delegate = self
        tabbartableview.delegate = self
        tabbartableview.dataSource = self
        tabbartableview.reloadData()

        tabbartableview.register(UINib(nibName: "AssignListCell", bundle: nil), forCellReuseIdentifier: "AssignListCell")
    }
    
    func setupCapturedImageView() {
            capturedImageView = UIImageView(frame: cameraView.bounds)
            capturedImageView.contentMode = .scaleAspectFill
            capturedImageView.isHidden = true
            cameraView.addSubview(capturedImageView)
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
           if item.tag == 0 {
               historyview.isHidden = false
           } else if item.tag == 1 {
               historyview.isHidden = true
           }
       }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        Mapview.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                self.currentAddress = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                pin.title = self.currentAddress
                self.Mapview.addAnnotation(pin)
                
                DispatchQueue.main.async {
                    self.currentlocationlbl.text = self.currentAddress
                }
            } else {
                self.currentAddress = "Location not found"
                pin.title = self.currentAddress
                self.Mapview.addAnnotation(pin)
                
                DispatchQueue.main.async {
                    self.currentlocationlbl.text = self.currentAddress
                }
            }
        }
        
    }
    
    @IBAction func switchCameraButtonAction(_ sender: UIButton) {
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        configureCamera(position: currentCameraPosition)
    }
    
    @IBAction func PunchInbtn(_ sender: UIButton) {
        captureAndSendRequest(status: "0")
          
    }
    
    
    @IBAction func Punchoutbtn(_ sender: UIButton) {
        captureAndSendRequest(status: "1")
        
    }
    
    func captureAndSendRequest(status: String) {
        guard let photoOutput = photoOutput else {
            print("PhotoOutput is nil")
            return
        }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.guestRequest(status: status)
        }
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        photoOutput = AVCapturePhotoOutput()
        configureCamera(position: currentCameraPosition)
    }

    func configureCamera(position: AVCaptureDevice.Position) {
            captureSession.beginConfiguration()
            if let currentInput = captureSession.inputs.first {
                captureSession.removeInput(currentInput)
            }
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
                print("No camera available")
                cameraView.isHidden = true
                return
            }
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                }
            } catch {
                print("Error setting up camera input: \(error)")
                return
            }
            captureSession.commitConfiguration()
            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = .resizeAspectFill
                previewLayer!.frame = cameraView.bounds
                cameraView.layer.addSublayer(previewLayer!)
            }
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            previewLayer.frame = cameraView.bounds
            capturedImageView.frame = cameraView.bounds
            view.bringSubviewToFront(switchCameraButton)
        }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            print("Image capture failed")
            return
        }
        
        capturedImageView.image = image
        capturedImageView.isHidden = false
        capturedImage = image
        captureSession.stopRunning()
    }

    
    @objc func messageOnClick(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let alert = UIAlertController(title: "Alert", message: "Coming Soon....", preferredStyle: .alert)
           let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
           alert.addAction(okAction)
           if let viewController = sender.window?.rootViewController {
               viewController.present(alert, animated: true, completion: nil)
           }
    }
    
    
    func guestRequest(status: String) {
        var dict = [String: Any]()
        dict["EmpCode"] = currentUser.EmpCode
        dict["status"] = status
        dict["location"] = currentAddress
        
        let epochTime = Int(Date().timeIntervalSince1970)
        dict["time"] = epochTime
        
        if let image = capturedImage?.resizeTowidth(250), let imageData = image.pngData() {
            dict["file"] = imageData
        } else {
            print("No image captured")
            return
        }
        
        let url = BASEURL + "/" + SelfAttendance
        DispatchQueue.main.async { Loader.showLoader() }
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in dict {
                if key == "file", let imageData = value as? Data {
                    let filename = "\(Int64(Date().timeIntervalSince1970 * 1000)).png"
                    multipartFormData.append(imageData, withName: key, fileName: filename, mimeType: "image/png")
                } else if let stringValue = "\(value)".data(using: .utf8) {
                    multipartFormData.append(stringValue, withName: key)
                }
            }
        }, to: url)
        .uploadProgress { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .responseJSON { response in
            DispatchQueue.main.async { Loader.hideLoader() }
            
            switch response.result {
            case .success(let value):
                if let jsonResponse = value as? [String: Any], let status = jsonResponse["status"] as? Bool {
                    let message = jsonResponse["message"] as? String ?? "Unknown error"
                    
                    DispatchQueue.main.async {
                        self.showAlert(title: status ? "Success" : "Success", message: message)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Invalid response format")
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    let errorMessage = (error as? URLError)?.code == .notConnectedToInternet ? "No internet connection" : error.localizedDescription
                    self.showAlert(title: "Upload Failed", message: errorMessage)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension ApprovalPageVc: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignListCell", for: indexPath) as? AssignListCell else {
            return UITableViewCell()
        }
     
        cell.AssignLbl.text = tableData[indexPath.section][indexPath.row]
        cell.locationonclick.tag = indexPath.row
        cell.locationonclick.addTarget(self, action: #selector(messageOnClick(_:)), for: .touchUpInside)
        return cell
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
}
extension UIImage {
        func resizeTowidth(_ width:CGFloat)-> UIImage {
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            imageView.image = self
            UIGraphicsBeginImageContext(imageView.bounds.size)
            imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result!
        }
    }
