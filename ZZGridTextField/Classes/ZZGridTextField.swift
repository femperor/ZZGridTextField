
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
        guard let text = sender.text else {
            return
        }
    
        let charGap = gridWidth - secuSymbolWidth - 2*secuSymbolWidth/CGFloat(maxInputNum - 1)
        let textAttr = [NSAttributedString.Key.font: sender.font!, NSAttributedString.Key.kern: charGap] as [NSAttributedString.Key : Any]
        sender.text = ""
        let attrText = text.count > maxInputNum ? String(text.dropLast()) : text
        if !isSecureTextEntry {
            sender.attributedText = NSAttributedString(string: attrText, attributes:textAttr)
        } else {
            let secuStr = repeatElement(secuSymbol, count: attrText.count).joined()
            sender.attributedText = NSAttributedString(string: secuStr, attributes:textAttr)
        }
    }
}
