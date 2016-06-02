//
//  CodeTextView.swift
//  Sublime
//
//  Created by Eular on 5/9/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import CYRTextView

extension CYRTextView {
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return false
    }
}

class CodeEngine {
    
    let textView = CYRTextView()
    
    init() {
        textView.editable = false
        textView.lineCursorEnabled = false
        textView.backgroundColor = Constant.CodeBackgroudColor
        textView.gutterBackgroundColor = Constant.CodeLineNumberBackgroudColor
        textView.gutterLineColor = Constant.CodeLineNumberBackgroudColor
        textView.textColor = UIColor.whiteColor()
        textView.font = textView.font?.fontWithSize(12)
        textView.setLineBreakMode(.ByCharWrapping)
        
        textView.contentInset.top = -7
        textView.scrollIndicatorInsets.top = -7
        
        setupTokens()
    }
    
    @objc func shareCodeInPicture() {
        print(123)
    }
    
    func setupTokens() {
        textView.tokens = [
            CYRToken(name: "Parameter", expression: "(?<=\\()[^\\)]*(?=\\))", attributes: [NSForegroundColorAttributeName : "#FD9720".color!]),
            CYRToken(name: "Parameter-fixbug", expression: "\\)+(?=\\))|\\)[^\\(]+(?=\\))", attributes: [NSForegroundColorAttributeName : "#FD9720".color!]),
            CYRToken(name: "Number", expression: "\\b(0[xX][0-9a-fA-F]+|\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?|\\.\\d+(?:[eE][+-]?\\d+)?)\\b", attributes: [NSForegroundColorAttributeName : "#AE81FF".color!]),
            CYRToken(name: "Boolean", expression: "\\b(true|false|True|False|None|nil|null|undefined|NaN)\\b", attributes: [NSForegroundColorAttributeName : "#FF3C50".color!]),
            CYRToken(name: "Operator", expression: "[/\\*\\;:=<>\\+\\-\\^!·≤≥\\?|%]", attributes: [NSForegroundColorAttributeName : "#F92772".color!]),
            CYRToken(name: "ReservedWords-js", expression: "\\b(break|continue|do|for|in|function|if|else|return|switch|default|this|throw|try|catch|finally|var|while|with|case|new|typeof|instance|delete|void|Object|Array|String|Number|Boolean|Function|RegExp|Date|Math|JSON|console|window|document|navigator|location)\\b", attributes: [NSForegroundColorAttributeName : "#66D9EF".color!]),
            CYRToken(name: "ReservedWords-css", expression: "\\b(px|em|pt|s|ms|deg|%)\\b", attributes: [NSForegroundColorAttributeName : "#66D9EF".color!]),
            CYRToken(name: "ReservedWords-php", expression: "\\b(print_r|exception|array|break|case|class|const|continue|declare|default|elseif|empty|enddeclare|endfor|endforeach|endif|endswitch|endwhile|eval|exit|extends|foreach|for|function|global|if|include|include_once|isset|list|new|print|require|require_once|return|static|switch|unset|use|var|while|final|interface|implements|extends|public|private|protected|abstract|clone|try|catch|throw|and|or|xor|as|die|do|echo|else|this)\\b", attributes: [NSForegroundColorAttributeName : "#66D9EF".color!]),
            CYRToken(name: "ReservedWords-c", expression: "\\b(asm|do|if|return|typedef|inline|typeid|bool|dynamic_cast|signed|typename|break|else|sizeof|union|case|enum|mutable|static|unsigned|catch|explicit|namespace|static_cast|using|export|new|struct|virtual|class|extern|operator|switch|void|const|private|template|volatile|const_cast|protected|this|wchar_t|continue|for|public|throw|while|default|friend|register|delete|goto|reinterpret_cast|try)\\b", attributes: [NSForegroundColorAttributeName : "#66D9EF".color!]),
            CYRToken(name: "ReservedWords-mysql", expression: "\\b(select|from|where|order|like|group|by|left|right|join|desc|asc|insert|into|values|and|or|sum|count|length|on|duplicate|key|update|limit|union|add|alter|delete|regexp|as|find_in_set|create|drop|table|exists|value|function|begin|declare|default|while|do|end|if|else|then|set|substr|return|repeat|returns|locate|int|float|varchar|char|bool|text|double|trigger|for|each|row|timestamp|primary|after|now)\\b", attributes: [NSForegroundColorAttributeName : "#66D9EF".color!]),
            CYRToken(name: "ReservedWords-python", expression: "\\b(class|finally|is|return|continue|for|lambda|try|def|from|nonlocal|while|and|del|global|not|with|as|elif|if|or|yield|assert|else|import|pass|break|except|in|raise)\\b", attributes: [NSForegroundColorAttributeName : "#66D9EF".color!]),
            CYRToken(name: "ReservedWords-swift", expression: "\\b(class|deinit|enum|extension|func|import|init|let|protocol|static|struct|subscript|typealias|var|break|case|continue|default|do|else|fallthrough|if|in|for|return|switch|where|while|as|dynamicType|is|new|super|self|__COLUMN__|__FILE__|__FUNCTION__|__LINE__|didSet|get|inout|mutating|override|set|unowned|weak|willSet)\\b", attributes: [NSForegroundColorAttributeName : "#66D9EF".color!]),
            CYRToken(name: "String", expression: "\"(?:[^\"\\\\]|\\\\[\\s\\S])*\"|'(?:[^'\\\\]|\\\\[\\s\\S])*'", attributes: [NSForegroundColorAttributeName : "#E6DB74".color!]),
            CYRToken(name: "Comment", expression: "^//.*|\\s//.*|/\\*[\\s\\S]*?\\*/|#.*|<!--.*-->", attributes: [NSForegroundColorAttributeName : "#75715E".color!]),
        ]
    }
    
}