# widgetExample

### [NewsAPI](https://newsapi.org/)からJSONで技術系のニュースデータを取得してその１つめのデータをWidgetに表示するサンプルプログラム。  


![Simulator Screen Shot - iPod touch (7th generation) - 2021-02-26 at 17.47.27.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/187470/3e353487-1f83-dcb8-ad65-9e5c51ffde9e.png)

---

ニュースを取得するためにNewsAPIを利用するのでそのAPIKeyを取得します。News系のAPIで探してみるとこれが多く使われてるみたいです。APIKeyを取得したら以下のようにGETするとレスポンスがかえってきます。

```
http://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=APIキー
```
WidgetKitがHTTP通信を行うことができるようにinfo.plistを編集してあげる必要があります。HTTPS通信が必須化しているためHTTP通信を行うには許可する必要があります。 
 今回編集するのはアプリのinfo.plistではなく、Widgetのフォルダに作成されたinfo.plistを編集する必要があることに注意してください。  
HTTP通信の許可する方法についてはこちらが参考になります。
[iOSアプリのhttp通信を許可する方法](https://qiita.com/Howasuto/items/f8e97796c6eb30de4112)
  


![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/187470/c2e81be9-3781-1d7f-0844-f4bc80ebcf2e.png)

まずはCodableなモデルを作成していきます。  
JSONからモデルを作成する時は、[Convert JSON into gorgeous](https://quicktype.io/)が便利です。JSONを入力するだけでいい感じにモデルを作ってくれます。

```{Swift}
import WidgetKit
import SwiftUI
import Intents



import Foundation

// MARK: - News
struct News: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

// MARK: - Article
struct Article: Codable {
    let source: Source?
    let author, title, articleDescription: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

// MARK: - Source
struct Source: Codable {
    let id: ID?
    let name: Name?
}

enum ID: String, Codable {
    case techcrunch = "techcrunch"
}

enum Name: String, Codable {
    case techCrunch = "TechCrunch"
}

```

次はWidgetKitのメインとなる部分です。今回は最初からあるSimpleEntryにnewsDataの項目を追加しています。取得したデータからTimelineEntryを作成し、それをもとにTimelineを構成していくイメージです。

```{Swift}


import WidgetKit
import SwiftUI
import Intents


struct Provider: IntentTimelineProvider {
    @ObservedObject var NewsStore = SessionStore()
    func placeholder(in context: Context) -> SimpleEntry {
        #Widgetが読み込み中の時に呼ばれる
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), newsData:  [] as? News)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
         #Widgetを追加しようとするときに例として表示される
         #ダミーのデータをいれるとよい
        let entry = SimpleEntry(date: Date(), configuration: configuration, newsData:  [] as? News)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        /// 1時間ごとに更新する
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        NewsStore.fetch{ newData in
            entries.append(SimpleEntry(date: Date(), configuration: ConfigurationIntent(), newsData: newData))
            
            let timeline = Timeline(entries: entries, policy: .after(refresh))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let newsData:News?
   
}

struct newsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        VStack{
            URLImageView(url: URL(string: entry.newsData?.articles?[0].urlToImage ?? "")!)
                .aspectRatio(contentMode: .fill)
                Text(entry.newsData?.articles?[0].title ?? "")
                    .foregroundColor(.black)
                    .font(.headline)
                    .padding(8)
        } 
    }
}

@main
struct newsWidget: Widget {
    let kind: String = "newsWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            newsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("News Widget")
        .description("News Widgetの説明")
        #大きなwidgetのみ対応する
        .supportedFamilies([.systemLarge])
    }
}

struct newsWidget_Previews: PreviewProvider {
    static var previews: some View {
        newsWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), newsData: [] as? News))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

```

データを取得するクラスはこんな感じで実装しています。

```{Swift}
import Foundation
import Combine

final class SessionStore: ObservableObject {
    @Published  var current : News?
    init(){
        self.fetch{ val in
            print(val)
        }
    }
}
extension SessionStore{
    func fetch(completion : @escaping(News)->()){
        NewsClient.fetchSummary {
            self.current = $0
            completion($0)
        }
    }
}

```

最後にURLから画像を読み込む処理についてです。
Swiftで非同期で画像を取得するときはKing Fisherとかが便利なんですが、今回はSwiftUIで実装するということもあり処理を別途書く必要があります。



```{Swift}
import SwiftUI
struct URLImageView: View {
    let url: URL
    @ViewBuilder
    var body: some View {
        if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()

        } else {
            Image(systemName: "photo")
                .resizable()
        }
    }
}
```

以上で、Widgetの実装は終わりになります。
これでWidgetを追加すると最新のニュースが表示されます。
