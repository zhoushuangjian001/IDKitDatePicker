//
//  IDKitDatePicker.swift
//  IDKitDatePicker
//
//  Created by 周双建 on 2019/6/24.
//  Copyright © 2019 周双建. All rights reserved.
//

import UIKit

// MARK: -- Customize
@objc protocol IDKitCustomizeDatePickerDelegate {
    
    /// -- Customeize view of IDKitDatePicker
    @objc optional func idkitPicker(pickerView:UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    /// -- Customeize row count
    @objc optional func idkitPicker(pickerView:UIPickerView, numberOfRowsInComponent component: Int)->Int
    /// -- Customeize row height
    @objc optional func idkitPicker(pickerView:UIPickerView, rowHeightForComponent component: Int)->CGFloat
    /// -- Customeize row width
    @objc optional func idkitPicker(pickerView:UIPickerView, widthForComponent component: Int)->CGFloat
}

class IDKitDatePicker: UIControl {
    
    /// -- Customize delegate
    weak var delegate:IDKitCustomizeDatePickerDelegate?
    
    // -- Main attributes of class
    private lazy var picker:UIPickerView = {
        let _picker = UIPickerView.init()
        _picker.delegate = self
        _picker.dataSource = self
        return _picker
    }()
    
    // -- Calendar of IDKitDatePicker
    private lazy var calendar:Calendar = {
        let _calendar = Calendar.init(identifier: .gregorian)
        return _calendar
    }()
    
    /// -- Date min value
    var minDate:Date = Date.init(timeIntervalSince1970: 0)
    
    /// -- Date max value
    var maxDate:Date?
    
    /// -- Current date
    var date:Date?
    
    /// -- Whether to show undately
    var isShowUndately:Bool = true
    
    // -- Default parameter initialization
    private var isThisYear:Bool = false
    private var isThisMoth:Bool = false
    private var thisMonthCount:Int = 0
    private var thisDayCount:Int = 0
    private var yearCount:Int = Int(INT16_MAX)
    
    /// -- Set text color
    var textColor:UIColor = .black
    
    /// -- Result of farmat
    var attachMark:String = "-"
    
    /// -- Return result
    var result:String?
    
    // -- Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(){
        super.init(frame: CGRect.zero)
        addElements()
    }
    
    // -- Faset  init
    convenience init(frame:CGRect, minDate:Date, maxDate:Date, isSUndatelay:Bool = true) {
        self.init(frame: frame)
        self.minDate = minDate
        self.maxDate = maxDate
        isShowUndately = isSUndatelay
        addElements()
    }
}

/// -- Class other method
extension IDKitDatePicker {
    
    // -- Add elements
    private func addElements() {
        self.backgroundColor = UIColor.white
        addSubview(self.picker)
        // -- layout
        if self.frame == .zero {
            self.picker.translatesAutoresizingMaskIntoConstraints = false
            let constraintTop:NSLayoutConstraint = NSLayoutConstraint(item: picker, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
            let constraintLeft:NSLayoutConstraint = NSLayoutConstraint(item: picker, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0)
            let constraintBottom:NSLayoutConstraint = NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
            let constraintRight:NSLayoutConstraint = NSLayoutConstraint(item: picker, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0)
         self.addConstraints([constraintTop,constraintLeft,constraintBottom,constraintRight])
        }else{
            picker.frame = self.frame
        }
    }
    
    /// -- Data initialization refresh
    func idkitPickerRefreshData() {
        if !isShowUndately {
            if maxDate == nil {
                maxDate = Date.init(timeIntervalSinceNow: -1 * 3600 * 24)
            }
            let components:DateComponents = self.calendar.dateComponents([.year], from: minDate, to: maxDate!)
            yearCount = components.year!
        }
        if date == nil {
            date = self.getCustomizeDate(value: "1990-01-01")
        }
        let monthRow:Int = self.getCurDateCount(format: "MM", date: date!)
        let dayRow:Int = self.getCurDateCount(format: "dd", date: date!)
        let minRow:Int = self.getCurDateCount(format: "yyyy", date: minDate)
        let curRow:Int = self.getCurDateCount(format: "yyyy", date: date!)
        let language = self.getSystemLanguage()
        if language.contains("zh") {
            self.scrollTo(object: (curRow - minRow,0), (monthRow - 1,1),(dayRow - 1,2))
        }else{
            self.scrollTo(object: (monthRow - 1,0),(dayRow - 1,1),(curRow - minRow,2))
        }
        // -- Set result value of no select
        let ryear:Int = curRow - minRow
        let rmonth:Int = monthRow - 1
        let rday:Int = dayRow - 1
        self.getResult(year: ryear, month: rmonth, day: rday)
    }
}

// MARK: -- pickerView delegate
extension IDKitDatePicker:UIPickerViewDelegate,UIPickerViewDataSource {
    
