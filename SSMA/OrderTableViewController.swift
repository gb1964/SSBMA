//
//  OrderTableViewController.swift
//  SSMA
//
//  Created by gb on 14-10-10.
//  Copyright (c) 2014年 com.darewaydigital. All rights reserved.
//

import UIKit

class OrderMTDDataModel : NSObject {
    var ddh:String = ""
    var ddscrq:String = ""
    var gysfk:String = ""
    var ddzt:String = ""
    var shzt:String = ""
}

class OrderTableViewController: UITableViewController {
    
    var data : Array<OrderMTDDataModel> = []
    var supplierString : String = ""
    var userString :String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.getOrderInFO()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 60.0
    }
    
    override func tableView(tableView: (UITableView!), numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        println("c=")
        println(self.data.count)

        return self.data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell...
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cellId_Order") as UITableViewCell
        println("data=")
        println(self.data.count)
        if (self.data.isEmpty){
            return cell
        }
        
        // Configure the cell...

        println(indexPath.row)
        let model:OrderMTDDataModel = self.data[indexPath.row] as OrderMTDDataModel
        var str: String = "订单号：" + model.ddh + "   " + self.supplierString
        str += "                     " + "生成日期：" + model.ddscrq
        var label: UILabel = cell.textLabel! as UILabel
        label.textColor = UIColor.blueColor()
        label.highlightedTextColor = UIColor.redColor()
        label.font = UIFont.systemFontOfSize(14.0)
        label.numberOfLines = 2
        label.text = str
        
        var subtitlestr: String = "     " + model.gysfk + "     " + model.ddzt + "     " + model.shzt
        var label1: UILabel = cell.textLabel! as UILabel
        label1.textColor = UIColor.redColor()
        label1.highlightedTextColor = UIColor.blueColor()
        label1.font = UIFont.systemFontOfSize(16.0)
        label1.text = subtitlestr
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    func getOrderInFO() {
        let reach = Reachability.reachabilityForInternetConnection()
        if (!reach.isReachable()) {
            let unavailAlert = UIAlertView(title:"警告：网络不通！",
                message:nil,
                delegate:nil,
                cancelButtonTitle:"关闭")
            unavailAlert.show()
  //          startToMove()
            return;
        }
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        let network = userDefault.objectForKey("network") as String
        let port = userDefault.objectForKey("port") as String
        let path = userDefault.objectForKey("path") as String
        let access_token = userDefault.objectForKey("access_token") as String
        let stringURL:String = "http://" + network + ":" + port + "/" + path + "/order/orderinquiry"
       
        let manager = AFHTTPRequestOperationManager()
        let url:String = stringURL + "?" + "gysdh=" + self.supplierString + "&cgzid=" + self.userString
        
        manager.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue(access_token, forHTTPHeaderField: "Authorization")
        manager.POST(url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON:" + responseObject.description!)
                
                var datas = NSJSONSerialization.dataWithJSONObject(responseObject, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                let jsonDic : NSDictionary! = NSJSONSerialization.JSONObjectWithData(datas!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                var array:NSArray! = jsonDic.objectForKey("ddxx") as NSArray
                if (array.count == 0)
                {
                    var subjson:AnyObject! = jsonDic.objectForKey("meta")
                    var message:String! = subjson.objectForKey("message") as String
                    var status:String! = subjson.objectForKey("mstatus") as String
                    if (message == "The token have no authorization" && status == "2") {
                        //                [SBMSet getRefreshToken];
                        self.getOrderInFO()
                    }
                }
                else
                {
                    for subjson in array
                    {
                        var model = OrderMTDDataModel()
                        model.ddh = subjson.objectForKey("ddh") as String
                        model.ddzt = subjson.objectForKey("ddzt") as String
                        model.shzt = subjson.objectForKey("shzt") as String
                        model.gysfk = subjson.objectForKey("gysfk") as String
                        model.ddscrq = subjson.objectForKey("ddscrq") as String
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
