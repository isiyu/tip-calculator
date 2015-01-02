//
//  ViewController.swift
//  TipCalc
//
//  Created by Siyu Song on 12/18/14.
//  Copyright (c) 2014 siyu. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var roundingControl: UISegmentedControl!
    
    @IBOutlet weak var tipPercentField: UITextField!
    @IBOutlet weak var tipPercentSlider: UISlider!
    
    //@IBOutlet weak var totalsView: UIView!
    @IBOutlet var tipMainView: UIView!
    @IBOutlet weak var totalsView: UIView!
    @IBOutlet weak var controlSubView: UIView!
    @IBOutlet weak var billAmountView: UIView!
    
    // outlets of UI compnents (views)
    @IBOutlet weak var controlsUIView: UIView!
    @IBOutlet weak var billAmountUIView: UIView!
    @IBOutlet weak var totalsUIView: UIView!
    @IBOutlet weak var tiptotalUIView: UIView!
    
    
    // Storing previous billAmount Values
    // setting up the formatter
    let formatter = NSNumberFormatter()
    var locale = "en_US"
    var storedBillAmount: Float = 0.0
    var storedBillAmountStr: String = ""
    var zeroStringVal: String = ""
    
    var date = NSDate()
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    let colorGreen = UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //var currentLocale = NSLocale.currentLocale().localeIdentifier

        tiptotalUIView.layer.cornerRadius = 10
        tiptotalUIView.layer.masksToBounds = true
        
        self.view.backgroundColor = colorGreen
        
        updateDefaultLocaleFormatting()
        //initialize the string to trigger hiding controllers
        zeroStringVal = formatter.stringFromNumber( NSNumber( float: 0.0))!
  
        // initialize the tip text
        tipLabel.text = "$0.00"
        totalLabel.text = "$0.00"
        
        // load the saved value from appDelegate
        // there is logic in there to reset the bill amount
        // after a certain amount of time has passed
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        storedBillAmount = appDelegate.initialBillValue
        
        storedBillAmountStr = formatter.stringFromNumber(NSNumber(float:storedBillAmount))!
        billField.text = storedBillAmountStr
        // end updating bill amount refresh
        
        billField.becomeFirstResponder()
    }
    
    @IBAction func roundingControlUpdated(sender: UISegmentedControl) {
        /*
             Rounding mode updated, update calculated tips
        */

        /*
        // code is here to test the billAmount reset
        // viewDidLoad was not being triggered by the iOS emulator
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        storedBillAmount = appDelegate.initialBillValue
        
        storedBillAmountStr = formatter.stringFromNumber(NSNumber(float:storedBillAmount))!
        billField.text = storedBillAmountStr

        return
        */
        updateCalculatedTips()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // update the format locales
        updateDefaultLocaleFormatting()
        
        // need to update the billFiled with the new formatting
        storedBillAmountStr = formatter.stringFromNumber(NSNumber(float: storedBillAmount))!
        billField.text = (storedBillAmountStr)
        
        // Load the default tip %
        var defaults = NSUserDefaults.standardUserDefaults()
        var defaultTipPercent = defaults.floatForKey("default_tip_percent")
        
        tipPercentSlider.setValue( defaultTipPercent, animated:false )
        
        //set the value in the field to the slider last
        self.tipPercentSliderUpdated(self)
        //see if the container subviews need to be hidden
        refreshContainerViewsVisability()
    }

    func updateDefaultLocaleFormatting() {
        /*
            - reformats the bill amount string
              based on float value
            - called when bill formatting is updated
        */
        var defaults = NSUserDefaults.standardUserDefaults()
        
        // load the default locales
        var defaultLocale = defaults.stringForKey("default_locale")
        if defaultLocale == nil {
            defaultLocale = "en_US"
        }
        formatter.locale = NSLocale(localeIdentifier: defaultLocale!)
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
    }
    
    func refreshBillFieldDisplay() {
        // update display on bill field
        
        storedBillAmountStr = formatter.stringFromNumber(NSNumber(float:storedBillAmount))!
        billField.text = storedBillAmountStr

        var billFieldAmountStr = billField.text
        var billNewAmount : String = updateBillAmount(billFieldAmountStr, prevBillStr: storedBillAmountStr)
        
        storedBillAmountStr = billNewAmount
        var billNewAmountNS : NSNumber = formatter.numberFromString(billNewAmount)!
        storedBillAmount = billNewAmountNS.floatValue
        billField.text = billNewAmount
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tipPercentSliderUpdated(sender: AnyObject) {
        /*
            slider view control
        */
        var sliderValue = tipPercentSlider.value
        var tipInt:Int = Int(sliderValue*100)
        
        tipPercentField.text = String(format: "%d%%", tipInt)
        
        updateCalculatedTips()
    }
    
    func updateBillAmount(newBillStr:String, prevBillStr:String) -> String {
        /*
            Given two bill amounts newBill, prevBill as floats
            if new bill has one char less (last operation was a backspace)
            return the value of the last character
        
            else return nil
        */
        
        var returnBill : Double = 0.0
        var prevBillNS : NSNumber = formatter.numberFromString(prevBillStr)!
        var prevBill = prevBillNS.doubleValue
        
        
        if (countElements(newBillStr) < countElements(prevBillStr)) {
            //new bill has fewer chars remove last decimal point
            // figure out the Cent digit before dividing by 10
            // (to avoid rounding issues)
            var centVal = prevBill % 0.1
            returnBill = (prevBill - centVal) / 10
            
        } else {
            // new bill has more chars, added value
            // find value of newest char

            // get the value of the last character in the
            // new bill string as a floating point cent value
            // billField always adds char to the end of the string
            var lastChar = Array(newBillStr)[countElements(newBillStr) - 1]
            var lastCharString = String(lastChar)
            var lastCharNSstring = NSString(string:lastCharString)
            var lastCharFloat = Double(lastCharNSstring.floatValue / 100)
            returnBill = prevBill * 10 + lastCharFloat
        }
        
        return formatter.stringFromNumber(NSNumber(double: returnBill))!
    }
    
    func updateCalculatedTips () {
        // updating all the values of the bills
        // and updates the displays in the bill field
        
        var tipPercentage = tipPercentSlider.value
        var tipInt:Int = Int(tipPercentage*100)
        var tipDouble:Double = Double(tipInt) / 100
        var billAmount = Double(storedBillAmount)
        
        //Get the rounding mode
        var roundingMode = roundingControl.selectedSegmentIndex
        var tip = Double(billAmount) * tipDouble
        var total = Double(billAmount) + tip
        
        
        if roundingMode == 1 {
            //formatted dollar values
            tipLabel.text = formatter.stringFromNumber(NSNumber(double: tip))
            totalLabel.text = formatter.stringFromNumber(NSNumber(double: total))
            return
        }
        
        if roundingMode == 2 {
            var roundedTotal = total + 0.99
            var roundedTotalInt:Int = Int(roundedTotal)
            roundedTotal = Double(roundedTotalInt)
            total = roundedTotal
            tip = roundedTotal - billAmount
        } else if roundingMode == 0 {
            var roundedTotal = total
            var roundedTotalInt:Int = Int(roundedTotal)
            roundedTotal = Double(roundedTotalInt)
            total = roundedTotal
            tip =  roundedTotal - billAmount
            
            if tip < 0 {
                tip = 0.0
                total = Double(billAmount)
            }
        }
        
        //some rounding happened - calc actual tip %
        // avoid rounding by 0:
        var actualTipPercent:Double = 0.0
        if billAmount != 0 {
            actualTipPercent = tip / billAmount
        }
        
        var tipPercentInt:Int = Int(actualTipPercent*100)
        var tipText:String = formatter.stringFromNumber(NSNumber(double: tip))! + String(format:" (%d%%)",tipPercentInt)
            
        //formatted dollar values
        //tipLabel.text = formatter.stringFromNumber(NSNumber(double: tip))
        tipLabel.text = tipText
        totalLabel.text = formatter.stringFromNumber(NSNumber(double: total))
    }
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        /*
            function for updated bill field text
        */
        var billFieldAmountStr = billField.text
        var billNewAmount : String = updateBillAmount(billFieldAmountStr, prevBillStr: storedBillAmountStr)
        
        storedBillAmountStr = billNewAmount
        var billNewAmountNS : NSNumber = formatter.numberFromString(billNewAmount)!
        storedBillAmount = billNewAmountNS.floatValue
        billField.text = billNewAmount
        
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(storedBillAmount, forKey: "stored_bill_amount")
        defaults.synchronize()
        
        // refresh the control containers visability
        updateCalculatedTips()
        refreshContainerViewsVisability()
    }
    
    func refreshContainerViewsVisability(){
        /*
            animation controls for hiding controls
            as well as position of the bill amount field
        */
        if billField.text == zeroStringVal {
            UIView.animateWithDuration(0.3, animations: {
                // This causes first view to fade in and second view to fade out
                self.totalsView.alpha = 0
                self.controlSubView.alpha = 0
                self.billAmountView.frame = CGRectMake(0, 150, 320, 70)
            })
            
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                // This causes first view to fade in and second view to fade out
                self.totalsView.alpha = 1
                self.controlSubView.alpha = 1
                self.billAmountView.frame = CGRectMake(0, 65, 320, 70)
            })
            
        }
    }
    
    @IBAction func onTap(sender: AnyObject) {
        // hide the keypad on taps
        view.endEditing(true)
    }
    
}

