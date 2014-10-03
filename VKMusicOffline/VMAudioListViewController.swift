//
//  DetailViewController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VMAudioListViewController: UITableViewController, UISearchResultsUpdating, VMAudioCellDelegate
{
    var audioList: VMAudioList! = nil {
        willSet {
            if (self.searchResultsController != nil) {
                self.searchResultsController.audioList = newValue
            }
        }
    }
    var searchController: UISearchController!
    var searchResultsController: VMAudioListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonI  tem = self.editButtonItem()
    
        if let parentViewController = self.parentViewController {
            if parentViewController is UINavigationController {
                self.searchResultsController = self.storyboard?.instantiateViewControllerWithIdentifier("VMAudioListViewController") as VMAudioListViewController
                self.searchResultsController.audioList = self.audioList
                self.searchController = UISearchController(searchResultsController: self.searchResultsController)
                self.searchController.searchResultsUpdater = self.searchResultsController
                
                self.definesPresentationContext = true
                
                self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
                self.tableView.tableHeaderView = self.searchController.searchBar;
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.audioList != nil) ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchResultsController == nil) {
            return self.audioList.filteredAudios.count
        } else {
            return self.audioList.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VMAudioCell", forIndexPath: indexPath) as VMAudioCell
        cell.delegate = self
        
        var audio : VMAudio! = nil
        if (self.searchResultsController == nil) {
            audio = self.audioList.filteredAudios[indexPath.row]
        } else {
            audio = self.audioList[indexPath.row]
        }
        cell.audio = audio
        
        return cell
    }


    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.audioList.count - 1 &&
            self.audioList.hasNextPage()) {
            self.audioList.loadNextPage(completion: { (error: NSError!) -> Void in
                tableView.reloadData()
            })
        }
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            return self.searchController.searchBar
//        } else {
//            return nil
//        }
//    }
//    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 44
//        } else {
//            return 0
//        }
//    }
    
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

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showLyrics") {
            let controller = segue.destinationViewController as VMLyricsController
            let audioCell = sender as VMAudioCell
            controller.lyrics = audioCell.audio.lyrics
        }
    }
    
    @IBAction func unwindFromSegue(segue: UIStoryboardSegue) {
        
    }

    
    // MARK: - VMAudioCellDelegate
    
    func audioCellLyricsButtonPressed(cell: VMAudioCell) {
        self.performSegueWithIdentifier("showLyrics", sender: cell)
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.audioList.searchTerm = searchController.searchBar.text
    }
    
}
