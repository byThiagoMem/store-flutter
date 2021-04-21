import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/product_data.dart';
import 'package:loja_virtual/tiles/product_tile.dart';

class CategoryScreen extends StatelessWidget {
  final DocumentSnapshot snapshot;

  CategoryScreen(this.snapshot);

  @override
  Widget build(BuildContext context) {
    // DefaultTabController é para dizer quantas telas vai compor o TabBar
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              snapshot.data["title"],
            ),
            centerTitle: true,
            //Estruturando o TabBar
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(Icons.grid_on),
                ),
                Tab(
                  icon: Icon(Icons.list),
                ),
              ],
            ),
          ),
          body: FutureBuilder<QuerySnapshot>(
            future: Firestore.instance
                .collection("products")
                .document(snapshot.documentID)
                .collection("items")
                .getDocuments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else
                return TabBarView(
                    // Isso para tornar a troca de categoria somente clicavel e nao deslizavel
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      //Opção de exibir por grade
                      GridView.builder(
                          padding: EdgeInsets.all(4.0),
                          //grid Delegate para dizer quantos itens teremos( nesse caso, na horizontal)
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            ProductData data = ProductData.fromDocument(
                                snapshot.data.documents[index]);
                            data.category = this.snapshot.documentID;
                            return ProductTile("grid", data);
                          }),

                      //Opcao de exibir por lista
                      ListView.builder(
                          padding: EdgeInsets.all(4.0),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            ProductData data = ProductData.fromDocument(
                                snapshot.data.documents[index]);
                            data.category = this.snapshot.documentID;
                            return ProductTile("list", data);
                          })
                    ]);
            },
          )),
    );
  }
}
