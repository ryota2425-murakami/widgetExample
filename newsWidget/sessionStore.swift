//
//  Created by ryota on 2021/02/26.
//

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


