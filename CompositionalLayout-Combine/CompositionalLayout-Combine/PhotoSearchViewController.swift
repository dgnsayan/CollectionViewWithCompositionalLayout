//
//  ViewController.swift
//  CompositionalLayout-Combine
//
//  Created by Doğan Sayan on 2.04.2022.
//

import UIKit
import Combine
import Kingfisher

enum SectionKind: Int, CaseIterable {
    case main
}

class PhotoSearchViewController: UIViewController {

    private var collectionView:UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind,Photo>
    private var dataSoruce:DataSource!
    
    private var searchController:UISearchController!
    
    @Published private var searchText = ""
    
    private var subscriptions:Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Photo Search"
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        
        $searchText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { text in
                self.searchPhotos(for: text)
            }
            .store(in: &subscriptions)
    }
    
    private func searchPhotos(for query: String) {
      APIClient().searchPhotos(for: query)
        .removeDuplicates()
        .sink(receiveCompletion: { (completion) in
          print(completion)
        }) { [weak self] (photos) in
            self?.updateSnapshot(with: photos)
        }
      .store(in: &subscriptions)
    }
    
    private func updateSnapshot(with photos:[Photo]){
        var snapshot = dataSoruce.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        dataSoruce.apply(snapshot,animatingDifferences: false)
    }
    
    private func configureSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 2)
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 3)
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1000))
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [leadingGroup, trailingGroup])
            
            let section = NSCollectionLayoutSection(group: nestedGroup)
            
            return section
        }
        return layout
    }
    
    private func configureDataSource(){
        dataSoruce = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, photo in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else { fatalError("error") }
            cell.backgroundColor = .systemTeal
            cell.imageView.kf.setImage(with: URL(string: photo.webformatURL))
            
            return cell
        })
        
        var snapshot = dataSoruce.snapshot()
        snapshot.appendSections([.main])
        dataSoruce.apply(snapshot,animatingDifferences: false)
    }

}

extension PhotoSearchViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        searchText = text
    }
    
    
}
