//
//  ViewController.swift
//  MetaImageParsing
//
//  Created by inforex on 2022/11/14.
//

import UIKit

import RxSwift
import RxGesture
import Alamofire
import SnapKit
import Then

final class ViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    // MARK: -Components
    private var textField = UITextField().then{
        $0.backgroundColor = .gray
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .black
        $0.placeholder = "url 입력"
    }
    
    private var parseButton = UIButton().then{
        $0.backgroundColor = .black
        $0.setTitle("parse", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.textAlignment = .center
    }
    
    private var imageView = UIImageView().then{
        $0.backgroundColor = .gray
    }
    
    private var titleLabel = UILabel().then{
        $0.text = "title"
        $0.numberOfLines = 2
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
    }
    
    private var descriptionLabel = UILabel().then{
        $0.text = "description"
        $0.numberOfLines = 2
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    private var hostLabel = UILabel().then{
        $0.text = "host"
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 10)
    }
    
    // MARK: -UI
    override func viewDidLoad() {
        super.viewDidLoad()
        addComponent()
        setConstraint()
        bind()
    }
    
    private func addComponent(){
        [textField, parseButton, imageView, titleLabel, descriptionLabel, hostLabel].forEach(view.addSubview)
    }
    
    private func setConstraint(){
        textField.snp.makeConstraints{
            $0.height.equalTo(30)
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(imageView.snp.top).inset(-30)
        }
        
        parseButton.snp.makeConstraints{
            $0.height.equalTo(30)
            $0.width.equalTo(50)
            $0.trailing.equalTo(textField).offset(10)
            $0.centerY.equalTo(textField)
        }
        
        imageView.snp.makeConstraints{
            $0.size.equalTo(150)
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints{
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        hostLabel.snp.makeConstraints{
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(10)
        }
    }
    
    private func bind(){
        parseButton.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.parse(url: self?.textField.text ?? "")
            }.disposed(by: disposeBag)
        
        view.rx.tapGesture()
            .when(.recognized)
            .filter{[weak self] _ in (self?.textField.isFirstResponder)! }
            .bind{[weak self] _ in self?.textField.resignFirstResponder() }
            .disposed(by: disposeBag)
    }
    
    //MARK: -Feature
    private func parse(url: String){
        AF.request(url).responseString {[weak self] (response) in
            guard let html = response.value else { return }
            var metaData = MetaData()
            metaData.setData(with: html)
            dump(metaData)
            self?.show(metaData)
        }
    }
    
    private func show(_ data: MetaData){
        imageView.load(url: URL(string: data.image)!)
        titleLabel.text = data.title
        descriptionLabel.text = data.description
        hostLabel.text = data.host
    }
}
