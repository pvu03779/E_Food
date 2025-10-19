//
//  ShoppingListView.swift
//  E-Food
//
//  Created by Vu Phong on 17/10/25.
//

import SwiftUI

struct ShoppingListView: View {
    var body: some View {
        NavigationView {
            List {
                ShoppingItemView(imageName: "olive_oil", name: "Vegetable oil", description: "Extra-virgin olive oil", quantity: "1 Liter")
                ShoppingItemView(imageName: "chicken_breast", name: "Chicken breast", description: "cut into bite-sized pieces", quantity: "1 Kg")
                ShoppingItemView(imageName: "sugar", name: "Sugar", description: "White sugar", quantity: "1 Kg")
                ShoppingItemView(imageName: "chili_peppers", name: "Dried red chili peppers", description: "Bird's eye chili", quantity: "500 g")
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Shopping list")
        }
    }
}

struct ShoppingItemView: View {
    let imageName: String
    let name: String
    let description: String
    let quantity: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text(description).font(.subheadline).foregroundColor(.gray)
                Text(quantity)
            }
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
