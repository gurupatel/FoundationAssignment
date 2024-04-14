//
//  ViewController.swift
//  FoundationAssignment
//
//  Created by Gaurang Patel on 14/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
            
    private let reuseIdentifier = "ImageCell"
    private let apiURL = URL(string: "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=100")!
    private var mediaCoverages: [MediaCoverage] = []
    private let cache = ImageCache()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMediaCoverages()
    }
    
    private func fetchMediaCoverages() {
            URLSession.shared.dataTask(with: apiURL) { data, response, error in
                guard let data = data else {
                    debugPrint("Failed to fetch media coverages:", error ?? "")
                    return
                }
                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: data as Any)
//                    self.mediaCoverages = try JSONDecoder().decode([MediaCoverage].self, from: jsonData)

                    let json = try JSONDecoder().decode([MediaCoverage].self, from: data)
                    self.mediaCoverages = json
//                    debugPrint("mediaCoverages : ", self.mediaCoverages.count as Any)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } catch {
                    debugPrint("Error decoding media coverages:", error)
                }
            }.resume()
        }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        debugPrint("mediaCoverages : ", self.mediaCoverages.count as Any)
        return mediaCoverages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
        let mediaCoverage = mediaCoverages[indexPath.item]
        
//        debugPrint("coverageURL : ", mediaCoverage.coverageURL ?? "" as Any)
        
//        cell.imageView.image = cache.getImage(for: URL(string: mediaCoverage.coverageURL ?? "")!)
        
        // Attempt to load image from cache
        if let cachedImage = cache.getImage(for: URL(string: mediaCoverage.coverageURL ?? "")!) {
            cell.imageView.image = cachedImage
        } else {
            // Image not found in cache, set placeholder image
            cell.imageView.image = UIImage(named: "placeholder_image") 
        }
        
        // Asynchronously fetch image from URL
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: URL(string: mediaCoverage.coverageURL ?? "")!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        self.cache.setImage(image, for: URL(string: mediaCoverage.coverageURL ?? "")!)
                    }
                }
            }
        }

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 3 // 3 columns with 10 spacing
        return CGSize(width: width, height: width)
    }
}

class ImageCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let directoryURL: URL
    
    init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        directoryURL = paths[0].appendingPathComponent("ImageCache")
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating cache directory:", error.localizedDescription)
        }
    }
    
    func getImage(for url: URL) -> UIImage? {
        if let image = cache.object(forKey: url as NSURL) {
            return image
        }
        
        let fileURL = directoryURL.appendingPathComponent(url.lastPathComponent)
        if let image = UIImage(contentsOfFile: fileURL.path) {
            cache.setObject(image, forKey: url as NSURL)
            return image
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
        
        let fileURL = directoryURL.appendingPathComponent(url.lastPathComponent)
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
    }
}
