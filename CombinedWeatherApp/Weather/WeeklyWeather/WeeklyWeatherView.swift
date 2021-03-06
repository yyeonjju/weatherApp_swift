/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct WeeklyWeatherView: View {
  
  //5.๐
  //โญ๏ธ WeeklyWeatherViewModel ์ธ์คํด์ค๋ก ๋ทฐ๋ชจ๋ธ์์ ๋ฐ์ดํฐ ์ธํํด์ค
  //โญ๏ธ @ObservedObject ์ฌ์ viewModel์์ @Published ํค์๋๋ฅผ ๊ฐ์ง ๋ฐ์ดํฐ๊ฐ์ด ๋ฐ๋๋๋ง๋ค ๋ฐ์๋๋ค
  @ObservedObject var viewModel: WeeklyWeatherViewModel
  init(viewModel: WeeklyWeatherViewModel) {
    self.viewModel = viewModel
  }
  

  var body: some View {
    NavigationView {
      List {
        //โญ๏ธ ๊ฒ์ view
        searchField

        if viewModel.dataSource.isEmpty {
          //โญ๏ธ ๊ฒฐ๊ณผ ์์ ๋ view
          emptySection
        } else {
          //โญ๏ธ๊ฒฐ๊ณผ ์์ ๋ - ํ์ฌ ๋?์จ view
          cityHourlyWeatherSection
          //โญ๏ธ๊ฒฐ๊ณผ ์์ ๋ - ์ฃผ๊ฐ ๋?์จ view
          forecastSection
        }
      }
      .listStyle(GroupedListStyle())
//      .navigationBarTitle("Weather โ๏ธ")
    }
  }

}

//7.๐
private extension WeeklyWeatherView {
  var searchField: some View {
    HStack(alignment: .center) {
      // 1
      //TextField์ ์๋?ฅ๋ ๊ฐ๊ณผ WeeklyWeatherViewModel์ city ํ๋กํผํฐ ๊ฐ์ ์ฐ๊ฒฐ
      //โญ๏ธโญ๏ธโญ๏ธโญ๏ธโญ๏ธโญ๏ธโญ๏ธโญ๏ธviewModel์ธ์คํด์ค์ $์ ์ฌ์ฉํด์ city ํ๋กํผํฐ๋ฅผ Binding<String>์ผ๋ก ๋ง๋ญ
      //=>โญ๏ธโญ๏ธโญ๏ธ ๋ทฐ๋ชจ๋ธ์ด ObservableObject๋ฅผ ์ค์ํ๊ธฐ ๋๋ฌธ์ ๊ฐ๋ฅ
      TextField("e.g. Cupertino", text: $viewModel.city)
    }
  }

  var forecastSection: some View {
    Section {
      // 2
      //๋ทฐ๋ชจ๋ธ์ dataSource ๋ฅผ ๊ฐ์ง๊ณ? ForEach -- content์ ๊ฐ์ด ๋ฟ๋?ค์ค๋ค
       //DailyWeatherRow์ ๋ทฐ์ initํด์ ๋ฐ์ดํฐ ์?๋ฌ ํ row ๋ณด์ด๋๋ก
      //โญ๏ธ ์ฃผ๊ฐ ์๋ณด ๊ฐ๊ฐ ๋ฆฌ์คํธ ๋ฟ๋?ค์ค์ผํด์
      // DailyWeatherRow ์ ๊ฐ๊ฐ ๋งตํํ ๋ฐ์ดํฐ ์?๋ฌ?????
      ForEach(viewModel.dataSource, content: DailyWeatherRow.init(viewModel:))
    }
  }

  var cityHourlyWeatherSection: some View {
//    Section {
//      NavigationLink(destination: CurrentWeatherView()) {
//        VStack(alignment: .leading) {
//          // 3
//          Text(viewModel.city)
//          Text("Weather today")
//            .font(.caption)
//            .foregroundColor(.gray)
//        }
//      }
//    }
    //14.๐
    Section {
      //โญ๏ธโญ๏ธโญ๏ธ์ฌ๊ธฐ์ ํด๋ฆญํ๋ฉด NavigationLink๋ก CurrentWeatherView๋ก ๋์ด๊ฐ์ผํ๊ธฐ ๋๋ฌธ์
      //WeeklyWeatherViewModel์ extension์ผ๋ก currentWeatherView ํ๋กํผํฐ๋ฅผ ์ค์?ํด์ค
      //์ฌ๊ธฐ์  WeeklyWeatherBuilder๊ฐ ํ์ํ์
      //โญ๏ธโญ๏ธโญ๏ธWeeklyWeatherView์์ NavigationLink๋ก CurrentWeatherView๋ก ๋์ด๊ฐ์ผํ๊ธฐ ๋๋ฌธ์ WeeklyWeatherViewModel์ extension๋ก currentWeatherView ํ๋กํผํฐ๋ฅผ ์์ฑํด์ฃผ์ด์ผํ๋๋ฐ ๊ทธ ๋ ํ์
        NavigationLink(destination: viewModel.currentWeatherView) {
          VStack(alignment: .leading) {
            Text(viewModel.city)
            Text("Weather today")
              .font(.caption)
              .foregroundColor(.gray)
          }
        }
      }
  }

  //๋ทฐ๋ชจ๋ธ์์ dataSource๊ฐ ๋น์ด์์ผ๋ฉด ๋ณด์ฌ์ฃผ๋ ๋ทฐ
  var emptySection: some View {
    Section {
      Text("No results")
        .foregroundColor(.gray)
    }
  }
}

