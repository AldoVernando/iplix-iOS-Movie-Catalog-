//
//  MovieAboutViewController.swift
//  iplix
//
//  Created by TEMP on 4/7/20.
//  Copyright © 2020 aldovernando. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView

class MovieAboutViewController: UIViewController {
    
    let customView = MovieAboutView()
    var scroller: UIScrollView!
    var content: UIView!
    var aboutLabel: UILabel!
    var overview: UILabel!
    var trailerView: WKYTPlayerView!
    
    var movie: Movie?
    let network = ViewController.network
    
//    override func loadView() {
//        view = customView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        scroller = customView.scroller
        content = customView.content
        aboutLabel = customView.aboutLabel
        overview = customView.overview
        trailerView = customView.trailerView
        
        content.addSubview(aboutLabel)
        content.addSubview(trailerView)
        content.addSubview(overview)
        
        scroller.addSubview(content)
        
        view.addSubview(scroller)
        
        NSLayoutConstraint.activate([

            // scroll view constraints
            scroller.topAnchor.constraint(equalTo: view.topAnchor),
            scroller.leftAnchor.constraint(equalTo: view.leftAnchor),
            scroller.rightAnchor.constraint(equalTo: view.rightAnchor),
            scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // content view constraints
            content.topAnchor.constraint(equalTo: scroller.topAnchor),
            content.leftAnchor.constraint(equalTo: scroller.leftAnchor),
            content.rightAnchor.constraint(equalTo: scroller.rightAnchor),
            content.bottomAnchor.constraint(equalTo: scroller.bottomAnchor),
            content.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            
            // about label constraints
            aboutLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
            aboutLabel.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 16),
            aboutLabel.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -16),

            // trailer view constraints
            trailerView.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 20),
            trailerView.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 16),
            trailerView.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -16),
            trailerView.heightAnchor.constraint(equalToConstant: 200),
            
            // overview constraints
            overview.topAnchor.constraint(equalTo: trailerView.bottomAnchor, constant: 20),
            overview.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 16),
            overview.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -16),
            overview.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -20)
            
        ])
        
        if let mov = movie {
            overview.text = mov.overview
            overview.text! += mov.overview!
            overview.text! += mov.overview!
            showTrailer(id: mov.id!)
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scroller.contentSize = CGSize(width: UIScreen.main.bounds.width, height: content.frame.height + 350)
    }

}


// MARK: Functions
extension MovieAboutViewController {
 
    
    // show movie trailer
    func showTrailer(id: Int) {
        
        network.getVideoURL(id: id) { response in
            
            if response.count > 1 {
                self.trailerView.load(withVideoId: response[1].key!)
            }
            else {
                self.trailerView.removeFromSuperview()
                self.overview.topAnchor.constraint(equalTo: self.aboutLabel.bottomAnchor, constant: 16).isActive = true
            }
        }
    }
}
