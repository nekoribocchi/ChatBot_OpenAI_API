このアプリは、OpenAI APIを用いたチャットボットアプリです。

![chatbot_sc](https://github.com/user-attachments/assets/bf09d4ef-68c0-4b47-802c-227b4eaa0d5d)

## セットアップ方法
以下の手順に従ってAPIキーの設定をして頂くと正常に動作します。
### ステップ1 APIキーの取得

以下のURLにアクセスし、Sign up というボタンを押してご自身のAPIキーを取得してください。詳細なAPIキーの取得の仕方はここでは省かせていただきます。別の記事をご参考ください。

https://openai.com/index/openai-api/

### ステップ2 XcodeのスキームでAPIキーを設定

1. **Xcodeのプロジェクトを開く**
2. **上部のメニューから `Product` > `Scheme` > `Edit Scheme...` を選択**
3. **左側のメニューで `Run` を選択**
4. **上部のタブで `Arguments` を選択**
5. **`Environment Variables` セクションに以下を追加**
    - **Name**: `OPENAI_API_KEY`
    - **Value**: ご自身で取得したAPIキー


## コードの解説
以下では、OpenAI APIの使用部分に焦点を当てて説明をしていきます。
OpenAI API の処理を実装しているクラスはChatViewModelです。

このクラスを3ステップに分けて解説していきます。

### APIキーの設定

最初のコードでは主に、APIキーの取得を行っています。APIキーを直接コードに書くこともできますが、今回はセキュリティを考慮して、環境変数を使用しました。

```swift
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
```

### メッセージ送信機能の実装

この関数では、`role` と `content` を引数として渡す `ChatMessage` オブジェクトを定義します。そのオブジェクトを `fetchOpenAIResponse` メソッドに渡して、返答を待ちます。

userMessageという定数を定義

```swift
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

```

### OpenAIからの応答を取得するメソッドの実装

この関数は、OpenAI APIにユーザーメッセージを送信し、取得した応答をチャットメッセージリストに追加する非同期処理を実行します。

ここでは、ユーザーメッセージとシステムメッセージの設定を行います。それぞれのメッセージは role と content の引数を持ちます。

contentには、ユーザーメッセージの場合、ユーザーが入力した文章が設定され、システムメッセージの場合は、キャラクター設定のプロンプトが与えられます。キャラクター設定のプロンプトは、別のクラスで定義されています。

```swift
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
