import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../Service/Model/Model.dart';
import 'Widget/Boxes.dart';
import 'Widget/Dialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //final List<Transaction> transactions = [];

  @override
  void dispose(){
    //Hive.box('transactions').close();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive DB Project'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Boxes.getTransaction().listenable(),
        builder: (context, box, _){
          final transactions = box.values.toList().cast<Transaction>();
          return buildContent(transactions);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => TransactionDialog(
            onClickedDone: addTransaction,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildContent(List<Transaction> transactions){
    if(transactions.isEmpty){
      return const Center(
        child: Text('Empty UWU',style: TextStyle(color: Colors.deepPurple),),
      );
    }else{
      final netExpense = transactions.fold<double>(
        0,
          (previousValue,transaction)=>transaction.isExpense
          ? previousValue - transaction.amount
          : previousValue + transaction.amount,
      );
      final newExpenseString = '\$${netExpense.toStringAsFixed(2)}';
      final color = netExpense > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          SizedBox(height: 24,),
          Text(
            'Net Expense: $newExpenseString',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24,),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context,int index){
                final transaction = transactions[index];
                return buildTransaction(context,transaction);
              },
            )
          ),
        ],
      );
    }
  }

  Widget buildTransaction(BuildContext context,Transaction transaction){
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdTime);
    final amount = NumberFormat.currency(symbol: '\$',decimalDigits: 2).format(transaction.amount);

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
        title: Text(
          transaction.name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            color: color,
          ),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          buildButton(context, transaction)
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context,Transaction transaction){
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            label: Text('Edit'),
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return TransactionDialog(
                  transaction: transaction,
                  onClickedDone: (name,amount,isExpense){
                    editTransaction(transaction, name, amount, isExpense);
                  },
                );
              }));
            },
          ),
        ),
        Expanded(
          child: TextButton.icon(
            label: Text('Delete'),
            icon: Icon(Icons.delete),
            onPressed: (){
              deleteTransaction(transaction);
            },
          ),
        )
      ],
    );
  }

  Future addTransaction(String name, double amount, bool isExpense) async{
    final transaction = Transaction()
      ..name = name
      ..amount = amount
      ..isExpense = isExpense
      ..createdTime = DateTime.now();
    final box = Boxes.getTransaction();
    box.add(transaction);
  }

  void editTransaction(
    Transaction transaction,
    String name,
    double amount,
    bool isExpense,
  ){
    transaction.name = name;
    transaction.amount = amount;
    transaction.isExpense = isExpense;
    transaction.save();
  }

  void deleteTransaction(Transaction transaction){
    transaction.delete();
  }

}

