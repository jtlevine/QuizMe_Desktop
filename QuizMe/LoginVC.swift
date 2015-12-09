//
//  LoginVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/1/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class LoginVC: NSViewController {
    
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var login: NSButton!
    @IBOutlet weak var createAccount: NSButton!
    @IBOutlet weak var ceaseNotifications: NSButton!
    var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearFields()
        // Do view setup here.
    }
    
    func clearFields(){
        username.stringValue = ""
        password.stringValue = ""
    }
    
    func submitRequest(){
        let send_this = "name='\(username.stringValue)'&pw='\(password.stringValue)'"
        let request = getRequest(send_this, urlString: QUERY_USERNAME_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                //self.alertUser("Backend error")
                print("Login error")
                return
            }
            if let data = data{
                do{
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSArray{    //put response into JSON so can access like a dictionary
                        dispatch_async(dispatch_get_main_queue(), {
                            //self.aiSpinner.stopAnimating()
                            if(json.count == 1){//if username exists
                                for dic in json{
                                    if case let id as String = dic["uid"]{
                                        if case let name as String = dic["name"]{
                                            if case let pw as String = dic["password"]{
                                                if self.password.stringValue == pw { //compare the passwords
                                                    self.count = 1
                                                    UID = Int(id)!
                                                    USERNAME = name
                                                    self.clearFields()
                                                    print("correct username/password")
                                                    self.performSegueWithIdentifier("seg", sender: self)
                                                    

                                                }
                                                if self.count == 0{
                                                    alertUser("Incorrect password")
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            else{//if username doesn't exist
                                alertUser("Username does not exist")
                            }
                        })
                    }
                }
                catch _ as NSError {}
            }
        }
        task.resume()
    }
    
    @IBAction func login_onClick(sender: NSButton) {
        submitRequest()
    }
    
}
