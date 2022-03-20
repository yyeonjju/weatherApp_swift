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
  
  //5.💜
  //⭐️ WeeklyWeatherViewModel 인스턴스로 뷰모델에서 데이터 세팅해줌
  //⭐️ @ObservedObject 여서 viewModel안의 @Published 키워드를 가진 데이터값이 바뀔떄마다 반영된다
  @ObservedObject var viewModel: WeeklyWeatherViewModel
  init(viewModel: WeeklyWeatherViewModel) {
    self.viewModel = viewModel
  }
  

  var body: some View {
    NavigationView {
      List {
        //⭐️ 검색 view
        searchField

        if viewModel.dataSource.isEmpty {
          //⭐️ 결과 없을 때 view
          emptySection
        } else {
          //⭐️결과 있을 때 - 현재 날씨 view
          cityHourlyWeatherSection
          //⭐️결과 있을 때 - 주간 날씨 view
          forecastSection
        }
      }
      .listStyle(GroupedListStyle())
//      .navigationBarTitle("Weather ⛅️")
    }
  }

}

//7.💜
private extension WeeklyWeatherView {
  var searchField: some View {
    HStack(alignment: .center) {
      // 1
      //TextField에 입력된 값과 WeeklyWeatherViewModel의 city 프로퍼티 간의 연결
      //⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️viewModel인스턴스에 $을 사용해서 city 프로퍼티를 Binding<String>으로 만듭
      //=>⭐️⭐️⭐️ 뷰모델이 ObservableObject를 준수하기 때문에 가능
      TextField("e.g. Cupertino", text: $viewModel.city)
    }
  }

  var forecastSection: some View {
    Section {
      // 2
      //뷰모델의 dataSource 를 가지고 ForEach -- content와 같이 뿌려준다
       //DailyWeatherRow의 뷰에 init해서 데이터 전달 후 row 보이도록
      //⭐️ 주간 예보 가각 리스트 뿌려줘야해서
      // DailyWeatherRow 에 각각 맵핑한 데이터 전달?????
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
    //14.💜
    Section {
      //⭐️⭐️⭐️여기서 클릭하면 NavigationLink로 CurrentWeatherView로 넘어가야하기 때문에
      //WeeklyWeatherViewModel의 extension으로 currentWeatherView 프로퍼티를 설정해줌
      //여기서  WeeklyWeatherBuilder가 필요했음
      //⭐️⭐️⭐️WeeklyWeatherView에서 NavigationLink로 CurrentWeatherView로 넘어가야하기 때문에 WeeklyWeatherViewModel에 extension로 currentWeatherView 프로퍼티를 생성해주어야하는데 그 때 필요
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

  //뷰모델에서 dataSource가 비어있으면 보여주는 뷰
  var emptySection: some View {
    Section {
      Text("No results")
        .foregroundColor(.gray)
    }
  }
}

