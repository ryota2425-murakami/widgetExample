//
//  Created by ryota on 2021/02/26.
//

import Foundation


private let url = URL(string: "http://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=f3ea37a3609345e6800f31b0907c7526")



private var decoder: JSONDecoder{
    let decode = JSONDecoder()
    
    return decode
}

class NewsClient {

    class func fetchSummary(onSuccess: @escaping (News) -> Void){
        guard let url = url else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else{  return  }
            do{
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 204{
                        print("empty")
                    }
                    }
             
                let Data = try decoder.decode(News.self, from: data)
                DispatchQueue.main.async {
                    onSuccess(Data)
                }
            }catch{
                print(error.localizedDescription)
            
            }
        }.resume()
    }
}


