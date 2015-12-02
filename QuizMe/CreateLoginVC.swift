//
//  CreateLoginVC.swift
//  QuizMe
//
//  Created by Josh Levine on 12/2/15.
//  Copyright © 2015 Josh Levine. All rights reserved.
//

import Cocoa

class CreateLoginVC: NSViewController {

    @IBOutlet weak var newUsername: NSTextField!
    @IBOutlet weak var password1: NSSecureTextField!
    @IBOutlet weak var submit: NSButton!
    @IBOutlet weak var password2: NSSecureTextField!
    @IBOutlet weak var cancel: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func passwordsMatch() -> Bool{
        if password1.stringValue != "" && password1.stringValue == password2.stringValue{
            return true
        }
        else{
            alertUser("Password mismatch")
            return false
        }
    }
    
    func queryUser(){
        let send_this = "name='\(newUsername.stringValue)'&pw='\(password2.stringValue)'"
        let request = getRequest(send_this, urlString: QUERY_USERNAME_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with creating login")
                return
            }
            if let data = data{
                do{
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSArray{    //put response into JSON so can access like a dictionary
                        if(json.count == 0){
                            self.createUser()
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue(), {
                                alertUser("Username taken")
                            })
                        }
                    }
                }
                catch _ as NSError {}
            }
        }
        task.resume()
    }
    
    func createUser(){
        let send_this = "name='\(newUsername.stringValue)'&pw='\(password2.stringValue)'"
        let request = getRequest(send_this, urlString: CREATE_USER_PHP)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            (data, response, error) in  //all this happens once request has been completed, in another queue
            if error != nil{
                print("Error with creating login")
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                alertUser("Username created")
                NSNotificationCenter.defaultCenter().postNotificationName(notification_key_login, object: self)
                self.view.window?.performClose(self)
            })
            
        }
        task.resume()
    }
    
    @IBAction func submit_onClick(sender: NSButton) {
        if passwordsMatch() {queryUser()}
    }
    @IBAction func cancel_onClick(sender: NSButton) {
        self.view.window?.performClose(self)
    }
}
