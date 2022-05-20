//
//  ViewController.swift
//  CompositionalLayoutMultipleSections
//
//  Created by Doğan Sayan on 1.04.2022.
//

import UIKit

class ViewController: UIViewController {
    
    enum Section : Int,CaseIterable{
        case grid
        case single
        var coloumnCount : Int{
            switch self {
            case .grid:
                return 4
            case .single:
                return 1
            }
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias DataSoruce = UICollectionViewDiffableDataSource<Section,Int>
    
    private var dataSource:DataSoruce!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureCollectionView()
        configureDataSource()
    }

    private func createLayout() -> UICollectionViewLayout{
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnviroment in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil}
            let coloums = sectionType.coloumnCount
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupHeight = coloums == 1 ? NSCollectionLayoutDimension.absolute(200) : NSCollectionLayoutDimension.fractionalWidth(0.25)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: coloums)
            
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]

            return section
        }
        return layout
    }
    
    private func configureCollectionView(){
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .systemTeal
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
        
    }
    
    private func configureDataSource(){
        dataSource = DataSoruce(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else { fatalError("could not dequeue") }
            cell.textLabel.text = "\(item)"
            if indexPath.section == 0{
                cell.backgroundColor = .systemRed
            }else{
                cell.backgroundColor = .systemBlue
            }
            return cell
        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else { fatalError("could not dequeue") }
            headerView.textLabel.text = "\(Section.allCases[indexPath.section])".capitalized
            headerView.backgroundColor = .darkGray
            headerView.layer.cornerRadius = 15
            return headerView
            
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section,Int>()
        snapshot.appendSections([.grid,.single])
        snapshot.appendItems(Array(1...12), toSection: .grid)
        snapshot.appendItems(Array(13...20), toSection: .single)
        dataSource.apply(snapshot,animatingDifferences: false)
        
    }

}

