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



struct CurrentWeatherView: View {
  //9.💜 viewModel 인스턴스로 데이터 받아주고
  @ObservedObject  var viewModel: CurrentWeatherViewModel
  init ( viewModel : CurrentWeatherViewModel ) {
     self .viewModel = viewModel
  }
  
  //10.💜
  var body: some  View {
    //⭐️⭐️⭐️ List라고는 했지만 리스트 참조 데이터가 없고 바로content 이기 때문에 그냥 하나의 content를 보여주는 용도???
     List (content: content) //extension
      .onAppear(perform: viewModel.refresh)
      .navigationBarTitle(viewModel.city)
      .listStyle( GroupedListStyle ())
  }
}

//11.💜 CurrentWeatherView의 extension!!!!
private extension CurrentWeatherView {
  //⭐️⭐️⭐️ viewModel.dataSource 값이 있을 때는details 함수 실행 -> CurrentWeatherRow 보여주는 용도
  //viewModel.dataSource 값이 없을 때는 loading 보여주는 용도
  func content() -> some View {
    //⭐️⭐️⭐️ viewModel.dataSource여기서 datasource는 WeeklyWeatherViewModel에서의 dataSource처럼 배열이 아니다!!!
    if let viewModel = viewModel.dataSource {
      //⭐️ 아래 details라는 함수에viewModel 인스턴스 전달
      return AnyView(details(for: viewModel))
    } else {
      return AnyView(loading)
    }
  }

  //⭐️⭐️⭐️ CurrentWeatherView 에서 파생되는 컴포넌트 CurrentWeatherRow
  func details(for viewModel: CurrentWeatherRowViewModel) -> some View {
    CurrentWeatherRow(viewModel: viewModel)
    //⭐️여기서의 viewModel은 RowViewModel???
  }

  var loading: some View {
    Text("Loading \(viewModel.city)'s weather...")
      .foregroundColor(.gray)
  }
}

