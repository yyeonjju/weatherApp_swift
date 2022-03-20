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

import Foundation
import Combine

class WeatherFetcher {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
}

//2.💜
//⭐️ Response에서 작성해준 타입 AnyPublisher의 성공 타입으로 넣어주기
//=>WeeklyForecastResponse, CurrentWeatherForecastResponse
protocol WeatherFetchable {
  func weeklyWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<WeeklyForecastResponse, WeatherError>

  func currentWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError>
}

//3.💜
// MARK: - WeatherFetchable
extension WeatherFetcher: WeatherFetchable {
  //⭐️⭐️⭐️
  //⭐️WeeklyWeatherViewModel 뷰모델 에서 city 입력값을 인수로 보냄
  //=> 서버에서 받은 데이터를 리턴함
  //=> 이 반환 값으로 WeeklyWeatherViewModel 에서 dataSource를 만듦
  //=> 이 값으로 실제 View에 반영시킴
  func weeklyWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<WeeklyForecastResponse, WeatherError> {
    //⭐️city 값을 makeWeeklyForecastComponents함수의 인수로 전달하여 URLComponent 반환
    //⭐️URLComponent를 forecast함수 의 인수로 전달하여 실제 api 요청으로 데이터 받음
    return forecast(with: makeWeeklyForecastComponents(withCity: city))
  }

  func currentWeatherForecast(
    forCity city: String
  ) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError> {
    return forecast(with: makeCurrentDayForecastComponents(withCity: city))
  }

  //⭐️ 실제 api 요청으로 데이터 받는 함수
  private func forecast<T>(
    with components: URLComponents
  ) -> AnyPublisher<T, WeatherError> where T: Decodable {
    // 1
    //URLComponents로 부터 URL 인스턴스를 만들려고 합니다. 만약 실패하면, Fail 값으로 감싸진 오류를 반환
    guard let url = components.url else {
      let error = WeatherError.network(description: "Couldn't create URL")
      return Fail(error: error).eraseToAnyPublisher()
    }

    // 2
    //데이터를 가져오기 위해 URLSession의 새로운 메소드 dataTaskPublisher(for:)를 사용
    return session.dataTaskPublisher(for: URLRequest(url: url))
      // 3
    //메소드가 AnyPublisher<T, WeatherError>를 반환하기 때문에, URLError에서 WeatherError로 오류를 매핑
      .mapError { error in
        .network(description: error.localizedDescription)
      }
      // 4
    //서버에서 오는 JSON 데이터를 완전한 객체로 변환하기 위해 flatmap을 사용
    //Pasing.swift에 있는 decode힘수 사용
      .flatMap(maxPublishers: .max(1)) { pair in
        decode(pair.data)
      }
      // 5
    //eraseToAnyPublisher()을 사용하지 않는 경우에 flatMap에서 반환된 전체 타입을 처리해야
    //type Eraser : subject라는 사실을 숨겨 send로 값을 추가할 수 없게 만든다
      .eraseToAnyPublisher()
  }
}



// MARK: - OpenWeatherMap API
private extension WeatherFetcher {
  struct OpenWeatherAPI {
    static let scheme = "https"
    static let host = "api.openweathermap.org"
    static let path = "/data/2.5"
    static let key = "414809b008833d16a10d0d0d4adec9e0"
  }
  
  func makeWeeklyForecastComponents(
    withCity city: String
  ) -> URLComponents {
    var components = URLComponents()
    components.scheme = OpenWeatherAPI.scheme
    components.host = OpenWeatherAPI.host
    components.path = OpenWeatherAPI.path + "/forecast"
    
    components.queryItems = [
      URLQueryItem(name: "q", value: city),
      URLQueryItem(name: "mode", value: "json"),
      URLQueryItem(name: "units", value: "metric"),
      URLQueryItem(name: "APPID", value: OpenWeatherAPI.key)
    ]
    
    return components
  }
  
  func makeCurrentDayForecastComponents(
    withCity city: String
  ) -> URLComponents {
    var components = URLComponents()
    components.scheme = OpenWeatherAPI.scheme
    components.host = OpenWeatherAPI.host
    components.path = OpenWeatherAPI.path + "/weather"
    
    components.queryItems = [
      URLQueryItem(name: "q", value: city),
      URLQueryItem(name: "mode", value: "json"),
      URLQueryItem(name: "units", value: "metric"),
      URLQueryItem(name: "APPID", value: OpenWeatherAPI.key)
    ]
    
    return components
  }
}
