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
//9.💜
import SwiftUI
import Combine

// 1
class CurrentWeatherViewModel: ObservableObject, Identifiable {
  // 2
  @Published var dataSource: CurrentWeatherRowViewModel?

  let city: String
  private let weatherFetcher: WeatherFetchable
  private var disposables = Set<AnyCancellable>()

  init(city: String, weatherFetcher: WeatherFetchable) {
    self.weatherFetcher = weatherFetcher
    self.city = city
  }

  //WeeklyWeatherViewModel 에서는 fetchWeather이라는 함수 있었음
  //=> CurrentWeatherViewModel 에서는 refresh라는 함수
  func refresh() {
    //⭐️ 1️⃣데이터 받아옴
    weatherFetcher
      .currentWeatherForecast(forCity: city)
      // 3
    //⭐️ 2️⃣받아온 데이터를 맵핑하여 CurrentWeatherRowViewModel로 보냄
    //WeeklyWeatherViewModel에서는 WeeklyWeatherRowViewModel로 로 보냈었음
    //⭐️CurrentWeatherRowViewModel에서는 item 프로퍼티로 받아서  RowView에서 보여줄 데이터로 프로퍼티 쪼개줌
      .map(CurrentWeatherRowViewModel.init)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] value in
        guard let self = self else { return }
        switch value {
        case .failure:
          self.dataSource = nil
        case .finished:
          break
        }
        }, receiveValue: { [weak self] weather in
          guard let self = self else { return }
          //⭐️ 3️⃣dataSource에 세팅시켜줌
          self.dataSource = weather
      })
      .store(in: &disposables)
  }
}

