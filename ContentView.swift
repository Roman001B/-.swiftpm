import SwiftUI
import CoreXLSX
import Foundation

// Модель для получения ответа по конвертации валют
struct CurrencyResponsee: Codable {
    let conversion_rate: Double
}

// Модель для получения исторических данных (переименована, если конфликтует)
struct CurrencyRate {
    var date: String
    var usd: Double
    var eur: Double
    var rub: Double
    var kzt: Double
    var cny: Double
}

struct ContentView: View {
    @State private var baseCurrency: String = ""
    @State private var targetCurrency: String = ""
    @State private var amount: String = ""
    @State private var convertedAmount: String?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var isHistoricalDataViewPresented: Bool = false

    @State private var yearInput: String = "" // Ввод года
    @State private var dateInput: String = "" // Ввод даты
    @State private var currencyInput: String = "" // Ввод валюты

    // Список валют
    let currencies: [(code: String, name: String, country: String)] = [
        ("AED", "UAE Dirham", "United Arab Emirates"),
                           ("AFN", "Afghan Afghani", "Afghanistan"),
                           ("ALL", "Albanian Lek", "Albania"),
                           ("AMD", "Armenian Dram", "Armenia"),
                                  ("ANG", "Netherlands Antillian Guilder", "Netherlands Antilles"),
                                  ("AOA", "Angolan Kwanza", "Angola"),
                                          ("ARS", "Argentine Peso", "Argentina"),
                                          ("AUD", "Australian Dollar", "Australia"),
                                          ("AWG", "Aruban Florin", "Aruba"),
                                          ("AZN", "Azerbaijani Manat", "Azerbaijan"),
                                          ("BAM", "Bosnia and Herzegovina Mark", "Bosnia and Herzegovina"),
                                          ("BBD", "Barbados Dollar", "Barbados"),
                                          ("BDT", "Bangladeshi Taka", "Bangladesh"),
                                          ("BGN", "Bulgarian Lev", "Bulgaria"),
                                          ("BHD", "Bahraini Dinar", "Bahrain"),
                                          ("BIF", "Burundian Franc", "Burundi"),
                                          ("BMD", "Bermudian Dollar", "Bermuda"),
                                          ("BND", "Brunei Dollar", "Brunei"),
                                          ("BOB", "Bolivian Boliviano", "Bolivia"),
                                          ("BRL", "Brazilian Real", "Brazil"),
                                          ("BSD", "Bahamian Dollar", "Bahamas"),
                                          ("BTN", "Bhutanese Ngultrum", "Bhutan"),
                                          ("BWP", "Botswana Pula", "Botswana"),
                                          ("BYN", "Belarusian Ruble", "Belarus"),
                                          ("BZD", "Belize Dollar", "Belize"),
                                          ("CAD", "Canadian Dollar", "Canada"),
                                          ("CDF", "Congolese Franc", "Democratic Republic of the Congo"),
                                          ("CHF", "Swiss Franc", "Switzerland"),
                                          ("CLP", "Chilean Peso", "Chile"),
                                          ("CNY", "Chinese Renminbi", "China"),
                                          ("COP", "Colombian Peso", "Colombia"),
                                          ("CRC", "Costa Rican Colon", "Costa Rica"),
                                          ("CUP", "Cuban Peso", "Cuba"),
                                          ("CVE", "Cape Verdean Escudo", "Cape Verde"),
                                          ("CZK", "Czech Koruna", "Czech Republic"),
                                          ("DJF", "Djiboutian Franc", "Djibouti"),
                                          ("DKK", "Danish Krone", "Denmark"),
                                          ("DOP", "Dominican Peso", "Dominican Republic"),
                                          ("DZD", "Algerian Dinar", "Algeria"),
                                          ("EGP", "Egyptian Pound", "Egypt"),
                                          ("ERN", "Eritrean Nakfa", "Eritrea"),
                                          ("ETB", "Ethiopian Birr", "Ethiopia"),
                                          ("EUR", "Euro", "European Union"),
                                          ("FJD", "Fiji Dollar", "Fiji"),
                                          ("FKP", "Falkland Islands Pound", "Falkland Islands"),
                                          ("FOK", "Faroese Króna", "Faroe Islands"),
                                          ("GBP", "Pound Sterling", "United Kingdom"),
                                          ("GEL", "Georgian Lari", "Georgia"),
                                          ("GGP", "Guernsey Pound", "Guernsey"),
                                          ("GHS", "Ghanaian Cedi", "Ghana"),
                                          ("GIP", "Gibraltar Pound", "Gibraltar"),
                                          ("GMD", "Gambian Dalasi", "The Gambia"),
                                          ("GNF", "Guinean Franc", "Guinea"),
                                          ("GTQ", "Guatemalan Quetzal", "Guatemala"),
                                          ("GYD", "Guyanese Dollar", "Guyana"),
                                          ("HKD", "Hong Kong Dollar", "Hong Kong"),
                                          ("HNL", "Honduran Lempira", "Honduras"),
                                          ("HRK", "Croatian Kuna", "Croatia"),
                                          ("HTG", "Haitian Gourde", "Haiti"),
                                          ("HUF", "Hungarian Forint", "Hungary"),
                                          ("IDR", "Indonesian Rupiah", "Indonesia"),
                                          ("ILS", "Israeli New Shekel", "Israel"),
                                          ("IMP", "Manx Pound", "Isle of Man"),
                                          ("INR", "Indian Rupee", "India"),
                                          ("IQD", "Iraqi Dinar", "Iraq"),
                                          ("IRR", "Iranian Rial", "Iran"),
                                          ("ISK", "Icelandic Króna", "Iceland"),
                                          ("JEP", "Jersey Pound", "Jersey"),
                                          ("JMD", "Jamaican Dollar", "Jamaica"),
                                          ("JOD", "Jordanian Dinar", "Jordan"),
                                          ("JPY", "Japanese Yen", "Japan"),
                                          ("KES", "Kenyan Shilling", "Kenya"),
                                          ("KGS", "Kyrgyzstani Som", "Kyrgyzstan"),
                                          ("KHR", "Cambodian Riel", "Cambodia"),
                                          ("KID", "Kiribati Dollar", "Kiribati"),
                                          ("KMF", "Comorian Franc", "Comoros"),
                                          ("KRW", "South Korean Won", "South Korea"),
                                          ("KWD", "Kuwaiti Dinar", "Kuwait"),
                                          ("KYD", "Cayman Islands Dollar", "Cayman Islands"),
                                          ("KZT", "Kazakhstani Tenge", "Kazakhstan"),
                                          ("LAK", "Lao Kip", "Laos"),
                                          ("LBP", "Lebanese Pound", "Lebanon"),
                                          ("LKR", "Sri Lanka Rupee", "Sri Lanka"),
                                          ("LRD", "Liberian Dollar", "Liberia"),
                                          ("LSL", "Lesotho Loti", "Lesotho"),
                                          ("LYD", "Libyan Dinar", "Libya"),
                                          ("MAD", "Moroccan Dirham", "Morocco"),
                                          ("MDL", "Moldovan Leu", "Moldova"),
                                          ("MGA", "Malagasy Ariary", "Madagascar"),
                                          ("MKD", "Macedonian Denar", "North Macedonia"),
                                          ("MMK", "Burmese Kyat", "Myanmar"),
                                          ("MNT", "Mongolian Tögrög", "Mongolia"),
                                          ("MOP", "Macanese Pataca", "Macau"),
                                          ("MRU", "Mauritanian Ouguiya", "Mauritania"),
                                          ("MUR", "Mauritian Rupee", "Mauritius"),
                                          ("MVR", "Maldivian Rufiyaa", "Maldives"),
                                          ("MWK", "Malawian Kwacha", "Malawi"),
                                          ("MXN", "Mexican Peso", "Mexico"),
                                          ("MYR", "Malaysian Ringgit", "Malaysia"),
                                          ("MZN", "Mozambican Metical", "Mozambique"),
                                          ("NAD", "Namibian Dollar", "Namibia"),
                                          ("NGN", "Nigerian Naira", "Nigeria"),
                                          ("NIO", "Nicaraguan Córdoba", "Nicaragua"),
                                          ("NOK", "Norwegian Krone", "Norway"),
                                          ("NPR", "Nepalese Rupee", "Nepal"),
                                          ("NZD", "New Zealand Dollar", "New Zealand"),
                                          ("OMR", "Omani Rial", "Oman"),
                                          ("PAB", "Panamanian Balboa", "Panama"),
                                          ("PEN", "Peruvian Sol", "Peru"),
                                          ("PGK", "Papua New Guinean Kina", "Papua New Guinea"),
                                          ("PHP", "Philippine Peso", "Philippines"),
                                          ("PKR", "Pakistani Rupee", "Pakistan"),
                                          ("PLN", "Polish Złoty", "Poland"),
                                          ("PYG", "Paraguayan Guaraní", "Paraguay"),
                                          ("QAR", "Qatari Riyal", "Qatar"),
                                          ("RON", "Romanian Leu", "Romania"),
                                          ("RSD", "Serbian Dinar", "Serbia"),
                                          ("RUB", "Russian Ruble", "Russia"),
                                          ("RWF", "Rwandan Franc", "Rwanda"),
                                          ("SAR", "Saudi Riyal", "Saudi Arabia"),
                                          ("SBD", "Solomon Islands Dollar", "Solomon Islands"),
                                          ("SCR", "Seychellois Rupee", "Seychelles"),
                                          ("SDG", "Sudanese Pound", "Sudan"),
                                          ("SEK", "Swedish Krona", "Sweden"),
                                          ("SGD", "Singapore Dollar", "Singapore"),
                                          ("SHP", "Saint Helena Pound", "Saint Helena"),
                                          ("SLE", "Sierra Leonean Leone", "Sierra Leone"),
                                          ("SOS", "Somali Shilling", "Somalia"),
                                          ("SRD", "Surinamese Dollar", "Suriname"),
                                          ("SSP", "South Sudanese Pound", "South Sudan"),
                                          ("STN", "São Tomé and Príncipe Dobra", "São Tomé and Príncipe"),
                                          ("SYP", "Syrian Pound", "Syria"),
                                          ("SZL", "Eswatini Lilangeni", "Eswatini"),
                                          ("THB", "Thai Baht", "Thailand"),
                                          ("TJS", "Tajikistani Somoni", "Tajikistan"),
                                          ("TMT", "Turkmenistani Manat", "Turkmenistan"),
                                          ("TND", "Tunisian Dinar", "Tunisia"),
                                          ("TOP", "Tongan Paʻanga", "Tonga"),
                                          ("TRY", "Turkish Lira", "Turkey"),
                                          ("TTD", "Trinidad and Tobago Dollar", "Trinidad and Tobago"),
                                          ("TVD", "Tuvaluan Dollar", "Tuvalu"),
                                          ("TZS", "Tanzanian Shilling", "Tanzania"),
                                          ("UAH", "Ukrainian Hryvnia", "Ukraine"),
                                          ("UGX", "Ugandan Shilling", "Uganda"),
                                          ("USD", "United States Dollar", "United States"),
                                          ("UYU", "Uruguayan Peso", "Uruguay"),
                                          ("UZS", "Uzbekistani Som", "Uzbekistan"),
                                          ("VES", "Venezuelan Bolívar", "Venezuela"),
                                          ("VND", "Vietnamese Đồng", "Vietnam"),
                                          ("VUV", "Vanuatu Vatu", "Vanuatu"),
                                          ("WST", "Samoan Tālā", "Samoa"),
                                          ("XAF", "Central African CFA Franc", "Central African States"),
                                          ("XCD", "East Caribbean Dollar", "East Caribbean"),
                                          ("XDR", "Special Drawing Rights", "International Monetary Fund"),
                                          ("XOF", "West African CFA Franc", "West African States"),
                                          ("XPF", "CFP Franc", "French territories of the Pacific"),
                                          ("YER", "Yemeni Rial", "Yemen"),
                                          ("ZAR", "South African Rand", "South Africa"),
                                          ("ZMW", "Zambian Kwacha", "Zambia"),
                                          ("ZWL", "Zimbabwean Dollar", "Zimbabwe")
    ]
    
