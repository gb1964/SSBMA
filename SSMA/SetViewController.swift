//
//  SetViewController.swift
//  SSMA
//
//  Created by gb on 14-10-8.
//  Copyright (c) 2014年 com.darewaydigital. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {

    @IBOutlet weak var network: UITextField!
    
    @IBOutlet weak var port: UITextField!
    
    @IBOutlet weak var path: UITextField!
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func onOK(sender: AnyObject) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject("211.87.227.93", forKey:"network")
        userDefault.setObject("6060", forKey:"port")
        userDefault.setObject("SBM/REST", forKey:"path")
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let userDefault = NSUserDefaults.standardUserDefaults()
        network.text = userDefault.objectForKey("network") as NSString
        port.text = userDefault.objectForKey("port") as NSString
        path.text = userDefault.objectForKey("path") as NSString
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
        if (network.isFirstResponder() && touch.view != network){
            network.resignFirstResponder()
        }
        else if (port.isFirstResponder() && touch.view != port)
        {
            port.resignFirstResponder()
        }
        else if (port.isFirstResponder() && touch.view != path)
        {
            port.resignFirstResponder()
        }
        super.touchesBegan(touches, withEvent: event)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
