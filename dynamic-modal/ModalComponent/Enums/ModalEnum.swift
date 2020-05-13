//
//  ModalEnum.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/24/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

enum ModalEnum {
    enum PresentationType {
        case modal(title: String)
        case alert
    }
    
    enum State {
        case open
        case dismiss
    }
    
    enum OptionsCell: CaseIterable {
        case deleteCard
        
        var value: (icon: String, title: String, excerpt: String?) {
            switch self {
            case .deleteCard:
                return (icon: "D", title: "remover cartão virtual", excerpt: nil)
            }
        }
    }
    
    enum FadeType {
        case fadeIn
        case fadeOut
    }
}
