
class City {

  String cityId, city;
  City({this.cityId, this.city});

  City.fromJson(Map<String, dynamic> json) :
    cityId = json['city_id'],
    city = json['city'];

}