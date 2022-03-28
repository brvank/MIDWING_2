class Order {
  int id, channelId;
  String custName, custPhone, addr, city, state, paymentStatus, deliveredDate, paymentMethod;
  Product product;
  Pickup pickup;

  Order(
      {required this.id,
      required this.channelId,
      required this.custName,
      required this.custPhone,
      required this.addr,
      required this.city,
      required this.state,
      required this.paymentStatus,
      required this.deliveredDate,
      required this.paymentMethod,
      required this.product,
      required this.pickup});
}

class Product {
  int id;
  String name, status;

  Product({required this.id, required this.name, required this.status});
}

//TODO: to add the email option also
class Pickup {
  int id;
  String address, city, state, country, pincode, delvPhone, delvName;

  Pickup(
      {required this.id,
      required this.address,
      required this.city,
      required this.state,
      required this.country,
      required this.pincode,
      required this.delvName,
      required this.delvPhone});
}
