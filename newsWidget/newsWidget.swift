
//
//  Created by ryota on 2021/02/26.
//


import WidgetKit
import SwiftUI
import Intents


struct Provider: IntentTimelineProvider {
    @ObservedObject var NewsStore = SessionStore()
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), newsData:  [] as? News)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge])
    }
}

struct newsWidget_Previews: PreviewProvider {
    static var previews: some View {
        newsWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), newsData: [] as? News))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