    // -- Number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // -- Number of row in component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count:Int = 0
        if (self.delegate != nil) && self.responds(to: #selector(self.delegate?.idkitPicker(pickerView:numberOfRowsInComponent:))) {
            count = self.delegate!.idkitPicker!(pickerView: pickerView, numberOfRowsInComponent: component)
        }else{
            let language = self.getSystemLanguage()
            if language.contains("zh") {
                if component == 0 {
                    count = yearCount + 1
                }else if component == 1 {
                    count = isThisYear ? thisMonthCount:12
                }else if component == 2 {
                    count = isThisMoth ? thisDayCount:31
                }
            }else{
                if component == 0 {
                    count = isThisYear ? thisMonthCount:12
                }else if component == 1 {
                    count = isThisMoth ? thisDayCount:31
                }else if component == 2 {
                    count = yearCount + 1
                }
            }
        }
        return count
    }

    // -- Width of row in component
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if (self.delegate != nil) && self.responds(to: #selector(self.delegate!.idkitPicker(pickerView:widthForComponent:))) {
            return self.delegate!.idkitPicker!(pickerView: pickerView, widthForComponent: component)
        }
        return UIScreen.main.bounds.width * 1.0 / 3;
    }
    
    // -- Height of row in component
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if (self.delegate != nil) && self.responds(to: #selector(self.delegate!.idkitPicker(pickerView:rowHeightForComponent:))) {
            return self.delegate!.idkitPicker!(pickerView: pickerView, rowHeightForComponent: component)
        }
        return 44
    }
    
    // -- View of row in component
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if (self.delegate != nil) && self.responds(to: #selector(self.delegate!.idkitPicker(pickerView:viewForRow:forComponent:reusing:))) {
            return self.delegate!.idkitPicker!(pickerView: pickerView, viewForRow: row, forComponent: component, reusing: view)
        }else{
            let tempLabel = UILabel.init()
            tempLabel.textAlignment = .center
            tempLabel.font = .systemFont(ofSize: 16)
            tempLabel.textColor = self.textColor
            tempLabel.backgroundColor = .clear
            let language = self.getSystemLanguage()
            if language.contains("zh") {
                // -- month
                if component == 0 {
                    let rowDate = Date.init(timeInterval: TimeInterval(row * 3600 * 24 * 366), since: minDate)
                    let rowYear = self.getCurDateCount(format: "yyyy", date: rowDate)
                    tempLabel.text = "\(rowYear)年"
                }
                // -- day
                if component == 1 {
                    let max = self.calendar.maximumRange(of: .month)!.upperBound - 1
                    let index = row % max
                    tempLabel.text = "\(index + 1)月"
                }
                // -- year
                if component == 2 {
                    let max = self.calendar.maximumRange(of: .day)!.upperBound - 1
                    let index = row % max
                    tempLabel.text = "\(index + 1)日"
                }
            }else{
                // -- month
                if component == 0 {
                    let max = self.calendar.maximumRange(of: .month)!.upperBound - 1
                    let index = row % max
                    tempLabel.text = self.getMonthEn(row: index)
                }
                // -- day
                if component == 1 {
                    let max = self.calendar.maximumRange(of: .day)!.upperBound - 1
                    let index = row % max
                    tempLabel.text = "\(index + 1)"
                }
                // -- year
                if component == 2 {
                    let rowDate = Date.init(timeInterval: TimeInterval(row * 3600 * 24 * 366), since: minDate)
                    let rowYear = self.getCurDateCount(format: "yyyy", date: rowDate)
                    tempLabel.text = "\(rowYear)"
                }
            }
            return tempLabel
        }
    }
    
    // -- Select row in component
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var ryear:Int?
        var rmonth:Int?
        var rday:Int?
        let language = self.getSystemLanguage()
        if language.contains("zh") {
            // -- year
            if component == 0 {
                let rowDate = Date.init(timeInterval: TimeInterval(row * 3600 * 24 * 366), since: minDate)
                let cyear = self.getCurDateCount(format: "yyyy")
                let ryear = self.getCurDateCount(format: "yyyy", date: rowDate)
                if cyear == ryear {
                    isThisYear = true
                    thisMonthCount = self.getCurDateCount(format: "MM")
                    pickerView.reloadComponent(1)
                }else{
                    // -- Prevent repeated calls
                    if isThisYear {
                        isThisYear = false
                        pickerView.reloadComponent(1)
                    }
                }
            }
            
            // -- month
            if component == 1 {
                if isThisYear {
                    if row == (thisMonthCount - 1) {
                        isThisMoth = true
                        thisDayCount = self.getCurDateCount(format: "dd") - 1
                        pickerView.reloadComponent(2)
                    }else{
                        if isThisMoth {
                            isThisMoth = false
                            pickerView.reloadComponent(2)
                        }
                    }
                }
            }
            
            // -- select
            ryear = pickerView.selectedRow(inComponent: 0)
            rmonth = pickerView.selectedRow(inComponent: 1)
            rday = pickerView.selectedRow(inComponent: 2)
        }else{
            // -- month
            if component == 0 {
                if isThisYear {
                    if row == (thisMonthCount - 1) {
                        isThisMoth = true
                        thisDayCount = self.getCurDateCount(format: "dd") - 1
                        pickerView.reloadComponent(1)
                    }else{
                        if isThisMoth {
                            isThisMoth = false
                            pickerView.reloadComponent(1)
                        }
                    }
                }
            }
            
            // -- year
            if component == 2 {
                let rowDate = Date.init(timeInterval: TimeInterval(row * 3600 * 24 * 366), since: minDate)
                let cyear = self.getCurDateCount(format: "yyyy")
                let ryear = self.getCurDateCount(format: "yyyy", date: rowDate)
                if cyear == ryear {
                    isThisYear = true
                    thisMonthCount = self.getCurDateCount(format: "MM")
                    pickerView.reloadComponent(0)
                }else{
                    // -- Prevent repeated calls
                    if isThisYear {
                        isThisYear = false
                        pickerView.reloadComponent(0)
                    }
                }
            }
            ryear = pickerView.selectedRow(inComponent: 2)
            rmonth = pickerView.selectedRow(inComponent: 0)
            rday = pickerView.selectedRow(inComponent: 1)
        }
        self.getResult(year: ryear!, month: rmonth!, day: rday!)
    }
}

