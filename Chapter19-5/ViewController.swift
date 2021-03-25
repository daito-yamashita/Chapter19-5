//
//  ViewController.swift
//  Chapter19-5
//
//  Created by daito yamashita on 2021/03/25.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // ラベル
    @IBOutlet weak var idoLabel: UILabel!
    @IBOutlet weak var keidoLabel: UILabel!
    @IBOutlet weak var hyoukouLabel: UILabel!
    @IBOutlet weak var henkakuLabel: UILabel!
    @IBOutlet weak var houiLabel: UILabel!
    
    // セグメンテッドコントロール
    @IBOutlet weak var jihokuSeg: UISegmentedControl!
    
    // 方位磁針
    @IBOutlet weak var compass: UIImageView!
    
    // ロケーションマネージャ
    var locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ラベルの初期化
        disabledLocationLabel()
        
        // アプリ利用中の位置情報の利用許可
        locationManager.requestWhenInUseAuthorization()
        
        // ロケーションマネージャーのdelegate
        locationManager.delegate = self
        
        // ロケーション機能の設定
        setupLocationService()
        
        // コンパス機能の開始
        startHeadingService()
    }

    // ロケーション機能の設定
    func setupLocationService() {
        // ロケーションの精度を設定する（ベスト）
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 更新距離
        locationManager.distanceFilter = 1
    }
    
    // ラベルにサービス利用不可を表示する
    func disabledLocationLabel() {
        idoLabel.adjustsFontSizeToFitWidth = true
        keidoLabel.adjustsFontSizeToFitWidth = true
        hyoukouLabel.adjustsFontSizeToFitWidth = true
        let msg = "位置情報の利用が許可されていない"
        idoLabel.text = msg
        keidoLabel.text = msg
        hyoukouLabel.text = msg
    }
    
    // コンパスの初期化とヘディングの更新
    func startHeadingService() {
        // セグメンテッドコントロールで磁北を選択する
        jihokuSeg.selectedSegmentIndex = 0
        
        // 自分が向いている方向をデバイスのポートレートの向きにする
        locationManager.headingOrientation = .portrait
        
        // ヘディングの更新角度（degree）
        locationManager.headingFilter = 1
        
        // ヘディングの更新を開始する
        locationManager.startUpdatingHeading()
    }
    
    // Delegateメソッド
    
    // 位置情報利用許可のステータスが変わった時に実行
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        // 利用を許可した
        case .authorizedAlways, .authorizedWhenInUse :
            locationManager.startUpdatingLocation()
        // 利用を不許可にした
        case .notDetermined:
            locationManager.stopUpdatingLocation()
            disabledLocationLabel()
        default:
            locationManager.stopUpdatingLocation()
            disabledLocationLabel()
        }
    }
    
    // 位置情報更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // locationsの最後の値を取り出す
        let locationData = locations.last
        
        // 緯度
        if var ido = locationData?.coordinate.latitude {
            // 下６桁で四捨五入
            ido = round(ido * 1000000) / 1000000
            keidoLabel.text = String(ido)
        }
        
        // 経度
        if var keido = locationData?.coordinate.longitude {
            // 下６桁で四捨五入
            keido = round(keido * 1000000) / 1000000
            keidoLabel.text = String(keido)
        }
        
        // 標高
        if var hyoukou = locationData?.altitude {
            // 下２桁で四捨五入
            hyoukou = round(hyoukou * 100) / 100
            hyoukouLabel.text = String(hyoukou) + " m"
        }
    }
    
    // 向いている方角が変わった
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // 真北
        let makita = newHeading.trueHeading
        // 磁北
        let jihoku = newHeading.magneticHeading
        // 偏角
        var henkaku = jihoku - makita
        if henkaku < 0 {
            henkaku += 360
        }
        // 下２桁で四捨五入
        henkaku = round(henkaku * 100) / 100
        henkakuLabel.text = String(henkaku)
        
        // 北の方角
        var kitamuki: CLLocationDirection!
        if jihokuSeg.selectedSegmentIndex == 0 {
            kitamuki = jihoku
        } else {
            kitamuki = makita
        }
        
        // 磁針で北を指す
        compass.transform = CGAffineTransform(rotationAngle: CGFloat(-kitamuki * Double.pi / 100))
        
        // デバイスが向いている方位角度
        let houikaku = round(kitamuki * 100) / 100
        houiLabel.text = String(houikaku)
    }

}

