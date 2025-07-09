// class Product {
//   final int id;
//   final String name;
//   final String description;
//   final double price;
//   final String? category;  // Added category field (nullable)

//   Product({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     this.category,  // Category is optional
//   });

//   // Factory constructor to create a Product instance from JSON
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       price: double.parse(json['price'].toString()),
//       category: json['category'],  // Assuming the category exists in the response
//     );
//   }

//   // Method to convert the Product instance to a JSON object (for sending to the server)
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'price': price,
//       'category': category,  // Include category if available
//     };
//   }
// }
