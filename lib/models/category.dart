

class Category {

  String categoryId, category;
  Category({this.categoryId, this.category});

  Category.fromJson(Map<String, dynamic> json) :
    categoryId = json['category_id'],
    category = json['category'];

}

class Category1 {

  String categoryId, category;
  Category1({this.categoryId, this.category});

  Category1.fromJson(Map<String, dynamic> json) :
        categoryId = json['id'],
        category = json['name'];

}