// MARK: -- extension method
extension IDKitDatePicker {
    
    // -- Get system language
    private func getSystemLanguage()->String {
        let appLanguage = UserDefaults.standard.object(forKey: "AppleLanguages") as! Array<String>
        return appLanguage.first!
    }
    
    // -- Get month of en
    private func getMonthEn(row:Int)->String {
        let monthArray:Array<String> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        return monthArray[row]
    }
    
    // -- Get count of current date
    private func getCurDateCount(format:String, date:Date = Date.init())->Int {
        let formatter = DateFormatter.init()
        formatter.locale = Locale.current
        formatter.dateFormat = format
        return Int(formatter.string(from: date)) ?? 0
    }
    
    // -- Scroll to the specified date
    private func scrollTo(object elements:Any..., animated:Bool = false) {
        for idTuples in elements {
            let (row, component) = (idTuples as! (Int, Int))
            self.picker.selectRow(row, inComponent: component, animated: animated)
        }
    }
    
    // -- Get customize  date
    private func getCustomizeDate(value:String, format:String = "yyyy-MM-dd")->Date {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        return formatter.date(from: value)!
    }
    
    // -- Get result
    private func getResult(year:Int, month:Int, day:Int) {
        let tDate = Date.init(timeInterval: TimeInterval(year * 3600 * 24 * 366), since: minDate)
        let maxDay = self.calendar.maximumRange(of: .day)!.upperBound - 1
        let maxMonth = self.calendar.maximumRange(of: .month)!.upperBound - 1
        let tMonth = month % maxMonth
        let tDay = day % maxDay
        let year = self.getCurDateCount(format: "yyyy", date: tDate)
        let month = String.init(format: "%.2d", tMonth + 1)
        let day = String.init(format: "%.2d", tDay + 1)
        self.result = "\(year)-" + month + "-" + day
        self.date = self.getCustomizeDate(value: self.result!)
    }
}
