//
//  ViewController.swift
//  CrudCloudFirestore
//
//  Created by GraceToa on 03/05/2019.
//  Copyright © 2019 GraceToa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var table: UITableView!
    
    var ref: DocumentReference!
    var getRef: Firestore!
    var listUsers = [User]()
    var image: UIImage?
    var imagePicker: UIImagePickerController = UIImagePickerController()


    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        
        getRef = Firestore.firestore()
        let settings = getRef.settings
        settings.areTimestampsInSnapshotsEnabled = true
        getRef.settings = settings
        
        getDataRealTimeFBCloud()
        viewWillAppear(true)
    }
    
    // MARK:- UITableViewDelegate methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserTableViewCell
        let user: User
        user = listUsers[indexPath.row]
        cell.nameCell.text = user.name
        cell.emailCell.text = user.email
        
        let urlPhoto = user.image
        Storage.storage().reference(forURL: urlPhoto).getData(maxSize: 5 * 1024 * 1024, completion: {  (data, error) in
            if  let error = error?.localizedDescription {
                print("error load image Firebase", error)
            }else{

                cell.imageCell.image = UIImage(data: data!)
                cell.imageCell.makeRounded()
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let id = table.indexPathForSelectedRow {
                let line = listUsers[id.row]
                let destin = segue.destination as! DetailViewController
                destin.user = line
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath)in
            let user: User
            user = self.listUsers[indexPath.row]
            let id = user.id
            self.getRef.collection("users").document(id).delete()
            let image = user.image
            let imgDelete = Storage.storage().reference(forURL: image)
            imgDelete.delete(completion: nil)
        }
        return [delete]
    }
 
    //MARK:- Method helpers
    
    func getDataRealTimeFBCloud()  {
        getRef.collection("users").addSnapshotListener { (QuerySnapshot, err) in
            if let err = err {
                print("Error gettind documents: \(err)")
            }else{
                self.listUsers.removeAll()
                for document in QuerySnapshot!.documents {
                    let id = document.documentID
                    let value = document.data()
                    let name = value["name"] as? String ?? ""
                    let lastname = value["lastname"] as? String ?? "without lastname"
                    let email = value["email"] as? String ?? "not email"
                    let imageUrl = value["image"] as? String ?? "not image"
                    let user = User(name: name, lastname: lastname, id: id, email: email, image: imageUrl)

                    self.listUsers.insert(user, at: 0)
                    self.refreshUI()
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }


    @IBAction func saveBtn(_ sender: Any) {
        let storage = Storage.storage().reference()
        let imgName = UUID()//esto nos genera un id
        let directory = storage.child("images/\(imgName)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let imageData = image?.jpegData(compressionQuality: 0.25)

        directory.putData(imageData!, metadata: metaData, completion: {(data,error)in
            if error == nil {
                print("load image Ok")
            }else{
                if let error = error?.localizedDescription{
                    print("error Load image in firebase",error)
                }else{
                    print("error in code")
                }
            }
        })
        
        let fields: [String: Any] = ["name": nameTF.text!, "lastname": lastnameTF.text!, "email": emailTF.text!, "image":String(describing: directory) ]
        ref = getRef.collection("users").addDocument(data: fields, completion: {(error)in
            if let error = error?.localizedDescription{
                print("error in save Firebase", error)
            }else{
                print("OK save")
                self.nameTF.text = ""
                self.lastnameTF.text = ""
                self.emailTF.text = ""
            }
        })
    }
    
    func refreshUI() { DispatchQueue.main.async { self.table.reloadData() } }
    
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK:- UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageTake = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        image = imageTake!
 
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Add Picture
    
    @IBAction func addPicture(sender: AnyObject) {

        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary

            present(imagePicker, animated: true, completion: nil)
        } else {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion:nil)
        }
    }
    
}

extension UIImageView {
    func makeRounded() {
        let radius = self.frame.size.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
