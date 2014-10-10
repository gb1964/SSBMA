//
//  ViewController.swift
//  SSMA
//
//  Created by gb on 14-9-12.
//  Copyright (c) 2014年 com.darewaydigital. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet var user: UITextField!
    @IBOutlet var passwd: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var actInd: UIActivityIndicatorView!
    
    @IBAction func onLogin(sender: AnyObject) {
        user.resignFirstResponder()
        passwd.resignFirstResponder()
        
        let username = String(user.text)
        let password = String(passwd.text)
        
        if (username.isEmpty || password.isEmpty)
        {
            let alertMessage = UIAlertView(title:"登录失败!!!",
                                        message:"帐号或密码为空!!!",
                                        delegate:nil,
                                        cancelButtonTitle:"确认")
            alertMessage.show()
            return;
        }
        //   _btnLogin.enabled = NO;
        startToMove()
        startLogin()
}
    
    @IBAction func onSet(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject("211.87.227.93", forKey:"network")
        userDefault.setObject("6060", forKey:"port")
        userDefault.setObject("SBM/REST", forKey:"path")
        
        setHidden()
        //    _btnLogin.enabled = YES;
    
        let arr = Array(SSKeychain.accountsForService("DarewaySSBMA"))
        let temp: AnyObject = arr[arr.count - 1]
        user.text = temp.valueForKey("acct") as NSString
        passwd.text = SSKeychain.passwordForService("DarewaySSBMA", account:user.text)
        //    [self findPosition];
        startToMove()
  //      startLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func textFieldReturn(sender: AnyObject){
        sender.resignFirstResponder()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
        let touch = touches.anyObject() as UITouch
        if (user.isFirstResponder() && touch.view != user){
            user.resignFirstResponder()
        }
        else if (passwd.isFirstResponder() && touch.view != passwd)
        {
            passwd.resignFirstResponder()
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    /*
    func dimissAlert(alert: UIAlertView) {
            alert.dismissWithClickedButtonIndex(alert.cancelButtonIndex, animated:true)
    }
    
    func showAlert(title: NSString, message: NSString){
        let alert = UIAlertView(title: title, message: message, delegate: nil,  cancelButtonTitle: nil)
        alert.show()
        performSelector(selector: "dimissAlert", withObject: alert, afterDelay: 2.0)
    }
*/
    func startToMove() {
       if (actInd.isAnimating()){
//            actInd.setHidden(FALSE)
            actInd.stopAnimating()
        }
        else{
            actInd.stopAnimating()
        }
        view.addSubview(actInd)
    }
    
    func setHidden() {
//        actInd.setHidden(TRUE)
        actInd.hidesWhenStopped = true
    }
    
    func startLogin() {
        let reach = Reachability.reachabilityForInternetConnection()
        if (!reach.isReachable()) {
            let unavailAlert = UIAlertView(title:"警告：网络不通！",
                message:nil,
                delegate:nil,
                cancelButtonTitle:"关闭")
            unavailAlert.show()
            startToMove()
            return;
        }
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        let network = userDefault.objectForKey("network") as String
        let port = userDefault.objectForKey("port") as String
        let path = userDefault.objectForKey("path") as String
        let stringURL:String = "http://" + network + ":" + port + "/" + path + "/loginimpl/logintest"
        
        let manager = AFHTTPRequestOperationManager()
        let url:String = stringURL + "?" + "username=" + user.text + "&password=" + passwd.text

        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("Basic c2JtX3Jlc3Q6c2R1YXNw", forHTTPHeaderField: "Authorization")
        manager.POST(url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON:" + responseObject.description!)
                
                var data = NSJSONSerialization.dataWithJSONObject(responseObject, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                let jsonDic : AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                let str = jsonDic.objectForKey("flag") as NSString
                if (str.isEqualToString("success")) {
                    let subjson = jsonDic.objectForKey("meta") as NSDictionary
                    let refresh_token_str: AnyObject? = subjson.objectForKey("refresh_token")
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    userDefault.setObject(refresh_token_str, forKey: "refresh_token")
                
                    let access_token_str: AnyObject? = subjson.objectForKey("access_token")
                    userDefault.setObject(access_token_str, forKey: "access_token")
                    println(refresh_token_str)
                    println(access_token_str)
        
                    self.startToMove()
                    
                    self.presentNextViewController()
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error:" + error.localizedDescription)
            }
        )
    }
    
    func presentNextViewController() {
        SSKeychain.setPassword(passwd.text, forService:"DarewaySSBMA", account:user.text)
    
        let mainStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("HomeView") as UIViewController
    
 //       viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical
        self.presentViewController(viewController, animated:true, completion:nil)
    }
}
