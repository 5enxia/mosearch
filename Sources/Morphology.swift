// かなの取得について
// https://qiita.com/sgr-ksmt/items/cc8882aa80a59e5a8355
import NaturalLanguage

public struct Morphology {
    private(set) static var tokens: [Token] = []

    private enum JPCharacter {
        case hiragana
        case katakana
        fileprivate var transform: CFString {
            switch self {
            case .hiragana:
                return kCFStringTransformLatinHiragana
            case .katakana:
                return kCFStringTransformLatinKatakana
            }
        }
    }

    // private static func convertToKana(_ text: String, to jpCharacter: JPCharacter) -> String {
    public static func convertToKana(_ text: String) -> String {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = ""
        let locale = CFLocaleCreate(kCFAllocatorDefault, CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, "ja" as CFString))
        let range = CFRangeMake(0, input.utf16.count)
        let tokenizer = CFStringTokenizerCreate(
            kCFAllocatorDefault,
            input as CFString,
            range,
            kCFStringTokenizerUnitWordBoundary,
            locale
        )

        var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        while (tokenType.rawValue != 0) {
            if let text = (CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? NSString).map({ $0.mutableCopy() }) {
                // CFStringTransform(text as! CFMutableString, nil, jpCharacter.transform, false)
                CFStringTransform(text as! CFMutableString, nil, kCFStringTransformLatinHiragana, false)
                output.append(text as! String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return output
    }

    public static func convertToRomaji(_ text: String) -> String {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = ""
        let locale = CFLocaleCreate(kCFAllocatorDefault, CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, "ja" as CFString))
        let range = CFRangeMake(0, input.utf16.count)
        let tokenizer = CFStringTokenizerCreate(
            kCFAllocatorDefault,
            input as CFString,
            range,
            kCFStringTokenizerUnitWordBoundary,
            locale
        )

        var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        while (tokenType.rawValue != 0) {
            if let text = (CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription) as? NSString).map({ $0.mutableCopy() }) {
                output.append(text as! String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        return output
    }

    // 
    public static func tokenize(_ s: String) -> [Token]{
        if #available(macOS 10.14, *) {
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = s
            let tokens = tokenizer.tokens(for: s.startIndex ..< s.endIndex)
            var textTokens: [Token] = []
            for token in tokens {
                let tokenStartI = token.lowerBound
                let tokenEndI = token.upperBound
                let text = s[tokenStartI ..< tokenEndI]
                // textTokens.append(Token(id: 0, term: String(text), kana: convertToKana(String(text), to: .hiragana)))
                textTokens.append(Token(id: 0, term: String(text), kana: convertToKana(String(text))))
            }
            return textTokens
        } else {
            return []
        }
    }
}