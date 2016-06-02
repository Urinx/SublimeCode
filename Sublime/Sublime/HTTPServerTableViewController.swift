//
//  HTTPServerTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/23/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import Swifter
import SafariServices

class HTTPServerTableViewController: UITableViewController {
    
    @IBOutlet weak var portTF: UITextField!
    @IBOutlet weak var ipLB: UILabel!
    @IBOutlet weak var serverSW: UISwitch!
    @IBOutlet weak var pathSW: UISwitch!
    @IBOutlet weak var logTV: UITextView!
    
    private var server: HttpServer?
    private var serverLog: WebServerLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HTTP"
        
        let safariBtn = UIBarButtonItem(image: UIImage(named: "open_safari"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.openSafari))
        navigationItem.rightBarButtonItem = safariBtn
        
        if Network.isConnectedToNetwork() {
            let ip = Network.getIFAddresses()[0]
            ipLB.text = ip
        } else {
            ipLB.text = "localhost"
        }
        
        // Here is a bug: if first start SublimeServer then CustomServer doesn't work.
        // Idk why, so just add the following useless code.
        // ----- Don't forget move it to isConnectedToNetwork satuation ------
        let server = HttpServer()
        try! server.start()
        server.stop()
        
        serverLog = WebServerLog(output: logTV)
    }
    
    deinit {
        self.server?.stop()
        serverLog?.saveInLogFile(self.logTV.text)
    }
    
    @IBAction func serverStatusChanged(sender: UISwitch) {
        if sender.on {
            startServer(SublimeServer(serverLog))
        } else {
            self.server?.stop()
            serverLog?.log("Server has stopped.")
        }
        portTF.enabled = !sender.on
        pathSW.on = false
        pathSW.enabled = sender.on
    }
    
    @IBAction func pathEnableStatusChanged(sender: UISwitch) {
        startServer(sender.on ? CustomServer(serverLog) : SublimeServer(serverLog))
    }
    
    func startServer(server: HttpServer) {
        self.server?.stop()
        guard let port = portTF.text!.isEmpty ? 8080 : UInt16(portTF.text!) else {
            serverLog?.log("Error: please set valid port.", isError: true)
            return
        }
        do {
            try server.start(port)
            self.server = server
            serverLog?.log("Server has started: http://\(ipLB.text!):\(port).")
        } catch {
            serverLog?.log("Error: \(error)", isError: true)
        }
    }
    
    func openSafari() {
        guard let port = portTF.text!.isEmpty ? 8080 : UInt16(portTF.text!) else {return}
        let svc = SFSafariViewController(URL: NSURL(string: "http://localhost:\(port)")!)
        svc.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [4, 1][section]
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let secTitle = ["   HTTP", "   Log"]
        let title = UILabel(frame: CGRectMake(0, 0, view.width, Constant.FilesTableSectionHight))
        title.backgroundColor = Constant.CapeCod
        title.text = secTitle[section]
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(12)
        title.textAlignment = .Natural
        let headerView = UIView()
        headerView.addSubview(title)
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.FilesTableSectionHight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        portTF.resignFirstResponder()
    }

}
