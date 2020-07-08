import Foundation
/// Represents a model for the country object
@objcMembers public class TapCountry : Codable {
    /// Arabic name
	public let nameAR : String?
    /// English name
	public let nameEN : String?
    /// Phone calling international code
	public let code : String?
    /// The correct mobile length for the country
	public let phoneLength : Int?

	enum CodingKeys: String, CodingKey {

		case nameAR = "nameAR"
		case nameEN = "nameEN"
		case code = "code"
		case phoneLength = "phoneLength"
	}

    required public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		nameAR = try values.decodeIfPresent(String.self, forKey: .nameAR)
		nameEN = try values.decodeIfPresent(String.self, forKey: .nameEN)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		phoneLength = try values.decodeIfPresent(Int.self, forKey: .phoneLength)
	}
    
    
    
    /**
     Wrapper for deciding the name to be displayed. Will hide the inner logiccal formatting or model attributes changes
     - Parameter lang: The lang code you want to the country ode localisation for
     - Returns: The localized country code and "" as a fallback for any error
     */
    public func localizedName(for lang:String) -> String {
        guard let nameAR = nameAR, let nameEN = nameEN else { return "" }
        return lang.lowercased() == "ar" ? nameAR : nameEN
    }

}
