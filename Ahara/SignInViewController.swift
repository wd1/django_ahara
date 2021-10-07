import UIKit
import SwiftyJSON

class SignInViewController: UIViewController {

    
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var vwPassword: UIView!
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnShowPassword: UIButton!
    
    var bPasswordShow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwEmail.layer.cornerRadius = 25.0
        vwEmail.layer.borderWidth = 1
        vwEmail.layer.borderColor = UIColor(rgb: 0xEBEBEB).cgColor
            
        vwPassword.layer.cornerRadius = 25.0
        vwPassword.layer.borderWidth = 1
        vwPassword.layer.borderColor = UIColor(rgb: 0xEBEBEB).cgColor
        
        btnLogin.layer.cornerRadius = 25.0
        btnFacebook.layer.cornerRadius = 25.0
        btnTwitter.layer.cornerRadius = 25.0
        
        txtEmail.addDoneButtonOnKeyboard()
        txtPassword.addDoneButtonOnKeyboard()
        
        //txtEmail.text = "+18572852661"
        //txtPassword.text = "Admin@12345"
    }
    
    @IBAction func onShowPassword(_ sender: Any) {
        if (bPasswordShow == false)
        {
            self.txtPassword.isSecureTextEntry = false
            self.btnShowPassword.setImage(UIImage(named: "passShow"), for: .normal)
        }else{
            self.txtPassword.isSecureTextEntry = true
            self.btnShowPassword.setImage(UIImage(named: "passHide"), for: .normal)
        }
        bPasswordShow = !bPasswordShow
    }
    
    @IBAction func onLogin(_ sender: Any) {
        if txtEmail.text == ""
        {
            let inputAlert = UIAlertController(title: "Ahara", message: "Phone number is required!", preferredStyle: UIAlertController.Style.alert)
            inputAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))

            present(inputAlert, animated: true, completion: nil)
            return
        }
        if txtPassword.text == ""
        {
            let inputAlert = UIAlertController(title: "Ahara", message: "Password is required!", preferredStyle: UIAlertController.Style.alert)
            inputAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))

            present(inputAlert, animated: true, completion: nil)
            return
        }
        self.showSpinner()
        UserLogin(phone_number: txtEmail.text!, password: txtPassword.text!, completionHandler: { response in
            let statusCode = response.response?.statusCode
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if statusCode == 400 {
                        var err_msg:String = ""
                        if json["non_field_errors"].exists()
                        {
                            err_msg = json["non_field_errors"][0].stringValue
                        }
                        let paramAlert = UIAlertController(title: "Authentication Error", message: err_msg, preferredStyle: UIAlertController.Style.alert)
                        paramAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        }))
                        self.removeSpinner()
                        self.present(paramAlert, animated: true, completion: nil)
                    }
                    else {
                        var auth_token: String = ""
                        auth_token = json["auth_token"].string!
                        UserDefaults.standard.set(auth_token, forKey: "auth_token")
                        guard let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyBoxViewController") as? MyBoxViewController
                        else{
                            return
                        }
                        dst_vc.modalPresentationStyle = .fullScreen
                        self.present(dst_vc, animated: true, completion: nil)
                    }
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
    
    @IBAction func onForgotPassword(_ sender: Any) {
    }
    
    @IBAction func onTwitter(_ sender: Any) {
    }
    
    @IBAction func onFacebook(_ sender: Any) {
    }
}
