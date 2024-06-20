class User {
  late final String work;
  late final String name;
  late final String image;
  late final String location;
  late final bool status;
  late final int price;

  User(this.work, this.name, this.image, this.location, this.status, this.price);
}

List<User> users = [
  User('Cooking for 2 days ', 'Ali Ahmed', 'images/face.png', 'Karachi', true, 500),
  User('Fix AC', 'Ahmed Ejaz', 'images/face.png', 'Lahore', false, 1000),
  User('Design Logo', 'Shakir', 'images/face.png', 'Islamabad', true, 300),
  User('Supply Chain', 'Imran', 'images/face.png', 'Peshawar', true, 700),
  User('Plumbing Service', 'Arif', 'images/face.png', 'Quetta', false, 400),
  User('Labor work', 'Khalid', 'images/face.png', 'Multan', true, 350),
  User('AC fitting', 'Laiba', 'images/face.png', 'Faisalabad', false, 600),
  User('Make script', 'Fareezeh', 'images/face.png', 'Rawalpindi', true, 450),
  User('Water pump problem', 'Qasim', 'images/face.png', 'Sialkot', true, 2000),
  User('Design a website', 'Aijaz', 'images/face.png', 'Gujranwala', false, 1200),
  User('Carpenter Work', 'Baloch', 'images/face.png', 'Sargodha', true, 300),
  User('House cleaning', 'Anum', 'images/face.png', 'Bahawalpur', false, 800),
];