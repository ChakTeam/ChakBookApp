class Book {
  List<String>? authors;
  String? contents;
  String? datetime;
  String? isbn;
  int? price;
  String? publisher;
  int? salePrice;
  String? status;
  String? thumbnail;
  String? title;
  List<String>? translators;
  String? url;

  Book(
      {this.authors,
        this.contents,
        this.datetime,
        this.isbn,
        this.price,
        this.publisher,
        this.salePrice,
        this.status,
        this.thumbnail,
        this.title,
        this.translators,
        this.url});

  Book.fromJson(Map<String, dynamic> json) {
    authors = json['authors'].cast<String>();
    contents = json['contents'];
    datetime = json['datetime'];
    isbn = json['isbn'];
    price = json['price'];
    publisher = json['publisher'];
    salePrice = json['sale_price'];
    status = json['status'];
    thumbnail = json['thumbnail'];
    title = json['title'];
    translators = json['translators'].cast<String>();
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authors'] = this.authors;
    data['contents'] = this.contents;
    data['datetime'] = this.datetime;
    data['isbn'] = this.isbn;
    data['price'] = this.price;
    data['publisher'] = this.publisher;
    data['sale_price'] = this.salePrice;
    data['status'] = this.status;
    data['thumbnail'] = this.thumbnail;
    data['title'] = this.title;
    data['translators'] = this.translators;
    data['url'] = this.url;
    return data;
  }
}
