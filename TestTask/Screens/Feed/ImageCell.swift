//
//  ImageCell.swift
//  TestTask
//
//  Created by MacBook on 11.10.2022.
//

import UIKit
import RxSwift
import SDWebImage

class ImageCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    var model = PublishSubject<ImageModel>()
    static let identifier = "ImageCell"

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 15
        view.frame = bounds
        view.backgroundColor = .gray
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        addSubview(imageView)

        model.subscribe(onNext: { value in
            guard let url = URL(string: value.urls?.raw ?? "") else { return }
            self.imageView.sd_setImage(with: url)
        }).disposed(by: disposeBag)
    }

    public func getImage() -> UIImage {
        return imageView.image ?? UIImage()
    }
}
