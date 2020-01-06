//
//  ViewController.swift
//  swift-rss-sample
//
//  Created by honda on 2020/01/06.
//  Copyright © 2020 honda. All rights reserved.
//

import UIKit
import FeedKit
import SafariServices

class ViewController: UITableViewController {
    var items: [RSSFeedItem]? = nil
    var image: UIImage? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        request()
    }
    
    func request() {
        guard let url = URL(string: "https://feeds.soundcloud.com/users/soundcloud:users:466377696/sounds.rss") else {
            return
        }
        let parser = FeedParser(URL: url)
        parser.parseAsync { (result) in
            switch result {
            case .success(let feed):
                self.items = feed.rssFeed?.items
                self.image = self.getImage(image: feed.rssFeed?.image)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Error : \(error.localizedDescription)")
            }
        }
    }
    
    func getImage(image: RSSFeedImage?) -> UIImage? {
        guard let url = URL(string: image?.url ?? "") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        }catch let error {
            print("Error : \(error.localizedDescription)")
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let item = items?[indexPath.row]
        cell?.textLabel?.text = item?.title
        cell?.textLabel?.numberOfLines = 0
        cell?.imageView?.image = image?.resize(size: CGSize(width: 35, height: 35))
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let link = items?[indexPath.row].link else {
            return
        }
        guard let url = URL(string: link) else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        self.present(safariViewController, animated: true, completion: nil)
    }
}

extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio

        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
}
