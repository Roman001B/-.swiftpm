
import Foundation

struct CurrencyResponse: Codable {
    let result: String
    let documentation: String
    let terms_of_use: String
    let time_last_update_unix: Int
    let time_last_update_utc: String
    let time_next_update_unix: Int
    let time_next_update_utc: String
    let base_code: String
    let target_code: String
    let conversion_rate: Double
}




