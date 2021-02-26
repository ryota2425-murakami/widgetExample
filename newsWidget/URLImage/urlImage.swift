//
//  Created by ryota on 2021/02/26.
//

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
