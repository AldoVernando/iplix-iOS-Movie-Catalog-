//
//  FavoriteViewController.swift
//  iplix
//
//  Created by TEMP on 4/16/20.
//  Copyright © 2020 aldovernando. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController {

    var collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let message: UILabel = {
        let label = UILabel()
        label.text = "You have no favorite movie"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    let realm = RealmManager()
    var movies: [FavoriteMovie] = []
    let network = ViewController.network
    var movieToSend: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 400)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(message)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            message.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            message.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        setUp()
    }
}


// MARK: UICollectionView
extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as? MovieCollectionViewCell else {
            fatalError("error")
        }
        
        let movie = movies[indexPath.row]
        
        cell.poster.sd_setImage(with: URL(string: network.posterURL + movie.poster_path))
        cell.title.text = movie.title
        cell.title.font = cell.title.font.withSize(30)
        cell.genre.text = movie.genre
        cell.genre.font = cell.genre.font.withSize(20)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gotoDetail(movie: movies[indexPath.row])
    }
    
    
}


extension FavoriteViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        setCollectionLooks()
    }
    
    
    // for custom snap-to paging, when user stop scrolling
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        var indexOfCellWithLargestWidth = 0
        var largestWidth : CGFloat = 1
        
        for cell in collectionView.visibleCells {
            if cell.frame.size.width > largestWidth {
                largestWidth = cell.frame.size.width
                if let indexPath = collectionView.indexPath(for: cell) {
                    indexOfCellWithLargestWidth = indexPath.item
                }
            }
        }
        
        collectionView.scrollToItem(at: IndexPath(item: indexOfCellWithLargestWidth, section: 0), at: .centeredHorizontally, animated: true)
    }
    
}


// MARK: Functions
extension FavoriteViewController {
    
    
    // set up view controller
    func setUp() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let padding =  ( collectionView.frame.size.width - 300 ) / 2.0
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        
        collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "movieCell")
        
        getFavorite()
        
    }
    
    
    // get favorite
    func getFavorite() {
        let favs = realm.realmInit.objects(FavoriteMovie.self)
        movies.removeAll()
        
        if favs.count > 0 {
            
            collectionView.isHidden = false
            message.isHidden = true
            
            for fav in favs {
                movies.append(fav)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                if favs.count > 1 {
                    self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
            
        } else {
            
            message.isHidden = false
            collectionView.isHidden = true
            
        }
        
        
        
    }
    
    
    // set collection view looks
    func setCollectionLooks() {
        let centerX = collectionView.center.x
        
            // only perform the scaling on cells that are visible on screen
        for cell in collectionView.visibleCells {
            // coordinate of the cell in the viewcontroller's root view coordinate space
            let basePosition = cell.convert(CGPoint.zero, to: self.view)
            let cellCenterX = basePosition.x + collectionView.frame.size.width / 2.0
            
            let distance = abs(cellCenterX - centerX)
            
            let tolerance : CGFloat = 0.02
            var scale = 1.00 + tolerance - (( distance / centerX ) * 0.105)
            if(scale > 1.0){
                scale = 1.0
            }
            
            if(scale < 0.860091){
                scale = 0.860091
            }
            
            // Transform the cell size based on the scale
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let movieCell = cell as! MovieCollectionViewCell
            movieCell.alpha = changeSizeScaleToAlphaScale(scale)

        }
    }
    
    
    // set size scale make alpha looks for cell
    func changeSizeScaleToAlphaScale(_ x : CGFloat) -> CGFloat {
        
        let minScale : CGFloat = 0.86
        let maxScale : CGFloat = 1.0
        
        let minAlpha : CGFloat = 0.25
        let maxAlpha : CGFloat = 1.0
        
        return ((maxAlpha - minAlpha) * (x - minScale)) / (maxScale - minScale) + minAlpha
    }
    
    
    // prepare before perform segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToDetail" {
            if let vc = segue.destination as? MovieDetailViewController {
                if let movieData = movieToSend {
                    vc.movie = movieData
                    vc.parentView = self
                }
            }
        }
    }
    
    
    // perform segue to movie detail
    func gotoDetail(movie: FavoriteMovie) {

        network.getMovieforFav(movieId: String(movie.id)) { response in
            
            self.movieToSend = response
            self.performSegue(withIdentifier:"goToDetail", sender: self)
        }
        
    }
    
}
