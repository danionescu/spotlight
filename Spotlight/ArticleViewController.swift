//
//  ViewController.swift
//  Spotlight
//
//  Created by Dan Ionescu on 12/04/16.
//  Copyright © 2016 Alt Tab. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    var article: [String: String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        populateViewsWithArticle(article)
    }

    func populateViewsWithArticle(article: [String: String]!) {
        title = article[ArticleKeys.Title]
        
        if let image = UIImage(named: article[ArticleKeys.ImageName]!) {
            imageView.image = image
            imageView.hidden = false
        } else {
            imageView.hidden = true
        }

        textView.text = article[ArticleKeys.Content]
    }


}

