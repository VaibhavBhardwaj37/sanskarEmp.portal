import UIKit
import AVFoundation
import MapKit
import CoreLocation



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
                let address = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                pin.title = address
                self.Mapview.addAnnotation(pin)
                // Set current address in label
                DispatchQueue.main.async {
                    self.currentlocationlbl.text = address
                }
            } else {
                pin.title = "Location not found"
                self.Mapview.addAnnotation(pin)
                DispatchQueue.main.async {
                    self.currentlocationlbl.text = "Location not found"
                }
            }
        }
    }


    
    @IBAction func switchCameraButtonAction(_ sender: UIButton) {
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        configureCamera(position: currentCameraPosition)
    }
    
    @IBAction func PunchInbtn(_ sender: UIButton) {
        guard let photoOutput = photoOutput else {
            print("PhotoOutput is nil")
            return
        }
            let settings = AVCapturePhotoSettings()
                    settings.flashMode = .auto
                    photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    @IBAction func Punchoutbtn(_ sender: UIButton) {
        
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
