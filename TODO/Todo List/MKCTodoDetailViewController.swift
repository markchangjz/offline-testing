import UIKit

class MKCTodoDetailViewController: UIViewController {
    
    var todoTitle: String?

    private lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Detail"
        self.view.backgroundColor = UIColor.white
        
        self.in_configureTodoLabelView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func in_configureTodoLabelView() {
        todoLabel.text = todoTitle
        todoLabel.sizeToFit()
        
        self.view.addSubview(todoLabel)
        todoLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        todoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        todoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}
