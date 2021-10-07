//
//  ReadyToCookViewController.swift
//  Ahara
//
//  Created by Miroslav Kostic on 5/19/21.
//

import UIKit
import SideMenu
import SwiftyJSON

class ReadyToCookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var btnNavigate: UIButton!
    @IBOutlet weak var vwTable: UITableView!
    
    var recipesArray:[JSON] = []
    
    var from: String = "menu"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwTable.dataSource = self
        vwTable.delegate = self
        
        self.getRecipes()
        if self.from == "menu" {
            self.btnNavigate.setImage(UIImage(named: "menuIcon"), for: .normal)
        } else {
            self.btnNavigate.setImage(UIImage(named: "icoBack"), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.getRecipes()
    }
    
    func getRecipes()
    {
        self.showSpinner()
        getApprovedRecipes(completionHandler: { response in
            switch response.result {
                case .success(let value):
                    self.removeSpinner()
                    let arr = JSON(value).arrayValue
                    print(arr)
                    for item in arr{
                        if item["is_this_week"].intValue == 1{
                            self.recipesArray.append(item)
                        }
                    }
                    self.vwTable.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recipesArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recp = self.recipesArray[indexPath.row]
        let chef = recp["chef"].dictionaryValue
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LetsCookViewController") as? LetsCookViewController
        else{
            return
        }
        dst_vc.b_index = 1
        dst_vc.recp = recp
        dst_vc.t_cook = String(recp["cooking_time"].stringValue) + " min"
        dst_vc.t_prep = String(recp["prep_time"].stringValue) + " min"
        dst_vc.serve = recp["serving"].stringValue
        dst_vc.desc = recp["description"].stringValue
        dst_vc.recpName = recp["name"].stringValue
        dst_vc.cheifName = "by " +   (chef["first_name"]?.stringValue)! + (chef["last_name"]?.stringValue)!
        let videos = recp["videos"].arrayValue
        let video = videos[0]
        dst_vc.videoURL = video["video"].stringValue
        
        dst_vc.modalPresentationStyle = .fullScreen
        self.present(dst_vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "readyToCookCell", for: indexPath) as! ReadyToCookCell
        cell.selectionStyle = .none
        let recipe = self.recipesArray[indexPath.row]
        let chef = recipe["chef"].dictionaryValue
        cell.lblChiefName.text = (chef["first_name"]?.stringValue)! + (chef["last_name"]?.stringValue)!
        //cell.lblViews.text = String(recipe["viewed"].intValue)
        cell.lblViews.text = String(recipe["likes"].arrayValue.count)
        cell.lblDuration.text = String(recipe["cooking_time"].intValue) + " min"
        cell.lblCookName.text = recipe["name"].stringValue
        cell.imgCook.sd_setImage(with: URL(string: recipe["image"].stringValue))
        cell.imgLiked.image = recipe["is_liked"].boolValue ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        return cell
    }
    @IBAction func onSideMenu(_ sender: Any) {
        if self.from == "menu" {
            guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RightMenuController") as? RightMenuController
            else{
                return
            }
            let menu = SideMenuNavigationController(rootViewController: dst_vc)
            menu.isNavigationBarHidden = true
            menu.menuWidth = 250
            menu.presentationStyle = .menuSlideIn
            dst_vc.isReadytoCook = true
            menu.leftSide = true
            present(menu, animated: true, completion: nil)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

