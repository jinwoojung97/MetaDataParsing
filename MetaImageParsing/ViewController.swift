//
//  ViewController.swift
//  MetaImageParsing
//
//  Created by inforex on 2022/11/14.
//

import UIKit

import RxSwift
import RxGesture
import SwiftSoup
import Alamofire
import SnapKit
import Then

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    var textField = UITextField().then{
        $0.backgroundColor = .gray
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .black
        $0.placeholder = "url 입력"
    }
    
    var parseButton = UIButton().then{
        $0.backgroundColor = .black
        $0.setTitle("parse", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.textAlignment = .center
    }
    
    var imageView = UIImageView().then{
        $0.backgroundColor = .gray
    }
    
    var titleLabel = UILabel().then{
        $0.text = "title"
        $0.numberOfLines = 2
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
    }
    
    var descriptionLabel = UILabel().then{
        $0.text = "description"
        $0.numberOfLines = 2
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    var hostLabel = UILabel().then{
        $0.text = "host"
        $0.textColor = .gray
        $0.font = UIFont.systemFont(ofSize: 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [textField, parseButton, imageView, titleLabel, descriptionLabel, hostLabel].forEach(view.addSubview)
        setConstraint()
        bind()
    }
    
    func bind(){
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
    
    func parse(url: String){
        AF.request(url).responseString {[weak self] (response) in
            guard let html = response.value else {
                return
            }
            var metaData = MetaData()
            metaData.setData(with: html)
            dump(metaData)
            self?.show(metaData)
            
        }
    }
    
    func show(_ data: MetaData){
        imageView.load(url: URL(string: data.image)!)
        titleLabel.text = data.title
        descriptionLabel.text = data.description
        hostLabel.text = data.host
    }
    
    
    func setConstraint(){
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
}

class MetaData{
    var image: String = "" /// 이미지
    var title: String = "" /// 제목
    var description : String = "" /// 부제
    var url: String = "" /// 전체 url
    var host: String = "" /// host ex) naver.com
    var appURL: String = "" /// ios app url
    var appStoreID: String = "" /// AppStore ID
    var appName: String = "" /// App Name

    func setData(with html: String){
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let elements: Element = doc.head()!
            self.image = (try elements.select(Tag.image.query).attr(Tag.content.query))
            self.title = (try elements.select(Tag.title.query).attr(Tag.content.query))
            self.description = (try elements.select(Tag.description.query).attr(Tag.content.query))
            self.url = (try elements.select(Tag.url.query).attr(Tag.content.query))
            self.host = URL(string: url)?.host ?? ""
            
            self.appURL = (try elements.select(Tag.appURL.query).attr(Tag.content.query))
            self.appStoreID = (try elements.select(Tag.appStoreID.query).attr(Tag.content.query))
            self.appName = (try elements.select(Tag.appName.query).attr(Tag.content.query))
        } catch {
            print("crawl error")
        }
    }
}





