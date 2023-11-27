//
//  ViewController.swift
//  RecogniseAnimal
//
//  Created by Manish on 21/11/23.
//

import UIKit
import Vision


class ViewController: UIViewController {

    @IBOutlet weak var inputImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var supportedAnimals: UILabel!
    private let imagePicker = UIImagePickerController()
    
    private let processQueue = DispatchQueue(label: "process.queue.animals", qos: .userInitiated)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSupportedAnimals()
    }

    @IBAction func onSelectImageButtonTap(_ sender: Any) {
        self.imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
}

// MARK: - Recognise Animal
private extension ViewController {
    
    func recogniseAnimal() {
        
        guard let img = inputImage.image?.pngData() else {
            assertionFailure()
            // handle error
            return
        }
        
        processQueue.async {
            let request = VNRecognizeAnimalsRequest()
            let handler = VNImageRequestHandler(data: img)
            
            #if targetEnvironment(simulator)
            request.usesCPUOnly = true
            #endif
            
            do {
                try handler.perform([request])
                
                if let foundAnimals = request.results?.compactMap({ $0.labels.first?.identifier }).joined(separator: ", ") {
                    DispatchQueue.main.async {
                        if foundAnimals.isEmpty {
                            self.resultLabel.text = "Could not recognise"
                        } else {
                            self.resultLabel.text = foundAnimals
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.resultLabel.text = "Failed"
                }
                assertionFailure()
            }
        }
        
    }
    
    func setSupportedAnimals() {
        let request = VNRecognizeAnimalsRequest()
        
        do {
            let ids = try request.supportedIdentifiers()
            supportedAnimals.text = "Supported Animals: " + ids.map { $0.rawValue }.joined(separator: ", ")
        } catch {
            supportedAnimals.text = "Supported Animals: Nil"
        }
    }
    
}

// MARK: - Image Picker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
            let pickedImage = info[.originalImage] as? UIImage
            inputImage.image = pickedImage
            
            recogniseAnimal()
            
            picker.dismiss(animated: true)
    }
    
}
