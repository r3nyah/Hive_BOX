import 'package:flutter/material.dart';
import '../../Service/Model/Model.dart';

class TransactionDialog extends StatefulWidget {
  final Transaction? transaction;
  final Function(
      String name,
      double amount,
      bool isExpense
      )onClickedDone;

  const TransactionDialog({
    Key? key,
    this.transaction,
    required this.onClickedDone,
  }) : super(key: key);

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  bool isExpense = true;

  @override
  void initState(){
    super.initState();
    if(widget.transaction != null){
      final transaction = widget.transaction!;
      nameController.text = transaction.name;
      amountController.text = transaction.amount.toString();
      isExpense = transaction.isExpense;
    }
  }

  @override
  void dispose(){
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final title = isEditing ? 'Edit Transaction' : 'Add Transaction';

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 7,),
              buildName(),
              SizedBox(height: 7,),
              buildAmount(),
              SizedBox(height: 7,),
              buildRadioButtons(),
            ],
          ),
        )
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing)
      ],
    );
  }

  Widget buildName(){
    return TextFormField(
      controller: nameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Name',
      ),
      validator: (name){
        if(name == null || name.isEmpty){
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  Widget buildAmount(){
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Amount',
      ),
      keyboardType: TextInputType.number,
      validator: (amount){
        return amount != null && double.tryParse(amount) == null
            ? 'Please enter a valid amount'
            : null;
      },
      controller: amountController,
    );
  }

  Widget buildRadioButtons(){
    return Column(
      children: [
        RadioListTile<bool>(
          title: Text('Expense'),
          value: true,
          groupValue: isExpense,
          onChanged: (value) => setState(() => isExpense = value!),
        ),
        RadioListTile<bool>(
          title: Text('Income'),
          value: false,
          groupValue: isExpense,
          onChanged: (value) => setState(() => isExpense = value!),
        ),
      ],
    );
  }

  Widget buildCancelButton(BuildContext context){
    return TextButton(
      child: Text(
        'Cancel',
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: (){
        Navigator.of(context).pop();
      },
    );
  }

  Widget buildAddButton(BuildContext context,{required bool isEditing}){
    final text = isEditing
        ? 'Update'
        : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: ()async{
        final isValid = formKey.currentState!.validate();
        if(isValid){
          final name = nameController.text;
          final amount = double.parse(amountController.text);
          widget.onClickedDone(name, amount, isExpense);
          Navigator.of(context).pop();
        }
      },
    );
  }
}
