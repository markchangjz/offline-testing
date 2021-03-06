import UIKit

@objc(MKCTodoDetailViewController)
class TodoDetailViewController: UIViewController {
    
    @objc var todoTitle: String?

    lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.in_configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func in_configureView() {
        self.title = "Detail"
        self.view.backgroundColor = UIColor.white
        
        todoLabel.text = todoTitle
        todoLabel.sizeToFit()
        self.view.addSubview(todoLabel)
        todoLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        todoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        todoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}
