//
//  ETAPopOverController.swift
//  findmybusnj
//
//  Created by David Aghassi on 1/18/16.
//  Copyright © 2016 David Aghassi. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: Dependancies
import NetworkManager

class ETASearchPopOverController: UIViewController {
  private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  // MARK: Formatters
  private let alertPresenter = ETAAlertPresenter()
  // MARK: DataSource
  private var favorites = [NSManagedObject]()
  
  // MARK: Outlets
  @IBOutlet weak var stopNumberTextField: UITextField!
  @IBOutlet weak var filterRouteNumberTextField: UITextField!
  @IBOutlet weak var favoritesTableView: UITableView!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Get the MoC and create the fetch request
    let managedObjectContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "Favorite")
    
    //3
    do {
      let results = try managedObjectContext.executeFetchRequest(fetchRequest)
      favorites = results as! [NSManagedObject]
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
  
  // MARK: Segue
  // Source of idea: http://jamesleist.com/ios-swift-tutorial-stop-segue-show-alert-text-box-empty/
  /**
  Overrides the `shouldPerformSegueWithIdentifier` method. Called before a segue is performed. Checks that if the segue identifier is `search`, and then checks whether or not the `stopNumberInput` is empty or not.
  
  - Parameters:
    - identifier: String identifier of the current segue trigger
    - sender: The object initiating the segue
  - return: A boolean that defines whether or not the segue should transition
  */
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if (identifier == "search") {
      
      // Check to see if user entered a stop number
      guard let stop = stopNumberTextField.text else {
        showEmptyWarning()
        return false
      }
      if (stop.isEmpty) {
        showEmptyWarning()
        return false
      }
    }
    
    return true
  }
  
  /**
   Creates a UIAlertController to notify the user they have not entered the proper stop information
   */
  private func showEmptyWarning() {
    let warning = alertPresenter.presentAlertWarning(ETAAlertEnum.Empty_Search)
    presentViewController(warning, animated: true, completion: nil)
  }
}

// MARK: UITextFieldDelegate
extension ETASearchPopOverController: UITextFieldDelegate {
  
  // Source of idea: http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield?rq=1
  /**
  Regulates the `textField` to a certain range. `1` is the `filterBusNumberInput` field tag, and `0` is the `stopNumberInput` tag.
  */
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    // If the current character count is nil, we set it to zero using nil coelescing
    guard let textFieldText = textField.text else {
      return false
    }
    
    let currentCharCount = textFieldText.characters.count ?? 0;
    if (range.length + range.location > currentCharCount) {
      return false
    }
    let newLength = currentCharCount + string.characters.count - range.length
    
    if (textField.tag == 0) { // Stop textField
      return newLength <= 5
    }
    else if (textField.tag == 1) { // Route textField
      return newLength <= 3
    }
    else {
      return false
    }
  }
  
  /**
   On hitting return, the current `textField` will resign the keyboard
   
   - parameter textField: The current `textField` that has triggered a return
   - return A boolean value if the `textField` should return or not.
   */
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

// MARK: UITableViewDataSource
extension ETASearchPopOverController: UITableViewDataSource {
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favorites.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("FavCell")
    let index = indexPath.row
    
    let favItem = favorites[index] as! Favorite
    
    cell?.textLabel?.text = favItem.stop
    
    return cell!
  }
}
