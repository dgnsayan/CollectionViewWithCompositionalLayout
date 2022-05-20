//
//  ViewController.swift
//  CompositionalLayout-Nested-Groups-Orthogonal-Scrolling
//
//  Created by Doğan Sayan on 1.04.2022.
//

import UIKit

enum SectionKind:Int,CaseIterable {
    case first
    case second
    case third
    
    var itemCount:Int{
        switch self {
        case .first:
            return 2
        default:
            return 1
        }
    }
    
    var nestedGroupHeight:NSCollectionLayoutDimension{
        switch self {
        case .first:
            return .fractionalWidth(0.9)
        default:
            return .fractionalWidth(0.45)
        }
    }
    
    var sectionTitle:String{
        switch self {
        case .first:
            return "First Section"
        case .second:
            return "Second Section"
        case .third:
            return "Third Section"
        }
    }
}

class ViewController: UIViewController {
    
    private var collectionView:UICollectionView!

    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind,Int>
    private var dataSource : DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        navigationItem.title = "Nested Groups"
    }
    
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createlayout())
        collectionView.backgroundColor = .systemCyan
        collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
    }

    private func createlayout() -> UICollectionViewLayout{
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            guard let sectionKind = SectionKind(rawValue: sectionIndex) else { fatalError("could not create a section") }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: sectionKind.itemCount)
            
            let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: sectionKind.nestedGroupHeight)
            let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])
            
            let section = NSCollectionLayoutSection(group: nestedGroup)
            section.orthogonalScrollingBehavior = .continuous
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            section.boundarySupplementaryItems = [header]
            return section
            
        }
        
        return layout
    }
    
    
    private func configureDataSource(){
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else { fatalError("error")}
            cell.textLabel.text = "\(item)"
            cell.backgroundColor = .systemGray5
            cell.layer.cornerRadius = 15
            return cell
        })
        
        dataSource.supplementaryViewProvider = {(collectionView,kind,indexPath) in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView, let sectionKind = SectionKind(rawValue: indexPath.section) else { fatalError("error") }
            headerView.textLabel.text = sectionKind.sectionTitle
            headerView.textLabel.textAlignment = .left
            headerView.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            return headerView
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind,Int>()
        snapshot.appendSections([.first, .second, .third])
        snapshot.appendItems(Array(1...20), toSection: .first)
        snapshot.appendItems(Array(21...30), toSection: .second)
        snapshot.appendItems(Array(31...40), toSection: .third)
        dataSource.apply(snapshot,animatingDifferences: false)
    }
    

}

