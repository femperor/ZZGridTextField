
import UIKit


@IBDesignable
open class ZZGridTextField: UITextField {
    
    @IBInspectable
    public var maxInputNum: Int = 6
    
    @IBInspectable
    public var borderColor: UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        }
        get {
            UIColor(cgColor: self.layer.borderColor ?? UIColor.black.cgColor)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.leftView = nil
        self.rightView = nil
        
        self.leftViewMode = .never
        self.rightViewMode = .never
        self.clearButtonMode = .never
        self.borderStyle = .bezel
        self.tintColor = UIColor.clear
        
        self.addTarget(self,
                       action: #selector(textFieldEditingChanged(sender:)),
                       for: UIControl.Event.editingChanged)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
   
        let width = rect.width
        ctx.beginPath()
        for i in 0...maxInputNum {
            let x = CGFloat(i) * gridWidth
            ctx.move(to: CGPoint(x: x, y: 0.0))
            ctx.addLine(to: CGPoint(x: x, y: rect.size.height))
        }
        ctx.move(to: CGPoint(x: 0.0, y: 0.0))
        ctx.addLine(to: CGPoint(x: width, y: 0))
        
        ctx.move(to: CGPoint(x: 0.0, y: rect.size.height))
        ctx.addLine(to: CGPoint(x: width, y: rect.size.height))

        ctx.closePath()
        
        ctx.setStrokeColor(borderColor.cgColor)
        ctx.drawPath(using: .fillStroke)
    }
    
    var gridWidth: CGFloat {
        self.bounds.size.width / CGFloat(maxInputNum)
    }
    
    var secuSymbol: String {
        "•"
    }
    
    private var secuSymbolWidth: CGFloat {
        (secuSymbol as NSString).size(withAttributes:[NSAttributedString.Key.font: self.font!]).width
    }
    
    //
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var offset: CGFloat = 0.0;
        offset = (gridWidth - secuSymbolWidth) / 2.0
        return CGRect(x: bounds.origin.x + offset, y: bounds.origin.y, width: bounds.size.width + gridWidth, height: bounds.size.height)
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        var offset: CGFloat = 0.0;
        offset = (gridWidth - secuSymbolWidth) / 2.0
        return CGRect(x: bounds.origin.x + offset, y: bounds.origin.y, width: bounds.size.width + gridWidth, height: bounds.size.height)
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: (Any)?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
    
    @objc private func textFieldEditingChanged(sender: UITextField) {
 
        guard let text = sender.attributedText, text.string.count > 1 else {
            print("attributedstring is nil")
            return
        }
    
        if text.string.count > maxInputNum {
            sender.attributedText = text.attributedSubstring(from: NSRange(location: 0, length: maxInputNum))
            return
        }
        
        if !isSecureTextEntry {
            let lastTwoRange = NSRange(location: text.string.count - 2, length: 2)
            let lastTwo = text.attributedSubstring(from: lastTwoRange)
      
            let charGap = gridWidth - lastTwo.string.size(withAttributes:[NSAttributedString.Key.font: self.font!]).width/2.0
            let textAttr = [NSAttributedString.Key.font: sender.font!, NSAttributedString.Key.kern: charGap] as [NSAttributedString.Key : Any]
            
            let newAttributedString = (text.mutableCopy() as! NSMutableAttributedString)
            newAttributedString.setAttributes(textAttr, range: lastTwoRange)
            sender.attributedText = newAttributedString
        } else {
            
            let charGap = gridWidth - ("3" as NSString).size(withAttributes:[NSAttributedString.Key.font: self.font!]).width // gap is about 8.5
            let textAttr = [NSAttributedString.Key.font: sender.font!, NSAttributedString.Key.kern: charGap] as [NSAttributedString.Key : Any]
        
            sender.attributedText = NSAttributedString(string: text.string, attributes:textAttr)
        }
    }
}
