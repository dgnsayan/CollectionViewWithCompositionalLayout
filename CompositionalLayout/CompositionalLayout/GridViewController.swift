//
//  ViewController.swift
//  CompositionalLayout
//
//  Created by Doğan Sayan on 31.03.2022.
//

import UIKit

class GridViewController: UIViewController {
    
    enum Section {
        case main
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource : UICollectionViewDiffableDataSource<Section, Int>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureDataSource()
    }
    
    private func createLayout() -> UICollectionViewLayout{
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    private func configureCollectionView(){
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .systemCyan
    }

    private func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section,Int>(collectionView: collectionView, cellProvider: {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else { fatalError("could not dequeue a label cell")}
            cell.textLabel.text = "\(item) - \(indexPath) - \(collectionView)"
            cell.backgroundColor = .systemMint
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section,Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(1...100))
        dataSource.apply(snapshot,animatingDifferences: false)

    }
}

