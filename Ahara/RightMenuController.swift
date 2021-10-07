//
//  RightMenuController.swift
//  Ahara
//
//  Created by Miroslav Kostic on 5/24/21.
//

import UIKit
import SwiftyJSON

class RightMenuController: UIViewController {

    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnReadytoCook: UIButton!
    @IBOutlet weak var btnMyBox: UIButton!
    @IBOutlet weak var btnIngredient: UIButton!
    @IBOutlet weak var imgProfile: imgProfileView!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    var isMybox: Bool = false
    var isReadytoCook: Bool = false
    var isSearch: Bool = false
    var isIngredient: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwContainer.layer.cornerRadius = 12.0
        self.view.bringSubviewToFront(imgProfile)
        
        if isMybox == true{
            btnMyBox.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 24)
        }else{
            btnMyBox.titleLabel?.font = UIFont(name: "Roboto-Thin", size: 24)
        }
        
        if isReadytoCook == true{
            btnReadytoCook.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 24)
        }else{
            btnReadytoCook.titleLabel?.font = UIFont(name: "Roboto-Thin", size: 24)
        }
        
        if isSearch == true{
            btnSearch.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 24)
        }else{
            btnSearch.titleLabel?.font = UIFont(name: "Roboto-Thin", size: 24)
        }
        
        if isIngredient == true{
            btnIngredient.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 24)
        }else{
            btnIngredient.titleLabel?.font = UIFont(name: "Roboto-Thin", size: 24)
        }
        
        //self.readMe()
        self.lblUserName.text = user["first_name"].stringValue + " " + user["last_name"].stringValue
        if user["avatar_image"].stringValue != "" {
            self.imgProfile.sd_setImage(with: URL(string: user["avatar_image"].stringValue))
        }
        
    }
    /*
    func readMe(){
        self.showSpinner()
        UserReadMe(completionHandler: { response in
            switch response.result {
                case .success(let value):
                    //print(value)
                    user = JSON(value)
                    print(user)
                    self.lblUserName.text = user["first_name"].stringValue + " " + user["last_name"].stringValue
                    if user["avatar_image"].stringValue != "" {
                        self.imgProfile.sd_setImage(with: URL(string: user["avatar_image"].stringValue))
                    }
                    self.removeSpinner()
                    //self.getUnboxing()
                    return
                case .failure(let error):
                    self.removeSpinner()
                    let paramAlert = UIAlertController(title: "Internet Error", message: "Please check internet connection.", preferredStyle: UIAlertController.Style.alert)
                    paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    }))
                    print(error)
                    self.present(paramAlert, animated: true, completion: nil)
                    return
            }
        })
    }
    */
    @IBAction func onMyBox(_ sender: Any) {
        //let name:String = String.init(describing: UIApplication.getTopViewController()?.classForCoder)
        if isMybox == false {
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyBoxViewController") as? MyBoxViewController
            else{
                return
            }
            dst_vc.modalPresentationStyle = .fullScreen
            self.present(dst_vc, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onReadytoCook(_ sender: Any) {
        if isReadytoCook == false{
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReadyToCookViewController") as? ReadyToCookViewController
            else{
                return
            }
            dst_vc.from = "menu"
            dst_vc.modalPresentationStyle = .fullScreen
            self.present(dst_vc, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func onFindRecipes(_ sender: Any) {
        if isSearch == false{
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FindReceipeViewController") as? FindReceipeViewController
            else{
                return
            }
            dst_vc.modalPresentationStyle = .fullScreen
            self.present(dst_vc, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onIngredient(_ sender: Any) {
        /*
        if isIngredient == false{
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IngredientViewController") as? IngredientViewController
            else{
                return
            }
            dst_vc.modalPresentationStyle = .fullScreen
            self.present(dst_vc, animated: true, completion: nil)
        }
        */
    }
    
    @IBAction func onRecommend(_ sender: Any) {
        
    }
    @IBAction func onProfile(_ sender: Any) {
        
    }
    @IBAction func onSetting(_ sender: Any) {
        
    }
    @IBAction func onPrivacy(_ sender: Any) {
        
    }
    @IBAction func onLogOut(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "auth_token")
        user = JSON()
        UserLogout(completionHandler: { response in
            print(response)
            return
        })
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        else{
            return
        }
        dst_vc.modalPresentationStyle = .fullScreen
        self.present(dst_vc, animated: true, completion: nil)
    }
}