    // Путь к файлу dailyrus.xlsx
    let fileURL = Bundle.main.url(forResource: "dailyrus", withExtension: "xlsx")!

    // Функция для получения обменного курса по году, валюте и дате
    func getExchangeRateFromXLSX(year: String, currency: String, date: String) -> Double? {
        do {
            // Загружаем файл XLSX, разворачиваем опционал
            guard let file = try? XLSXFile(filepath: fileURL.path) else {
                print("Ошибка при загрузке файла XLSX.")
                return nil
            }
            
            // Читаем общие строки из файла
            guard let sharedStrings = try? file.parseSharedStrings() else {
                print("Ошибка при чтении общих строк.")
                return nil
            }
            
            // Получаем список всех листов в файле
            let sheets = try file.parseWorksheetPaths()
            
            // Перебираем все листы
            for sheetPath in sheets {
                let worksheet = try file.parseWorksheet(at: sheetPath)
                
                // Используем URL для получения имени листа
                let sheetURL = URL(fileURLWithPath: sheetPath)
                let sheetName = sheetURL.lastPathComponent  // Извлекаем имя листа
                
                // Проверяем, совпадает ли название листа с нужным годом
                if sheetName.contains(year) {
                    
                    // Перебираем все строки на листе
                    for row in worksheet.data?.rows ?? [] {
                        // Пытаемся извлечь значения из каждой строки
                        if let dateCell = row.cells.first?.stringValue(sharedStrings), // Получаем дату из первой ячейки
                           let usdCell = row.cells[1].stringValue(sharedStrings), // USD во второй ячейке
                           let eurCell = row.cells[2].stringValue(sharedStrings), // EUR в третьей
                           let rubCell = row.cells[3].stringValue(sharedStrings), // RUB в четвертой
                           let kztCell = row.cells[4].stringValue(sharedStrings), // KZT в пятой
                           let cnyCell = row.cells[5].stringValue(sharedStrings) { // CNY в шестой
                           
                            // Проверяем, совпадает ли дата с искомой
                            if dateCell.contains(date) {
                                // Если дата совпала, возвращаем курс нужной валюты
                                if currency == "USD" {
                                    return Double(usdCell)
                                } else if currency == "EUR" {
                                    return Double(eurCell)
                                } else if currency == "RUB" {
                                    return Double(rubCell)
                                } else if currency == "KZT" {
                                    return Double(kztCell)
                                } else if currency == "CNY" {
                                    return Double(cnyCell)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Ошибка при обработке файла XLSX: \(error)")
            return nil
        }
        
        return nil
    }

    // Функция для получения деталей валюты (название и страна)
    func getCurrencyDetails(for currencyCode: String) -> (name: String, country: String) {
        // Ищем валюту по её коду
        if let currency = currencies.first(where: { $0.code == currencyCode }) {
            // Если нашли, возвращаем имя валюты и страну
            return (currency.name, currency.country)
        }
        // Если не нашли, возвращаем пустые строки
        return ("", "")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 5) {
                Text("Приложение для конвертации валют")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                TextField("Сумма для конвертации", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Базовая валюта")
                        Picker("Выберите валюту", selection: $baseCurrency) {
                            ForEach(currencies, id: \.code) { currency in
                                Text(currency.code).tag(currency.code)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                        let baseCurrencyDetails = getCurrencyDetails(for: baseCurrency)
                        Text("Страна: \(baseCurrencyDetails.country)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Валюта: \(baseCurrencyDetails.name)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    VStack {
                        Text("→")
                            .font(.title)
                            .frame(width: 30, alignment: .center)
                            .padding(.horizontal)
                    }

                    VStack(alignment: .leading) {
                        Text("Целевая валюта")
                        Picker("Выберите валюту", selection: $targetCurrency) {
                            ForEach(currencies, id: \.code) { currency in
                                Text(currency.code).tag(currency.code)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                        let targetCurrencyDetails = getCurrencyDetails(for: targetCurrency)
                        Text("Страна: \(targetCurrencyDetails.country)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Валюта: \(targetCurrencyDetails.name)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Button(action: {
                    convertCurrency()
                }) {
                    Text("Конвертировать")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                TextField("Введите год", text: $yearInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Введите дату (например, 11.02.17)", text: $dateInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Введите валюту (например, KGZ)", text: $currencyInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    fetchHistoricalData()
                }) {
                    Text("Получить исторический курс")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }

                if isLoading {
                    ProgressView()
                        .padding()
                } else if let convertedAmount = convertedAmount {
                    Text("Результат: \(convertedAmount)")
                        .font(.title2)
                        .foregroundColor(.green)
                } else if let errorMessage = errorMessage {
                    Text("Ошибка: \(errorMessage)")
                        .foregroundColor(.red)
                }

                Spacer()

                Button(action: {
                    exit(0)
                }) {
                    Text("Выйти из приложения")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
    }

    func convertCurrency() {
        guard let amount = Double(amount) else {
            errorMessage = "Введите корректную сумму."
            return
        }

        isLoading = true
        errorMessage = nil

        let apiKey = "bc8729f58ec71b9d8a40dec8"
        let urlString = "https://v6.exchangerate-api.com/v6/\(apiKey)/pair/\(baseCurrency)/\(targetCurrency)/\(amount)"

        guard let url = URL(string: urlString) else {
            errorMessage = "Ошибка формирования URL."
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Ошибка запроса: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "Данные отсутствуют."
                    return
                }

                do {
                    let result = try JSONDecoder().decode(CurrencyResponsee.self, from: data)
                    let convertedValue = amountToConvert(amount: amount, rate: result.conversion_rate)
                    convertedAmount = String(format: "%.2f", convertedValue)
                } catch {
                    errorMessage = "Ошибка обработки данных."
                }
            }
        }

        task.resume()
    }

    func amountToConvert(amount: Double, rate: Double) -> Double {
        return amount * rate
    }

    func fetchHistoricalData() {
        // Используем функцию для получения исторического курса
        if let rate = getExchangeRateFromXLSX(year: yearInput, currency: currencyInput, date: dateInput) {
            convertedAmount = "Курс на \(dateInput): \(rate)"
        } else {
            errorMessage = "Не удалось найти курс по заданным данным."
        }
    }
}
