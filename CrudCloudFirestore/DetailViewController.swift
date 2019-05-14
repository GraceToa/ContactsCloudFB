//
//  DetailViewController.swift
//  CrudCloudFirestore
//
//  Created by GraceToa on 06/05/2019.
//  Copyright © 2019 GraceToa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    var user: User!
    var ref: DocumentReference!
    var id = ""
    var urlPhoto = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTF.text = user.name
        lastnameTF.text = user.lastname
        emailTF.text = user.email
        
        urlPhoto = user.image
        Storage.storage().reference(forURL: urlPhoto).getData(maxSize: 5 * 1024 * 1024, completion: {  (data, error) in
            if  let error = error?.localizedDescription {
                print("error load image Firebase", error)
            }else{
                self.image.image = UIImage(data: data!)
                self.image.makeRounded()
            }
        })
        id = user.id
        ref = Firestore.firestore().collection("users").document(id)
    }
    

    @IBAction func editBtn(_ sender: Any) {
        let fields: [String: Any] = ["name": nameTF.text!, "lastname": lastnameTF.text!, "email": emailTF.text!, "image": urlPhoto]
        ref.setData(fields){(error)in
            if let error = error?.localizedDescription {
                print("Error update", error)
            }else{
                print("OK update")
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func exitBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension UIImageView {
    func makeRounded2() {
        let radius = self.frame.size.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}

