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

//⭐️ 받아줄 데이터의 타입들 지정 => WeatherFetcher에서 AnyPublisher<,> 에 성공 타입으로 넣어주기
//⭐️ 주간 날씨 리스트 데이터
struct WeeklyForecastResponse: Codable {
  let list: [Item]
  
  struct Item: Codable {
    let date: Date
    let main: MainClass
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
      case date = "dt"
      case main
      case weather
    }
  }
  
  struct MainClass: Codable {
    let temp: Double
  }
  
  struct Weather: Codable {
    let main: MainEnum
    let weatherDescription: String
    
    enum CodingKeys: String, CodingKey {
      case main
      case weatherDescription = "description"
    }
  }
  
  enum MainEnum: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
  }
}

//⭐️ 현재 날씨 디테일 페이지 데이터
struct CurrentWeatherForecastResponse: Decodable {
  let coord: Coord
  let main: Main
  
  struct Main: Codable {
    let temperature: Double
    let humidity: Int
    let maxTemperature: Double
    let minTemperature: Double
    
    enum CodingKeys: String, CodingKey {
      case temperature = "temp"
      case humidity
      case maxTemperature = "temp_max"
      case minTemperature = "temp_min"
    }
  }
  
  struct Coord: Codable {
    let lon: Double
    let lat: Double
  }
}