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
import Combine

// 1
//ObservableObject와 Identifiable을 준수하도록
//프로퍼티가 바인딩(bindings)을 사용할 수 있다는 의미
class WeeklyWeatherViewModel: ObservableObject, Identifiable {
  // 2
  //프로퍼티를 관찰(observe)하는 것이 가능하도록  @Published
  //SwiftUI는 해당 게시자(publisher)를 구독(subscribes)하고 프로퍼티가 변할때 화면을 다시 그려준다
  //⭐️ @Published => 변화가 트레팅됨
  //=> 뷰에서의 입력값에 따라 => 뷰모델에서 값 변동을 인식하면
  //=> 뷰모델의 fetchWeather 함수 재실행 => 모델 WeatherFetcher의 함수 재실행하면서
  //=> 데이터 새로 받아옴 => 받아온 데이터로 dataSource 세팅
  //=> 뷰에 반영
  @Published var city: String = ""
  // 3
  @Published var dataSource: [DailyWeatherRowViewModel] = []

  //⭐️ weatherFetcher인스턴스
  private let weatherFetcher: WeatherFetchable

  // 4
  private var disposables = Set<AnyCancellable>()

  
  //8.💜
  //⭐️⭐️⭐️⭐️⭐️⭐️ SceneDelegate에서 WeeklyWeatherViewModel 초기화 ??????
  //⭐️ 이 코드는 두 세계(SwiftUI와 Combine)를 연결하기 때문에 중요
//  init(weatherFetcher: WeatherFetchable) {
//    self.weatherFetcher = weatherFetcher
//  }
  // 1
  // scheduler 매개변수를 추가해서, HTTP 요청에서 사용할 큐(queue)를 지정
  init(
    weatherFetcher: WeatherFetchable,
    scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
  ) {
    self.weatherFetcher = weatherFetcher
    
    // 2
    // city 프로퍼티는 @Published 프로퍼티 델리게이터를 사용므로 다른 Publisher와 같은 역할을 합니다. 이것은 관찰될(observed)수 있고 Publiser에서 사용할 수 있는 다른 메소드를 사용할 수 있다는 의미
    $city
      // 3
      .dropFirst(1)
      // 4
      // debounce는 사용자가 입력을 멈추고 마지막 값을 전달할때까지 0.5초 동안 기다리다가 동작
      //인자로 scheduler을 전달하는 것은, 특정 큐에서 모든 값이 내보내지는 것을 의미합니다. 경험상(Rule of thumb), 백그라운드 큐(background queue)에서 값을 처리하고 메인 큐(main queue)에 전달해야 합니다.
      .debounce(for: .seconds(0.5), scheduler: scheduler)
      // 5
      //publisher를 구독하는 방법중 하나 => .sink
      //구독했던 city 값이 변경됨에 따라 이 값을 전달
      .sink(receiveValue: fetchWeather(forCity:))
      // 6
      .store(in: &disposables)
  }

  
  //4.💜
  func fetchWeather(forCity city: String) {
    // 1
    //⭐️⭐️⭐️ weatherFetcher의 weeklyWeatherForecast함수에 city입력값을 인수로 보내고
    //=> 반환된 값으로 dataSource를 세팅시켜준다
    weatherFetcher.weeklyWeatherForecast(forCity: city)
      .map { response in
        // 2
        // 응답받은 것(WeeklyForecastResponse 객체)을 DailyWeatherRowViewModel 객체의 배열로 매핑합니다. 해당 요소(entity)는 목록에서 한 행(row)을 나타냅니다
        //⭐️서버에서 받은 리스트 데이터를 맵핑하여 하나하나 Row로 들어갈 수 있도록
        //DailyWeatherRowViewModel 뷰모델!!!에 전달?!?!?
        response.list.map(DailyWeatherRowViewModel.init)
      }

      // 3
      //하루에 시간에 따라 여러개의 온도를 반환하므로, 중복되는 것을 제거
      //removeDuplicates => Array+Filtering 파일에 extension 한 메서드
      .map(Array.removeDuplicates)

      // 4
    //메인 스레드에서 처리되는 Serial Queue
    //서버로부터 데이터를 가져오거나 JSON의 blob로 파싱하는 것이 백그라운드 큐(background queue)에서 수행하지만, UI 업데이트 하는 것은 반드시 메인 큐(main queue)에서 수행해야
    // receive(on:)에서, 5, 6, 7 단계에서 수행한 업데이트가 올바른 위치에서 수행하는지를 확인
      .receive(on: DispatchQueue.main)

      // 5
    //sink(receiveCompletion:receiveValue:)를 사용해서 게시자(publisher)를 시작합니다. 이곳에서 dataSource를 적절하게 업데이트
    //publisher를 구독하는 방법중 하나 => .sink
    //publisher 내부에서 subscriber를 생성해줄 수 있는 함수 sink
      .sink(
        receiveCompletion: { [weak self] value in
          guard let self = self else { return }
          switch value {
          case .failure:
            // 6
            //이벤트가 실패한 경우에,dataSource는 비어있는 배열을 설정
            self.dataSource = []
          case .finished:
            break
          }
        },
        receiveValue: { [weak self] forecast in
          guard let self = self else { return }

          // 7
          //⭐️⭐️⭐️ publisher로부터 새로운 날씨값을 전달받았을 때 dataSource를 업데이트
          self.dataSource = forecast
      })

      // 8
    //disposable 설정에 취소 가능한 참조를 추가합니다. 이전에 언급했던 것처럼, 참조를 유지하지 않고, 네트워크 게시자(publisher)는 즉시 종료
      .store(in: &disposables)
  }

  
}

//13.💜
//⭐️⭐️⭐️WeeklyWeatherView에서 NavigationLink로 CurrentWeatherView로 넘어가야하기 때문에 WeeklyWeatherViewModel에 extension로 currentWeatherView 프로퍼티를 생성해주어야함 ( WeeklyWeatherBuilder필요한 지점)
extension WeeklyWeatherViewModel {
  var currentWeatherView: some View {
    return WeeklyWeatherBuilder.makeCurrentWeatherView(
      withCity: city,
      weatherFetcher: weatherFetcher
    )
  }
}

