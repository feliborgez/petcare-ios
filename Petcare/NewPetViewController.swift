//
//  PetController.swift
//  Petcare
//
//  Created by Gustavo Gomes de Oliveira on 28/11/16.
//  Copyright © 2016 Felipe Borges. All rights reserved.
//

import UIKit
import CoreData
import CZPicker
import DatePickerDialog
import WatchConnectivity
import NotificationCenter

class PetController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CZPickerViewDelegate, CZPickerViewDataSource {
    
    let dao = CoreDataDAO<Pet>()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let pets = [["Cat": UIImage(named: "catIcon")], ["Dog": UIImage(named: "dogIcon")]]
    var sex: String = "Male"
    var date: Date?
    
    let czpicker = CZPickerView(headerTitle: "Species", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
    
    var petToCreate: Pet!
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var breed: UITextField!
    
    @IBOutlet weak var type: UITextField!
    
    @IBOutlet weak var birthdayTextField: UITextField!
    

    @IBOutlet weak var sexSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.delegate = self
        self.breed.delegate = self
        self.type.delegate = self
        self.birthdayTextField.delegate = self
                
        czpicker?.delegate = self
        czpicker?.dataSource = self
        
        czpicker?.allowMultipleSelection = false
        
        czpicker?.needFooterView = true
        
        self.type.allowsEditingTextAttributes = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        
    }
    

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.white
        
        if (((textField.placeholder?.description)! as String == "Animal")
            || ((textField.placeholder?.description)! as String == "Birthdate")) {
            
            return false
            
        } else {
            
            return true
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        switch sexSegment.selectedSegmentIndex {
        case 0:
            self.sex = "Male"
        case 1:
            self.sex = "Female"
        default:
            break;
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                print(self.view.frame.origin.y)
                self.view.frame.origin.y -= (keyboardSize.height - 50)
                print(self.view.frame.origin.y)

            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                print(self.view.frame.origin.y)

                self.view.frame.origin.y += (keyboardSize.height - 50)
                print(self.view.frame.origin.y)

            }
        }
    }
    
    func validatePet() -> Bool{
        
        var petIsOk = true
        
        
        if (self.name.text?.isEmpty)! {
            
            petIsOk = false
            self.name.backgroundColor = UIColor(colorLiteralRed: 255, green: 0, blue: 0, alpha: 0.3)
            
        } else {
            
            self.name.backgroundColor = UIColor.white

        }
        
        if (self.breed.text?.isEmpty)! {
            
            petIsOk = false
            self.breed.backgroundColor = UIColor(colorLiteralRed: 255, green: 0, blue: 0, alpha: 0.3)
            
        }
        
        if (self.type.text?.isEmpty)! {
            
            petIsOk = false
            self.type.backgroundColor = UIColor(colorLiteralRed: 255, green: 0, blue: 0, alpha: 0.3)

        }
        
        if (self.birthdayTextField.text?.isEmpty)! {
            
            self.birthdayTextField.backgroundColor = UIColor(colorLiteralRed: 255, green: 0, blue: 0, alpha: 0.3)
            
        }
        
        return petIsOk
        
    }
    
    
    
    func create(pet: Pet){
 
        dao.insert(pet)
        
    }
    
    func delete(pet: Pet){
        
        dao.delete(pet)
    }
    
    func update(pet: Pet){
        
        var petToUpdate = getByID(id: pet.objectID)
        
        petToUpdate = pet
        
        dao.update(petToUpdate)
    }
    
    func getAll() -> [Pet] {
        
        return dao.getAll()
    }
    
    func getByID(id: NSManagedObjectID) -> Pet{
        
        return dao.getByID(id)
    }

    
    func buildPet(){
        
        if validatePet() {
            
            let imageData: NSData = UIImagePNGRepresentation(imagePicked.image!)! as NSData
            
            self.petToCreate = Pet(name: self.name.text!, birthdate: self.date! as NSDate as NSDate, breed: self.breed.text!, photo: imageData, sex: self.sex, type: self.type.text!, context: self.context)
            
        }
        
        
    }
    
    func savePet() {
        
        self.create(pet: petToCreate)
        
    }
    

    // MARK: - Get camera Image
    
    
    @IBAction func openLibraryButton(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicked.image = pickedImage
        }
        
        self.dismiss(animated: true, completion: nil);
        
    }
    
    // MARK: - Segue

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        buildPet()
        
        var shouldSegue = false
        
        if identifier == "prefrerencesSegue" {
            
            shouldSegue =  validatePet()
            
        }
        
        return shouldSegue
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        savePet()
        
        let dict = ["Name": self.petToCreate.name!, "Type": self.petToCreate.type!,
                    "Breed": self.petToCreate.breed!, "TypeSended": "Pet"] as [String : Any]
                
        WCSession.default().transferUserInfo(["Created": dict, "TypeSended": "Pet"])
        let confirmPetController = segue.destination as! ConfirmPetViewController
        
        confirmPetController.pet = petToCreate
    }
    
    // MARK: - CZPicker

    
    func numberOfRows(in pickerView: CZPickerView!) -> Int {
        return pets.count
    }
    
    func czpickerView(_ pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        return pets[row].keys.first
    }
    
    func czpickerView(_ pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
        return pets[row].values.first!
    }
    
    func czpickerView(_ pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        type.text = pets[row].keys.first
    }
    
    
    @IBAction func speciesFieldTouchDown(_ sender: UITextField) {
       // czpicker?.show()
        let options = [
            ["value": "Cat", "display": "Cat"],
            ["value": "Dog", "display": "Dog"]
        ]
        
        PickerDialog().show("Species", options: options) { (value) in
            
            self.type.text = value
        }
    }
   
    
    @IBAction func birthdayFieldTouchDown(_ sender: UITextField) {
        DatePickerDialog().show("Pet's birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), datePickerMode: .date, callback: { (date) in
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            if let date = date {
                self.birthdayTextField.text = formatter.string(from: date)
                
                self.date = date
            }
            
            
        })
        
        sender.resignFirstResponder()
    }
    

}
