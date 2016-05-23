//
//  ArticlesTableViewController.swift
//  Spotlight
//
//  Created by Dan Ionescu on 12/04/16.
//  Copyright © 2016 Alt Tab. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

struct ArticleKeys {
    static let Title = "title"
    static let Content = "text"
    static let UUID = "uuid"
    static let ThumbName = "thumb"
    static let ImageName = "image"
    static let Summary = "summary"
}

class ArticlesTableViewController: UITableViewController {

    var Articles: [[String: String]]!

    let ArticlesDomainIdentifier = "co.alttab.articles"
    let ArticlesIndexVersionKey = "co.alttab.articles.VersionKey"
    let ArticlesIndexVersion = 1

    var selectedArticle: [String: String]?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadArticles()

        indexArticlesIfNeeded()
    }

    func loadArticles() {
        Articles = NSArray(contentsOfURL: NSBundle.mainBundle().URLForResource("Articles", withExtension: "plist")!)! as! [[String : String]]
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Articles.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        let article = Articles[indexPath.row]

        cell.textLabel?.text = article[ArticleKeys.Title]

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showArticle(Articles[indexPath.row])
    }

    func showArticle(article: [String: String]?) {
        guard let article = article else {
            return
        }

        self.selectedArticle = article
        self.performSegueWithIdentifier("ShowArticle", sender: self)
    }

    func showArticleWithUniqueIdentifier(uniqueIdentifier: String) {
        let article = Articles.filter { (article) -> Bool in
            return article[ArticleKeys.UUID] == uniqueIdentifier
        }.first

        showArticle(article)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        guard let segueIdentifier = segue.identifier else {
            return
        }

        switch segueIdentifier {
        case "ShowArticle":
            let vc: ArticleViewController = segue.destinationViewController as! ArticleViewController
            vc.article = self.selectedArticle

            break

        default:
            break;

        }

    }

    // MARK: - Indexing
    func indexArticlesIfNeeded() {
        let oldArticlesIndexVersion = NSUserDefaults.standardUserDefaults().integerForKey(ArticlesIndexVersionKey)

        guard oldArticlesIndexVersion < ArticlesIndexVersion else {
            return
        }

        // something better can be done here
        // deleting only the ones that do no appear in the new articles
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithDomainIdentifiers([ArticlesDomainIdentifier]) { (error) in
            self.indexArticles()
        }
    }

    func indexArticles() {
        let searchableItems = Articles.map { (article) -> CSSearchableItem in
            return searchableItemForArticle(article)
        }

        guard searchableItems.count > 0 else {
            return;
        }

        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) { [unowned self] (error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                print("Items indexed.")
                NSUserDefaults.standardUserDefaults().setInteger(self.ArticlesIndexVersion, forKey: self.ArticlesIndexVersionKey)
            }
        }
    }

    func searchableItemForArticle(article: [String: String]) -> CSSearchableItem {
        // Describe the item with the attribute set
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        // Set the item details
        attributeSet.title = article[ArticleKeys.Title]
        attributeSet.contentDescription = article[ArticleKeys.Summary]
        attributeSet.keywords = article[ArticleKeys.Title]?.componentsSeparatedByString(" ")

        let thumbName = article[ArticleKeys.ThumbName]

        if let thumb = UIImage(named: thumbName!) {
            attributeSet.thumbnailData = UIImagePNGRepresentation(thumb)
        }

        // Create the  item with a unique identifier, the domain identifier and the attribute set
        let item = CSSearchableItem(uniqueIdentifier: article[ArticleKeys.UUID], domainIdentifier: ArticlesDomainIdentifier, attributeSet: attributeSet)

        return item;
    }


}
