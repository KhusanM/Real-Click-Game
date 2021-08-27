//
//  EntryVC.swift
//  Real_Click_Game
//
//  Created by Kh's MacBook on 25.08.2021.
//

import UIKit
import Firebase


class EntryVC: UIViewController {

    
    @IBOutlet weak var roomTF: UITextField!
    
    let db = Firestore.firestore()
    var rooms :[QueryDocumentSnapshot] = []
    
    var currentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        db.collection("rooms").getDocuments {snapshot, error in
            if let snap = snapshot{
                self.rooms = snap.documents
            }
        }
        
    }
    

    @IBAction func goBtnTapped(_ sender: Any) {
        
        if roomTF.text!.isEmpty{
            roomTF.layer.borderWidth = 1
            roomTF.layer.borderColor = UIColor.red.cgColor
        }else{
            
            roomTF.layer.borderWidth = 0
            let roomID = roomTF.text!.replacingOccurrences(of: " ", with: "").lowercased()
            
            db.collection("rooms").getDocuments {snapshot, error in
                
                let docIDes : [String] = snapshot!.documents.map { a in
                    return a.documentID
                }
                
                if docIDes.contains(roomID){
                    print("have")
                    
                    let vc = GameVC(nibName: "GameVC", bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    vc.currentRoomDocumentID = roomID
                    vc.currenPlayer = 2
                    self.present(vc, animated: true, completion: nil)
                }else{
                    print("no")
                    let myData : Room = Room.init(isRoomActive: true, maxCount: (30...50).randomElement()!, player_1_count: 0, player_2_count: 0, player_1_active: true, player_2_active: false, roomName: self.roomTF.text!)
                    
                    
                    self.db.collection("rooms").document(roomID).setData(myData.getDic())
                    
                    //listening
                    self.currentListener = self.db.collection("rooms").document(roomID).addSnapshotListener { snapshot, error in
                        
                        if let snap = snapshot{
                            let vc = GameVC(nibName: "GameVC", bundle: nil)
                            vc.modalPresentationStyle = .fullScreen
                            vc.currentRoomDocumentID = snap.documentID
                            vc.currenPlayer = 1
                            self.present(vc, animated: true) {
                                self.currentListener.remove()
                            }
                        }
                    }
                }
            }
        }
    }


}
