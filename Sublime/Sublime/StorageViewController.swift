//
//  StorageViewController.swift
//  Sublime
//
//  Created by Eular on 5/5/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Charts

class StorageViewController: UIViewController {

    let pieChart = PieChartView()
    let cacheCell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
    let processing = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storage"
        view.backgroundColor = Constant.CapeCod
        
        view.addSubview(processing)
        processing.text = "0 %"
        processing.textAlignment = .Center
        processing.textColor = UIColor.whiteColor()
        processing.frame = CGRectMake(0, 0, view.width, 40)
        processing.atCenter(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        let total = Device.systemSize
        var tmp = 0
        
        Device.appSize({ percent in
            
            let per = Int(percent * 100)
            if per != tmp {
                tmp = per
                dispatch_async(dispatch_get_main_queue()) {
                    self.processing.text = "\(per) %"
                }
            }
            
        }, completion: { app, cache in
            
            let sublime = app / total * 100
            let available = Device.systemFreeSize / total * 100
            let other = 100 - available - sublime
            
            let xValues = ["Sublime", "Available", "Other"]
            let yValues = [sublime, available, other]
            
            dispatch_async(dispatch_get_main_queue()) {
                self.processing.removeFromSuperview()
                self.setupPieChart(xValues, values: yValues)
                self.setupCacheCell(cache.size)
            }
            
        })
    }
    
    func setupCacheCell(cache: String) {
        cacheCell.frame = CGRectMake(0, view.height - 80, view.width, 50)
        cacheCell.backgroundColor = RGB(100, 100, 100, alpha: 0.5)
        cacheCell.selectedBackgroundView = UIView(frame: cacheCell.frame)
        cacheCell.selectedBackgroundView?.backgroundColor = Constant.CapeCod
        cacheCell.accessoryType = .DisclosureIndicator
        cacheCell.textLabel?.text = "Cache"
        cacheCell.textLabel?.textColor = UIColor.whiteColor()
        cacheCell.imageView?.image = UIImage(named: "setting_cache")
        cacheCell.detailTextLabel?.text = cache
        view.addSubview(cacheCell)
        cacheCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cleanCache)))
    }
    
    func cleanCache() {
        cacheCell.selected = true
        Device.cache = 0
        cacheCell.detailTextLabel?.text = "0 KB"
    }
    
    func setupPieChart(dataPoints: [String], values: [Double]) {
        pieChart.frame = CGRectMake(0, 0, view.width, view.height - 100)
        pieChart.descriptionText = "Sublime 仅占有少量储存空间，建议清理手机中其他应用和数据"
        pieChart.descriptionTextAlign = .Center
        pieChart.descriptionTextPosition = CGPoint(x: pieChart.center.x, y: pieChart.height - 40)
        pieChart.descriptionTextColor = UIColor.whiteColor()
        pieChart.descriptionFont = pieChart.descriptionFont?.fontWithSize(10)
        pieChart.holeColor = UIColor.clearColor()
        pieChart.legend.position = .BelowChartCenter
        pieChart.legend.textColor = UIColor.whiteColor()
        pieChart.infoTextColor = UIColor.whiteColor()
        view.addSubview(pieChart)
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        var colors = ChartColorTemplates.liberty()
        colors.shift()
        pieChartDataSet.colors = colors
        pieChartDataSet.sliceSpace = 2
        
        
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        
        let pFormatter = NSNumberFormatter()
        pFormatter.numberStyle = .PercentStyle
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        pieChartData.setValueFormatter(pFormatter)
        
        pieChart.data = pieChartData
        
        pieChart.animate(xAxisDuration: 1.4)
    }
    
}
