//
//  ViewController.swift
//  ToDoNotepad
//
//  Created by user217360 on 6/17/22.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var dataSource : [(String, String)] = []
    private let dataBase = Database.database().reference()
    private var dataBasePath = "ToDoNotePad"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddBtn))
        fetchTodo()
    }
    
    @objc func didTapAddBtn(){
        let alert = UIAlertController(title: "Add item to do", message: " ", preferredStyle: .alert)
        alert.addTextField{field in field.placeholder = "Enter to do item"}
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               !text.isEmpty{
                self?.saveToDo(item: text)
            }
        }))
    }
    
    func removeFromDataBase(itemKey: String) {
        dataBase.child("\(dataBasePath)/\(itemKey)").removeValue()
    }
    
    func saveToDo(item: String) {
        dataBase.child(dataBasePath).childByAutoId().setValue(item)
    }
    
    func fetchTodo(){
        dataBase.child(dataBasePath).observe(.value) { [weak self] snapShot in
            guard let items = snapShot.value as? [String: String] else {
                return
            }
            self?.dataSource.removeAll()
            let sortedItems = items.sorted { $0.0 < $1.0}
            for (key, item) in sortedItems{
                self?.dataSource.append((key, item))
            }
            self?.tableView.reloadData()
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        tableCell.textLabel?.text = dataSource[indexPath.row].1
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteAlert = UIAlertController(title: "Delete ToDo Item?", message: nil, preferredStyle: .alert)
            present(deleteAlert, animated: true)
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                self?.removeFromDataBase(itemKey: (self?.dataSource[indexPath.row].0)!)
                self?.dataSource.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
        }
    }
}
