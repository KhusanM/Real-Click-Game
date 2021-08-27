//
//  GameVC.swift
//  Real_Click_Game
//
//  Created by Kh's MacBook on 25.08.2021.
//

import UIKit
import Firebase


struct Room {
    var isRoomActive: Bool
    var maxCount: Int
    var player_1_count: Int
    var player_2_count: Int
    var player_1_active: Bool
    var player_2_active: Bool
    var roomName: String
    
    
    func getDic() -> [String:Any]{
        let dic :[String:Any] =  [
            "isRoomActive": self.isRoomActive,
            "maxCount": maxCount,
            "player_1_count": player_1_count,
            "player_2_count": player_2_count,
            "roomName" : roomName,
            "player_1_active": player_1_active,
            "player_2_active": player_2_active
        ]
        
        return dic
    }
    
    init(data : [String:Any]) {
        self.isRoomActive = data["isRoomActive"] as! Bool
        self.maxCount = data["maxCount"] as! Int
        self.player_1_count = data["player_1_count"] as! Int
        self.player_2_count = data["player_2_count"] as! Int
        self.player_1_active = data["player_1_active"] as! Bool
        self.player_2_active = data["player_2_active"] as! Bool
        self.roomName = data["roomName"] as! String
    }
    
    init(isRoomActive: Bool, maxCount: Int, player_1_count: Int, player_2_count: Int, player_1_active: Bool, player_2_active: Bool, roomName: String) {
        self.isRoomActive = isRoomActive
        self.maxCount = maxCount
        self.player_1_count = player_1_count
        self.player_2_count = player_2_count
        self.player_1_active = player_1_active
        self.player_2_active = player_2_active
        self.roomName = roomName
    }
    
}
class GameVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var playerName1: UILabel!
    @IBOutlet weak var playerName2: UILabel!
    
    @IBOutlet weak var playerQuestion1: UILabel!
    @IBOutlet weak var playerQuestion2: UILabel!
    @IBOutlet weak var playerCount1: UILabel!
    @IBOutlet weak var playerCount2: UILabel!
    
    @IBOutlet weak var containerViewPlaye1: UIView!
    @IBOutlet weak var containerViewPlaye2: UIView!
    
    
    @IBOutlet weak var player1Btn: UIButton!
    @IBOutlet weak var player2Btn: UIButton!
    
    @IBOutlet weak var restartBtn: UIButton!{
        didSet{
            restartBtn.isHidden = true
        }
    }
    
    var db = Firestore.firestore()
    
    var currentRoomDocumentID: String!
    
    var currentMaxCount: Int! = 0{
        didSet{
            self.playerQuestion1.text = "\(currentMaxCount ?? 30)"
            self.playerQuestion2.text = "\(currentMaxCount ?? 30)"
        }
    }
    var currenPlayer: Int = 1
    var currentRoom : Room!
    var currentListener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.db.collection("rooms").document(self.currentRoomDocumentID).updateData(["player_\(currenPlayer)_active": true])
        
        currentListener = db.collection("rooms").document(currentRoomDocumentID).addSnapshotListener({ snapshot, error in
            if let data = snapshot?.data(){
                let room = Room.init(data: data)
                self.currentMaxCount = room.maxCount
                self.update(room: room)
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !currentRoom.player_1_active && !currentRoom.player_2_active{
            self.db.collection("rooms").document(self.currentRoomDocumentID).delete()
        }
        
        self.currentListener.remove()
    }
    
    private func update(room: Room){
        
        currentRoom = room
        self.titleLbl.text = room.roomName
        //Player 1
        containerViewPlaye1.layer.borderWidth = 2
        containerViewPlaye1.layer.borderColor = room.player_1_active ? UIColor.systemBlue.cgColor : UIColor.white.cgColor
        playerCount1.text = "\(room.player_1_count)"
        
        
        //Player 2
        containerViewPlaye2.layer.borderWidth = 2
        containerViewPlaye2.layer.borderColor = room.player_2_active ? UIColor.systemOrange.cgColor : UIColor.white.cgColor
        playerCount2.text = "\(room.player_2_count)"
        
        
        
        if room.player_1_active && room.player_2_active{
            if currenPlayer == 1{
                player1Btn.isHidden = false
                player2Btn.isHidden = true
            }else{
                player1Btn.isHidden = true
                player2Btn.isHidden = false
            }
        }else{
            player1Btn.isHidden = true
            player2Btn.isHidden = true
        }
        
        if (room.player_1_count == room.maxCount) || (room.player_2_count == room.maxCount){
            
            player1Btn.isHidden = true
            player2Btn.isHidden = true
            
            if room.player_1_count == room.maxCount{
                playerQuestion1.text = "WIN!!!"
            }else{
                playerQuestion2.text = "WIN!!!"
            }
            
            restartBtn.isHidden = false
        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.db.collection("rooms").document(self.currentRoomDocumentID).updateData(["player_\(currenPlayer)_active": false])
        
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func player1PlusBtnTapped(_ sender: Any) {
        self.db.collection("rooms").document(self.currentRoomDocumentID).updateData(["player_1_count": self.currentRoom.player_1_count + 1])
    }
    
    @IBAction func player2PlusBtnTapped(_ sender: Any) {
        self.db.collection("rooms").document(self.currentRoomDocumentID).updateData(["player_2_count": self.currentRoom.player_2_count + 1])
        
    }
    
    @IBAction func restartBtnTapped(_ sender: Any) {
        playerQuestion2.text = "\(currentRoom.maxCount)"
        playerQuestion1.text = "\(currentRoom.maxCount)"
        playerCount1.text = "\(0)"
        playerCount2.text = "\(0)"
        self.db.collection("rooms").document(self.currentRoomDocumentID).updateData(["player_1_count": 0])
        self.db.collection("rooms").document(self.currentRoomDocumentID).updateData(["player_2_count": 0])
        
        
        if currenPlayer == 1{
            player1Btn.isHidden = false
            player2Btn.isHidden = true
        }else{
            player1Btn.isHidden = true
            player2Btn.isHidden = false
        }
        
        restartBtn.isHidden = true
        
    }
}
