import UIKit
import SideMenu
import SwiftyJSON

class FindReceipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var vwSearch: UIView!
    @IBOutlet weak var btnCat1: UIButton!
    @IBOutlet weak var btnCat2: UIButton!
    @IBOutlet weak var btnCat3: UIButton!
    @IBOutlet weak var btnCat4: UIButton!
    @IBOutlet weak var btnCat5: UIButton!
    @IBOutlet weak var vwTable: UITableView!
    @IBOutlet weak var btnLikeFilter: UIButton!
    
    var recipesArray:[JSON] = []
    var filteredArray:[JSON] = []
    
    var strCat1: String = ""
    var strCat2: String = ""
    var strCat3: String = ""
    var strCat4: String = ""
    var strCat5: String = ""
    var searchStr: String = ""
    
    var isLike: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwTable.dataSource = self
        vwTable.delegate = self
        
        vwSearch.layer.cornerRadius = 20.0
        txtSearch.addTarget(self, action: #selector(self.txtChanged(_:)), for: .editingChanged)
        txtSearch.addDoneButtonOnKeyboard()
        self.getRecipes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc func txtChanged(_ textField: UITextField)
    {
        searchStr = self.txtSearch.text!
        filterRecipes()
    }
    
    @IBAction func onLike(_ sender: Any) {
        self.isLike = !self.isLike
        btnLikeFilter.setImage(UIImage(systemName: isLike ? "star.fill" : "star"), for: .normal)
        filterRecipes()
    }
    
    func filterRecipes()
    {
        filteredArray = self.recipesArray
        var emptyArray:[JSON] = []
        if searchStr != ""
        {
            if searchStr.lowercased() == "past recipe"
            {
                filteredArray = recipesArray.filter {$0["is_this_week"].boolValue == false}
            } else if searchStr.lowercased() == "this week"
            {
                filteredArray = recipesArray.filter {$0["is_this_week"].boolValue == true}
            } else
            {
                for recipe in self.recipesArray{
                    if recipe["name"].stringValue.lowercased().contains(searchStr.lowercased()){
                        emptyArray.append(recipe)
                    }else{
                        let ingredients:[JSON] = recipe["recipe_ingredients"].arrayValue
                        var count:Int = 0
                        for ingredient in ingredients{
                            if ingredient["ingredient"].stringValue.lowercased().contains(searchStr.lowercased()){
                                count += 1
                            }
                        }
                        if count > 0{
                            emptyArray.append(recipe)
                        }
                    }
                }
                filteredArray = emptyArray
            }
        } else{
            filteredArray = self.recipesArray
        }
        
        if strCat1 != "" || strCat2 != "" || strCat3 != "" || strCat4 != "" || strCat5 != ""{
            filteredArray = filteredArray.filter{$0["category"].stringValue == strCat1 || $0["category"].stringValue == strCat2 || $0["category"].stringValue == strCat3 || $0["category"].stringValue == strCat4 || $0["category"].stringValue == strCat5}
        }
        if self.isLike == true {
            filteredArray = filteredArray.filter{$0["is_liked"].boolValue == self.isLike}
        }
        
        vwTable.reloadData()
    }
    
    func getRecipes()
    {
        self.showSpinner()
        getApprovedRecipes(completionHandler: { response in
            switch response.result {
                case .success(let value):
                    self.removeSpinner()
                    let arr = JSON(value).arrayValue
                    for item in arr{
                        //if item["is_this_week"].intValue == 1{
                            self.recipesArray.append(item)
                        //}
                    }
                    print(self.recipesArray)
                    print(self.recipesArray.count)
                    self.filteredArray = self.recipesArray
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
        return self.filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recp = self.recipesArray[indexPath.row]
        let chef = recp["chef"].dictionaryValue
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LetsCookViewController") as? LetsCookViewController
        else{
            return
        }
        dst_vc.b_index = 2
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
        return 210
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receipeTableCell", for: indexPath) as! ReceipeTableCell
        cell.selectionStyle = .none
        
        let recipe = self.filteredArray[indexPath.row]
        let chef = recipe["chef"].dictionaryValue
        cell.lblCheifName.text = (chef["first_name"]?.stringValue)! + (chef["last_name"]?.stringValue)!
        //cell.lblMarkCount.text = String(recipe["viewed"].intValue)
        cell.lblMarkCount.text = String(recipe["likes"].arrayValue.count)
        cell.lblTime.text = String(recipe["cooking_time"].intValue) + " min"
        cell.lblRecipeName.text = recipe["name"].stringValue
        cell.imgReceipe.sd_setImage(with: URL(string: recipe["image"].stringValue))
        cell.imgLiked.image = recipe["is_liked"].boolValue ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        return cell
    }
    
    @IBAction func onSideMenu(_ sender: Any) {
        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RightMenuController") as? RightMenuController
        else{
            return
        }
        let menu = SideMenuNavigationController(rootViewController: dst_vc)
        menu.isNavigationBarHidden = true
        menu.menuWidth = 250
        menu.presentationStyle = .menuSlideIn
        dst_vc.isSearch = true
        menu.leftSide = true
        present(menu, animated: true, completion: nil)
    }
    
    @IBAction func onCat1(_ sender: Any) {
        if strCat1 == "Beverage"{
            btnCat1.layer.borderWidth = 0
            strCat1 = ""
        }else{
            btnCat1.layer.borderWidth = 2
            btnCat1.layer.cornerRadius = 7
            btnCat1.layer.borderColor = UIColor.init(rgb: 0x979797).cgColor
            strCat1 = "Beverage"
        }
        self.filterRecipes()
    }
    @IBAction func onCat2(_ sender: Any) {
        if strCat2 == "Main Dish"{
            btnCat2.layer.borderWidth = 0
            strCat2 = ""
        }else{
            btnCat2.layer.borderWidth = 2
            btnCat2.layer.cornerRadius = 7
            btnCat2.layer.borderColor = UIColor.init(rgb: 0x979797).cgColor
            strCat2 = "Main Dish"
        }
        self.filterRecipes()
    }
    @IBAction func onCat3(_ sender: Any) {
        if strCat3 == "Salad"{
            btnCat3.layer.borderWidth = 0
            strCat3 = ""
        }else{
            btnCat3.layer.borderWidth = 2
            btnCat3.layer.cornerRadius = 7
            btnCat3.layer.borderColor = UIColor.init(rgb: 0x979797).cgColor
            strCat3 = "Salad"
        }
        self.filterRecipes()
    }
    @IBAction func onCat4(_ sender: Any) {
        if strCat4 == "Side Dish"{
            btnCat4.layer.borderWidth = 0
            strCat4 = ""
        }else{
            btnCat4.layer.borderWidth = 2
            btnCat4.layer.cornerRadius = 7
            btnCat4.layer.borderColor = UIColor.init(rgb: 0x979797).cgColor
            strCat4 = "Side Dish"
        }
        self.filterRecipes()
    }
    @IBAction func onCat5(_ sender: Any) {
        if strCat5 == "Soup"{
            btnCat5.layer.borderWidth = 0
            strCat5 = ""
        }else{
            btnCat5.layer.borderWidth = 2
            btnCat5.layer.cornerRadius = 7
            btnCat5.layer.borderColor = UIColor.init(rgb: 0x979797).cgColor
            strCat5 = "Soup"
        }
        self.filterRecipes()
    }
}
