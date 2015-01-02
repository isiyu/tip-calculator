//
//  SettingsViewController.swift
//  TipCalc
//
//  Created by Siyu Song on 12/22/14.
//  Copyright (c) 2014 siyu. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    @IBOutlet weak var defaultPercentageSlider: UISlider!
    @IBOutlet weak var defaultPercentageDisplay: UITextField!

    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet var currencyPickerData: [UIPickerView]!
    
    var localeDict = ["kr Krona": "sv_SE", "$ Dollar": "en_US", "£ Pounds": "en_GB", "€ Euro": "fr_FR"]

    var localeDictKeys:[String] = []
    
    let colorGreen = UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        
        //
        self.view.backgroundColor = colorGreen
        
        // update the text display to match the tip slider
        self.defaultPercentageSliderUpdated(self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load the default tip %
        var defaults = NSUserDefaults.standardUserDefaults()
        var defaultTipPercent = defaults.floatForKey("default_tip_percent")
        defaultPercentageSlider.setValue( defaultTipPercent, animated:false )
        
        // Load the default locale
        var defaultLocale = defaults.stringForKey("default_locale")
        if defaultLocale == nil {
            defaultLocale = "en_GB"
        }
        defaultLocaleUpdated(defaultLocale!)
        
        // get the keyName of defaultLocale
        // creating a list of strings out of keys for defaultLocaleDict
        // This is used in the listview for locale selection
        var defaultLocaleKey: String = "$ Dollar"
        for key in localeDict.keys {
            if localeDict[key] == defaultLocale {
                defaultLocaleKey = key
            }
        }
        
        for key in localeDict.keys{
            localeDictKeys.append(key)
        }
        var defaultLocaleIndex:Int?
        
        for (i, value) in enumerate(localeDictKeys) {
            if defaultLocaleKey == value {
                defaultLocaleIndex = i
            }
        }
        currencyPicker.selectRow( defaultLocaleIndex!, inComponent: 0, animated: false )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func defaultLocaleUpdated(localeName:String){
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(localeName, forKey: "default_locale")
        defaults.synchronize()
    }
    
    @IBAction func defaultPercentageSliderUpdated(sender: AnyObject) {
        
        var sliderValue = defaultPercentageSlider.value
        var tipInt:Int = Int(sliderValue*100)
        println("sliderValue")
        println(sliderValue)
        //println("tipPercent")
        //println(tipPercent)
        
        defaultPercentageDisplay.text = String(format: "%d%%", tipInt)
 
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setFloat(sliderValue, forKey: "default_tip_percent")
        defaults.synchronize()
        
    }

    func numberOfComponentsInPickerView(currencyPicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return localeDictKeys.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selected = localeDictKeys[row]
        var localeName:String = localeDict[selected]!
        defaultLocaleUpdated(localeName)
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = localeDictKeys[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
    }
    
    
    @IBAction func doneButtonSelected(sender: UIButton) {
        self.dismissViewControllerAnimated( true , completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
