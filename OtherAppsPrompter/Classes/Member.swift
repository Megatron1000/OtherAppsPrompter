import Cocoa

struct Member: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case address
        case vars
    }
    
    enum VarsCodingKeys: String, CodingKey {
        case appIdentifiers
    }

    let address: String
    let appIdentifiers: Set<String>
    
}

extension Member {

    init(from decoder: Decoder) throws {

        let container = try decoder.container(
            keyedBy: CodingKeys.self)

        let vars = try container.nestedContainer(
            keyedBy: VarsCodingKeys.self, forKey: .vars)
        
        let address = try container.decode(String.self, forKey: .address)
        let appIdentifiers = try vars.decode(Set<String>.self, forKey: .appIdentifiers)

        self.init(address: address, appIdentifiers: appIdentifiers)
    }

}

struct MemberContainer : Decodable {
    let member: Member
}
