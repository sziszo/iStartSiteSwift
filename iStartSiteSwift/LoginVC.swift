//
//  LoginVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 17..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

class LoginVC: UIViewController {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    let loginService: LoginService = PLoginService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "Login"{
            let vc = segue.destinationViewController as ContainerViewController
//            vc.colorString = colorLabel.text
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        
        loginService.loginUser(txtUserName.text, withPassword: txtPassword.text) { user, error in
            
            AppDelegate.sharedAppDelegate().settings.currentUser = user

            if error != nil {
                let errorString = error.userInfo?["error"] as String
                UIAlertView(title: "Login failed", message: errorString, delegate: nil, cancelButtonTitle: "Ok").show()
            } else {                
                self.performSegueWithIdentifier("Login", sender: self)
            }
        }        
    }
    
    @IBAction func register(sender: AnyObject) {
        
        loginService.registerUser(txtUserName.text, withPassword: txtPassword.text) { user, error in

            if error != nil {
                let errorString = error.userInfo?["error"] as String
                UIAlertView(title: "Registration failed", message: errorString, delegate: nil, cancelButtonTitle: "Ok").show()
            } else {
                UIAlertView(title: "Success", message: "Successfull registration", delegate: nil, cancelButtonTitle: "Ok").show()
                self.performSegueWithIdentifier("Login", sender: self)
            }
        }
    }
    
}
