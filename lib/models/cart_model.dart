import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  UserModel user;

  List<CartProduct> products = [];
  String cupomCode;
  int discountPorcentage = 0;

  bool isLoading = false;

  CartModel(this.user) {
    if (user.isLoggedIn()) _loadCartItem();
  }

  //função declarada para acessar minha classe de qualquer lugar do meu código, estou chamando ela na
  // productScreen
  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);

    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .add(cartProduct.toMap())
        .then((doc) {
      cartProduct.cid = doc.documentID;
    });
    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .delete();
    products.remove(cartProduct);
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;

    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());

    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;

    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());

    notifyListeners();
  }

  //Retorna o subTotal
  double getProductsPrice() {
    double price = 0.0;
    for (CartProduct c in products) {
      price += c.quantity * c.productData.price;
    }
    return price;
  }

  //Retorna o desconto
  double getDiscount() {
    return getProductsPrice() * discountPorcentage / 100;
  }

  //Retorna o frete
  double getShipPrice() {
    return 9.99;
  }

  void _loadCartItem() async {
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .getDocuments();
    //Transformando todos os documentos recuperados do banco em um CarProduct e depois retornando
    //em uma lista com todos esses cartProducts
    products =
        query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();
  }

  void setCupom(String couponCode, int discountPorcentage) {
    this.cupomCode = couponCode;
    this.discountPorcentage = discountPorcentage;
  }

  void updatePrices() {
    notifyListeners();
  }

  Future<String> finishOrder() async {
    if (products.length == 0) return null;
    isLoading = true;
    notifyListeners();

    double productPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    //Obtendo a referencia do id do meu pedido para salvar no usuário
    DocumentReference refOrder =
    await Firestore.instance.collection("orders").add({
      "clienteId": user.firebaseUser.uid,
      "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
      //convertendo meu cartProduct em um mapa, pois nao podemos adicionar um cartProduct no banco
      "shipPrice": shipPrice,
      "productsPrice": productPrice,
      "discount": discount,
      "totalPrice": productPrice - discount + shipPrice,
      "status": 1
    });
    //Salvando o id do pedido na coleção usuario
    await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("orders")
        .document(refOrder.documentID)
        .setData({"orderId": refOrder.documentID});

    //remover os produtos do carrinho, para isso obtivemos a referencia de cada produto do carrinho
    QuerySnapshot query = await Firestore.instance.collection("users").document(
        user.firebaseUser.uid).collection("cart").getDocuments();
    //Deletando os produtos do carrinho
    for(DocumentSnapshot doc in query.documents){
      doc.reference.delete();
    }
    //Limpando a lista local e o disconto pois já foi aplicado o desconto
    products.clear();
    discountPorcentage = 0;
    cupomCode = null;

    isLoading = false;
    notifyListeners();

    return refOrder.documentID;
  }
}
