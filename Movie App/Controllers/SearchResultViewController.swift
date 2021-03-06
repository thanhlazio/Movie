//
//  SearchResultViewController.swift
//  Movie App
//
//  Created by Việt Trần on 11/1/16.
//  Copyright © 2016 IDE Academy. All rights reserved.
//

import UIKit

class SearchResultViewController: BaseViewController {
    
    static let identifier = "searchVC"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movieList:[Movie] = [Movie]()
    var typeOfMovie:TypeOfMovie = .topRated
    var searchText:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.addSubview(refeshing)
        //        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 65, right: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.itemSize.width = (screenWidth - 20)
                flowLayout.itemSize.height = (screenHeight - 5) / 2.5
            }
            isFirstLoad = false
        }
    }
    
    class func newVC() -> MovieListViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyBoard.instantiateViewController(withIdentifier: identifier) as! MovieListViewController
    }
    
    func dataForFirstPage() {
        page = 1
        isLoading = true
        self.pleaseWait()
        MovieDataStore.share.searchMovie(searchText: searchText,page: 1, response: { (movies) in
            if let movies = movies {
                self.movieList = movies
            }
            DispatchQueue.main.async(execute: { [weak self] in
                guard let `self` = self else {return}
                self.collectionView.reloadData()
                self.clearAllNotice()
            })
            self.isLoading = false
        })
    }
    
    func dataForNextPage() {
        Thread.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(loadNextPage), with: self, afterDelay: 0.2)
    }
    
    func loadNextPage() {
        page += 1
        isLoading = true
        self.pleaseWait()
        MovieDataStore.share.searchMovie(searchText: searchText,page: page, response: { (movies) in
            if let movies = movies {
                self.movieList = movies
            }else {
                self.page -= 1
            }
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let `self` = self else {return}
                self.collectionView.reloadData()
                self.clearAllNotice()
            })
        })
    }
    
}

extension SearchResultViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell
        
        let movie = movieList[indexPath.item]
        cell.setUpCell(movie: movie)
        
        return cell
    }
}

extension SearchResultViewController : UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refeshing.isRefreshing {
            dataForFirstPage()
            refeshing.endRefreshing()
        }
        
        let offSetY = scrollView.contentOffset.y
        let heightOfContent = scrollView.contentSize.height
        
        if !searchText.isEmpty && heightOfContent - offSetY - scrollView.bounds.size.height <= 1 {
            dataForNextPage()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let movie = movieList[indexPath.item]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "viewDetail" ), object: nil, userInfo: ["movieId": movie.id])
    }
}


extension SearchResultViewController : UISearchControllerDelegate {
    
}

extension SearchResultViewController : UISearchBarDelegate {
    
}

extension SearchResultViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let textSearch:String = searchController.searchBar.text, textSearch.characters.count >= 2 {
            searchText = textSearch
            Thread.cancelPreviousPerformRequests(withTarget: self)
            
            self.perform(#selector( searchMovie ), with: nil, afterDelay: TimeInterval(0.2))
        }else{
            searchText = ""
            self.movieList.removeAll()
            self.collectionView.reloadData()
        }
    }
    
    func searchMovie() {
        self.pleaseWait()
        MovieDataStore.share.searchMovie(searchText: searchText,page: 1, response: { (movies) in
            if let movies = movies {
                self.movieList = movies
            }
            
            DispatchQueue.main.async(execute: { [weak self] in
                guard let `self` = self else {return}
                self.collectionView.reloadData()
                self.clearAllNotice()
            })
        })
    }
}
