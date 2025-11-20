//
//  ViewController.swift
//  BLESDKCallDemo
//
//  Created by Spectra-iOS on 19/03/25.
//

import UIKit
import SpectraBLEiOS
import Toast

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tblDeviceList: UITableView!
    
    var deviceList: [DeviceData] = [] // Store received device list

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white // Set background to white
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    
        
        tblDeviceList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblDeviceList.backgroundColor = .lightGray
        
//        let additionalInfo = """
//        {
//            \"no_of_fields\": 3,
//            \"fields\": [
//                {\"length\": 0, \"key\": \"DestinationFloor\", \"value\": 1},
//                {\"length\": 1, \"key\": \"BoardingFloor\", \"value\": 2},
//                {\"length\": 1, \"key\": \"SelectedFloor\", \"value\": 1}
//            ]
//        }
//        """
        
        let startTime = Date().timeIntervalSince1970
        UserDefaults.standard.set(startTime, forKey: "BLEStartTime")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            SpectraBLE.shared.stopScan()
        }

    }
    
    @objc func appDidBecomeActive() {
        InitSDK()
    }
    
    
    func InitSDK()
    {
        
//        let additionalInfo = """
//        {
//            \"no_of_fields\": 3,
//            \"fields\": [
//                {\"length\": 0, \"key\": \"DestinationFloor\", \"value\": 1},
//                {\"length\": 1, \"key\": \"BoardingFloor\", \"value\": 2},
//                {\"length\": 1, \"key\": \"SelectedFloor\", \"value\": 1}
//            ]
//        }
//        """
//        
        
        SpectraBLE.shared.initialize(encryptionKey:  "5844424A343639474542343939494230", bleTag: "1726397546", punchRange: 2)
        
        //SpectraBLE.shared.initialize(encryptionKey:  "123456", bleTag: "2141085659", punchRange: 2, additionalInfo: additionalInfo)
        { (event, data) in
            switch event {
            case .SUCCESS:
                print("SDK Initialized")
                
                if let bleSuccess = data as? BLEData {
                       print("success Code: \(bleSuccess.code), Message: \(bleSuccess.message)")
                    if bleSuccess.code != 100
                    {
                        guard let bleSuccess = data as? BLEData, let devices = bleSuccess.data as? [DeviceData] else {
                               print("⚠️ Failed to cast device list from BLEData")
                               return
                           }
                        
                        // Get device names as a comma-separated string
                        let deviceNames = devices.map { $0.deviceName }.joined(separator: ", ")
                        
                        // Construct the message
                        let finalMessage = "\(bleSuccess.message)"
                        
                        // Wait for the device list before showing the alert
                                   DispatchQueue.global().async {
                                       while self.deviceList.isEmpty {
                                           // Wait for the device list to be updated
                                           usleep(100_000) // Sleep for 100ms
                                       }

                                       // Get the first device name after device list is received
                                       let firstDeviceName = self.deviceList.first?.deviceName ?? "Unknown Device"
                                       
                                       // Format the final message with first device name
                                       let finalMessage = finalMessage + " on " + firstDeviceName

                                       // Show the alert on the main thread
                                       DispatchQueue.main.async {
                                           
                                           self.view.makeToast(finalMessage, duration: 2.0, position: .bottom)
                                       }
                                   }
                        
                        
                        
//                        let result = self.formatString(finalMessage)
//
//                        // Show the toast alert with the device names
//                        DispatchQueue.main.async {
//                            self.showAlert(title: "Alert", message: result)
//                        }
                    }
                
                   } else {
                       print("❌ Error: \(data)") // Fallback if data is not BLEData
                   }
                
            case .DEVICE_LIST:
                print("Devices List: \(data)")
                guard let bleSuccess = data as? BLEData, let devices = bleSuccess.data as? [DeviceData] else {
                       print("⚠️ Failed to cast device list from BLEData")
                       return
                   }

                   print("✅ Device List Received: \(devices)")
                   self.deviceList = devices

                   DispatchQueue.main.async {
                       self.tblDeviceList.reloadData()
                   }
            case .ERROR:
                
                if let bleError = data as? BLEData {
                       print("❌ Error Code: \(bleError.code), Message: \(bleError.message)")
                    self.view.makeToast(bleError.message, duration: 2.0, position: .bottom)
                    
                    //self.showAlert(title: "Alert", message: bleError.message)
                   } else {
                       print("❌ Error: \(data)") // Fallback if data is not BLEData
                   }
            default:
                print("Unknown event")
            }
        }
    }
    

    @IBAction func btnGetLogsTap(_ sender: Any) {
        
        guard let logFileURL = LogManager.shared.readLogs(),
                  FileManager.default.fileExists(atPath: logFileURL.path) else {
                let alert = UIAlertController(title: "No Logs", message: "Log file not found.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }

//            let activityVC = UIActivityViewController(activityItems: [logFileURL], applicationActivities: nil)
//    
//            self.present(activityVC, animated: true)
//        
        
        do {
            let logText = try String(contentsOf: logFileURL)
            let vc = LogVC() // Make sure this is connected via storyboard or XIB if not using storyboard ID
               vc.logs = logText
            self.present(vc, animated: true)
           } catch {
               print("Failed to read log file: \(error)")
           }
        
    }
    
    @IBAction func btnClearLogs(_ sender: Any) {
        
        LogManager.shared.clearLogs()
        let alert = UIAlertController(title: "Logs Cleared", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            if let topController = UIApplication.shared.topMostViewController() {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func formatString(_ input: String) -> String {
        let cleanedString = input.replacingOccurrences(of: ".", with: "") // Remove existing dots
        return cleanedString + "." // Append a dot at the end
    }
    
    
    // MARK: - UITableView DataSource Methods

      // Number of Rows
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return deviceList.count
      }

      // Cell Configuration
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                  let device = deviceList[indexPath.row]
                  cell.textLabel?.text = "\(device.deviceName) - \(device.deviceID)"
                  return cell
      }

}

extension UIApplication {
    func topMostViewController(controller: UIViewController? = UIApplication.shared.connectedScenes
                                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                                    .first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topMostViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            return topMostViewController(controller: tabController.selectedViewController)
        }
        if let presented = controller?.presentedViewController {
            return topMostViewController(controller: presented)
        }
        return controller
    }
}



// ✅ DeviceData Struct
public struct GetDeviceData: Codable {
    public let deviceName: String
    public let deviceType: String
    public let deviceID: String
    public let punchTime: String
}
