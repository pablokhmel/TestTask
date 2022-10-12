//
//  ImageVC.swift
//  TestTask
//
//  Created by MacBook on 11.10.2022.
//

import UIKit
import RxSwift
import RxCocoa

class ImageVC: UIViewController {
    let disposeBag = DisposeBag()
    let model: ImageModel
    let isLiked = BehaviorSubject(value: false)

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        let url = URL(string: model.urls?.full ?? "")
        view.sd_setImage(with: url)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = .gray
        view.clipsToBounds = true
        return view
    }()

    private lazy var likesLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.text = "Likes: " + String(model.likes ?? 0)
        view.font = .systemFont(ofSize: 16)
        return view
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemPink
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    init(model: ImageModel) {
        self.model = model

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray
        isLiked.onNext(RealmService.shared.isLiked(id: model.id))
        setupViews()
        bindRx()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let value = (try? isLiked.value()) ?? false
        if value && !RealmService.shared.isLiked(id: model.id) {
            RealmService.shared.addImage(model: model.copy() as! ImageModel)
        } else if !value && RealmService.shared.isLiked(id: model.id) {
            RealmService.shared.deleteImage(with: model.id)
        }
    }

    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(likesLabel)
        view.addSubview(likeButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(model.height) / CGFloat(model.width)),

            likesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            likesLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),

            likeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            likeButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func bindRx() {
        isLiked.bind(onNext: { value in
            let image = value ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            self.likeButton.setImage(image, for: .normal)
        }).disposed(by: disposeBag)

        likeButton.rx.tap.bind {
            let value = (try? self.isLiked.value()) ?? false
            self.isLiked.onNext(!value)
        }.disposed(by: disposeBag)
    }
}
