import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/tiles/category_tile.dart';

class ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtendo as categorias do banco de dados
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance.collection("products").getDocuments(),
      builder: (context, snapshot) {
        // Se tiver carregando dados exibir Barra de progresso
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
          // Se nao, mostrar as categorias em um listView
          // O dividedTiles é a linha que separa cada categoria
        } else {
          var dividedTiles = ListTile.divideTiles(
                  tiles: snapshot.data.documents.map((doc) {
                    return CategoryTile(doc);
                  }).toList(),
                  color: Colors.grey)
              .toList();
          return ListView(
            children: dividedTiles,
          );
        }
      },
    );
  }
}
