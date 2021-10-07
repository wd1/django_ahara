
import Foundation
import UIKit

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

    convenience init(rgb: Int) {
       self.init(
        red: ((rgb >> 16) & 0xFF),
        green: ((rgb >> 8) & 0xFF),
        blue: (rgb & 0xFF)
       )
   }
    
    convenience init(hex: UInt32, alpha: CGFloat) {
    let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
    let green = CGFloat((hex & 0xFF00) >> 8)/256.0
    let blue = CGFloat(hex & 0xFF)/256.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UITextField{
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}

fileprivate var aView : UIView?
extension UIViewController {
    func showSpinner()
    {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = UIColor.white
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
    }
    func removeSpinner()
    {
        aView?.removeFromSuperview()
        aView = nil
    }
}

class SegueFromLeft: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination

        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)

        UIView.animate(withDuration: 0.5,
                              delay: 0.0,
                            options: .curveEaseInOut,
                         animations: {
                                dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                                },
                        completion: { finished in
                                src.present(dst, animated: false, completion: nil)
                                    }
                        )
    }
}

class blurView: UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.layer.frame.width / 2
    }
}

class socialBtn: UIButton {
    override func awakeFromNib() {
        self.layer.cornerRadius = 25.0
    }
}

class imgProfileView: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.layer.frame.width / 2
    }
}

class radiusView: UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 12
    }
}

extension UIView{
    func rotate(angle: CGFloat){
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
