//
//  TweetsViewController.swift
//  ShowTwits
//
//  Created by Dmytro Rozumeyenko on 1/23/17.
//  Copyright © 2017 Appload. All rights reserved.
//

import UIKit
import TwitterKit
import DZNEmptyDataSet

let kDefaultTwitter = "CNN"

class TweetsViewController: TWTRTimelineViewController, TWTRTimelineDelegate, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.text = kDefaultTwitter
            searchBar.placeholder = "Put Twitter name here"
        }
    }
    
    var prevTwitterSource = kDefaultTwitter
    var shouldShowEmptyState = false
    
    deinit {
        self.tableView.emptyDataSetSource = nil
        self.tableView.emptyDataSetDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.timelineDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.dataLoad()
    }
    
    //MARK: Data load
    
    func dataLoad() {
        if let twitterName = self.searchBar.text {
            self.dataSource = TWTRUserTimelineDataSource(screenName: twitterName, apiClient: TWTRAPIClient())
        }
    }
    
    //MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.shouldShowEmptyState = false
        self.dissmissSearch()
        self.dataLoad()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if let text = searchBar.text, text.characters.count > 0 && self.countOfTweets() > 0 {
            self.prevTwitterSource = text
        }
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = self.prevTwitterSource
        self.dissmissSearch()
    }
    
    func dissmissSearch() {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    //MARK: TWTRTimelineDelegate

    func timeline(_ timeline: TWTRTimelineViewController, didFinishLoadingTweets tweets: [Any]?, error: Error?) {
        self.shouldShowEmptyState = true
        if tweets == nil || tweets?.count == 0 {
            self.tableView.reloadData()
        }
    }
    
    //MARK: DZNEmptyDataSetSource
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.shouldShowEmptyState
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
       return  NSAttributedString(string:  "No twits for account '\(self.searchBar.text ?? "")'", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.gray])
        
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        return  NSAttributedString(string: "Go back to '\(self.prevTwitterSource)' twitter", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.lightGray])
  
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.searchBar.text = self.prevTwitterSource
        self.dataLoad()
    }

    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        self.searchBar.isHidden = true
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        self.searchBar.isHidden = false
    }
}

