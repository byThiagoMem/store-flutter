import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loja_virtual/datas/product_data.dart';

class CartProduct{
  //id do carrinho
  String cid;

  String category;
  //id do produto
  String pid;

  int quantity;
  String size;

  ProductData productData;

  CartProduct();

  //Pegando um documento que esta armazenado no banco e transformando em um CartProduct
  CartProduct.fromDocument(DocumentSnapshot document){
    cid = document.documentID;
    category = document.data["category"];
    pid = document.data["pid"];
    quantity = document.data["quantity"];
    size = document.data["size"];
  }

  //Adicionando no Banco de dados, para isso temos que transformar as infosmacoes em um mapa
  //A função toMap está sendo chamada no cart_model
  Map<String, dynamic> toMap(){
    return {
      "category": category,
      "pid": pid,
      "quantity": quantity,
      "size": size,
      "product": productData.toResumedMap(),
    };
  }
}













