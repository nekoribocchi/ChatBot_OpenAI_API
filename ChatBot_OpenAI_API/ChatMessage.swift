
//チャットメッセージを表す構造体 (struct) を提供
import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()//一意のID
    let role: Role//userかassistantか
    let content: String//メッセージ本文
    
    enum Role {
        case user
        case assistant
    }
}

