import Foundation
import OpenAI
import SwiftUI

class ChatViewModel: ObservableObject {
    // チャットメッセージのリスト
    @Published var messages: [ChatMessage] = [ChatMessage(role: .assistant, content: "こんにちは！")]
    
    // ユーザーが入力中の新しいメッセージ
    @Published var newMessage: String = ""
    
    // characterプロパティを初期化するためのイニシャライザ
    let character: CharacterType
    
    // OpenAIのインスタンスをプロパティとして保持
    private var openAI: OpenAI?
    
    init(character: CharacterType) {
        self.character = character
        
        // 環境変数からAPIキーを取得
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            // OpenAIのインスタンスを作成
            self.openAI = OpenAI(apiToken: apiKey)
            print("APIキーが設定されました。")
        } else {
            print("APIキーが設定されていません。環境変数の設定をしてください")
        }
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let userMessage = ChatMessage(role: .user, content: newMessage)
        messages.append(userMessage)
        newMessage = ""
        
        // fetchOpenAIResponseメソッドを非同期タスクで呼び出し、OpenAIからの応答を取得。
        Task {
            await fetchOpenAIResponse(for: userMessage)
        }
    }
    
    @MainActor
    private func fetchOpenAIResponse(for userMessage: ChatMessage) async {
        guard let openAI = openAI else {
            let errorResponse = ChatMessage(role: .assistant, content: "APIキーが設定されていません")
            messages.append(errorResponse)
            return
        }
        
        // ユーザーのメッセージ
        guard let message = ChatQuery.ChatCompletionMessageParam(role: .user, content: userMessage.content),
              
              // システムメッセージ（キャラクターのプロンプト）
              let systemMessage = ChatQuery.ChatCompletionMessageParam(role: .system, content: character.prompt) else { return }

        // 使用するモデルを指定
        let query = ChatQuery(messages: [systemMessage, message], model: .gpt3_5Turbo)
        
        do {
            // クエリをOpenAIに送信し、応答を取得
            let result = try await openAI.chats(query: query)
            
            // 返された応答メッセージ
            if let firstChoice = result.choices.first {
                switch firstChoice.message {
                
                // 応答メッセージがアシスタントからのものである場合、その内容をassistantMessageとして取得
                case .assistant(let assistantMessage):
                    
                    // 取得したアシスタントのメッセージをChatMessageオブジェクトに変換し、内容が空の場合はデフォルトで「がんばって！」というメッセージを設定
                    let assistantResponse = ChatMessage(role: .assistant, content: assistantMessage.content ?? "がんばって！")
                    messages.append(assistantResponse)
                    
                default:
                    break
                }
            }
        } catch {
            let errorResponse = ChatMessage(role: .assistant, content: "エラー: \(error.localizedDescription)")
            messages.append(errorResponse)
        }
    }
}

#Preview {
    CharacterSelectionView()
}

