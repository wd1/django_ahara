import UIKit

class TutorialScreenViewController3: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .left
        self.view.addGestureRecognizer(swipeRight)
    }
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            performSegue(withIdentifier: "Tutor3toL", sender: nil)
        }
    }
}
