// ∅ 2024 lil org

import WalletCore

extension Account {

    var croppedAddress: String {
        let dropFirstCount: Int
        switch coin {
        case .ethereum:
            dropFirstCount = 2
        case .near, .solana:
            dropFirstCount = 0
        default:
            fatalError(Strings.somethingWentWrong)
        }
        let withoutCommonPart = String(address.dropFirst(dropFirstCount))
        return withoutCommonPart.prefix(4) + "..." + withoutCommonPart.suffix(4)
    }
    
    var image: PlatformSpecificImage? {
        if coin == .ethereum {
            return Blockies(seed: address.lowercased()).createImage()
        } else {
            return Images.circleFill
        }
    }
    
    var accountImageAttachmentString: NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image?.withCornerRadius(7)
        attachment.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)
        let attachmentString = NSAttributedString(attachment: attachment)
        return attachmentString
    }
    
}
