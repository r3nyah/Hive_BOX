import 'package:hive/hive.dart';
import '../../Service/Model/Model.dart';

class Boxes{
  static Box<Transaction> getTransaction(){
    return Hive.box<Transaction>('transactions');
  }
}