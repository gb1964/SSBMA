//
//  SupplerTableViewController.swift
//  SSMA
//
//  Created by gb on 14-10-8.
//  Copyright (c) 2014年 com.darewaydigital. All rights reserved.
//

import UIKit

class SupplierDataModel : NSObject {
    var num:String = ""
    var name:String = ""
    var orderNum:String = ""
}

class SupplerTableViewController: UITableViewController {
    
    var data : Array<SupplierDataModel> = []
    var userString : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.getSupplierList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: (UITableView!)) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: (UITableView!), numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        println(self.data.count)
        return self.data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell...

        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cellId_Supplier") as UITableViewCell
        
        let model: SupplierDataModel  = self.data[indexPath.row] as SupplierDataModel
        let str = model.name
        var label: UILabel = cell.textLabel! as UILabel
        label.textColor = UIColor.blueColor()
        label.highlightedTextColor = UIColor.blueColor()
        label.font = UIFont.systemFontOfSize(14.0)
//        label.lineBreakMode = NSLineBreakByTruncatingTail
        label.numberOfLines = 1
        label.text = str;
        
        
        let subtitlestr = model.orderNum as NSString
        let label1: UILabel = cell.detailTextLabel!
        label1.textColor = UIColor.redColor()
        label1.highlightedTextColor = UIColor.redColor()
        label1.font = UIFont.systemFontOfSize(18.0)
        label1.numberOfLines = 1
        label1.text = subtitlestr;

        return cell
    }

/*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
*/

    // Override to support editing the table view.
    override func tableView(tableView: (UITableView!), commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: (NSIndexPath!)) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let viewController: OrderTableViewController = segue.destinationViewController as OrderTableViewController;
        let selectedIndex: NSIndexPath = self.tableView.indexPathForSelectedRow() as NSIndexPath!
        
        let model  = self.data[selectedIndex.row] as SupplierDataModel
        viewController.supplierString = model.num
        viewController.userString = self.userString
    }
    
    func getSupplierList (){
        let reach = Reachability.reachabilityForInternetConnection()
        if (!reach.isReachable()) {
            let unavailAlert = UIAlertView(title:"警告：网络不通！",
                message:nil,
                delegate:nil,
                cancelButtonTitle:"关闭")
            unavailAlert.show()
//            startToMove()
            return;
        }
        let userDefault = NSUserDefaults.standardUserDefaults()
        let network = userDefault.objectForKey("network") as String
        let port = userDefault.objectForKey("port") as String
        let path = userDefault.objectForKey("path") as String
        let access_token = userDefault.objectForKey("access_token") as String
        let stringURL:String = "http://" + network + ":" + port + "/" + path + "/user/supplierlist"
        
        let arr = Array(SSKeychain.accountsForService("DarewaySSBMA"))
        let temp: AnyObject = arr[arr.count - 1]
        self.userString = temp.valueForKey("acct") as String
        
        let manager = AFHTTPRequestOperationManager()
        let url:String = stringURL + "?" + "username=" + self.userString
        
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(access_token, forHTTPHeaderField: "Authorization")
        manager.GET(url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON:" + responseObject.description!)
                
                var datas = NSJSONSerialization.dataWithJSONObject(responseObject, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                let jsonDic : NSDictionary! = NSJSONSerialization.JSONObjectWithData(datas!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary

                var array:NSArray! = jsonDic.objectForKey("enterprise") as NSArray
                if (array.count == 0)
                {
                    var subjson:AnyObject! = jsonDic.objectForKey("meta")
                    var message:String! = subjson.objectForKey("message") as String
                    var status:String! = subjson.objectForKey("mstatus") as String
                    if (message == "The token have no authorization" && status == "2") {
                        //                [SBMSet getRefreshToken];
                        self.getSupplierList()
                    }
                }
                else
                {
                    for subjson in array
                    {
                        var model = SupplierDataModel()
                        model.num = subjson.objectForKey("gysdh") as String
                        model.name = subjson.objectForKey("cjmc") as String
                        model.orderNum = subjson.objectForKey("len") as String
                        self.data.append(model)
                    }
                    self.tableView.reloadData()
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error:" + error.localizedDescription)
            }
        )
    }
}

