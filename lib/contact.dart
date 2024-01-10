class Contact {
  int? id; // assuming you have an ID for each person
  String name;
  String phone;
  String email;

  // Constructor
  Contact(
      { this.id,
      required this.name,
      required this.phone,
      required this.email});

  // Named constructor for creating a Person from a Map
  Contact.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        phone = map['phone'],
        email = map['email'];

  // Convert a Person object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  // Create a copy of the current Person with optional updated values
  Contact copyWith({int? id, String? name, String? phone, String? email}) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
