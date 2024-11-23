import 'dart:convert';

import 'package:flutter/material.dart';
import 'ExlistWidget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'NewExWidget.dart';
import 'expense.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masroufi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: mainPage(),   //mainPageHook(),
    );
  }
}

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  List<expense> allExpenses = [];
 final expensesURL = Uri.parse(
 'https://masroufi-5f157-default-rtdb.firebaseio.com/ExpensesFirebase.json');

 Future<void> fetchExpensesFromServer() async {
 try {
 var response = await http.get(expensesURL);
 var fetchedData = json.decode(response.body) as Map<String, dynamic>;
 setState(() {
 allExpenses.clear();
 fetchedData.forEach((key, value) {
 allExpenses.add(expense(amount: value['amount'], date: value['date'], id: key, title: value['title']));
 });
 });
 } catch (err) {
  print(err);
 }
 }

  Future<void> addnewExpense({required String t, required double a, required DateTime d}) async {
    return http
        .post(expensesURL, body: json.encode({'expenseTitle': t, 'expenseAmount': a, 'expenseDate': d.toIso8601String()}))
        .then((response) {
      setState(() {
        allExpenses.add(expense(amount: a, date: d, id: json.decode(response.body)['name'], title: t));
      });
    }).catchError((err) {
      throw err;
    });
  }

  void deleteExpense({required String id}) async {
  var expenseToDeleteURL = Uri.parse(
      'https://masroufi-5f157-default-rtdb.firebaseio.com/ExpensesFirebase/$id.json');
  try {
    final response = await http.delete(expenseToDeleteURL);
    if (response.statusCode == 200) {
      // Expense deleted successfully on server, update UI
      setState(() {
        allExpenses.removeWhere((element) => element.id == id);
      });
    } else {
      // Handle unsuccessful delete request (e.g., show error message)
      print("Delete request failed with status code: ${response.statusCode}" + "id: $id");
    }
  } catch (err) {
    print("Error deleting expense: $err");
  }
}




  double calculateTotal() {
    double total = 0;
    allExpenses.forEach((e) {
      total += e.amount;
    });
    return total;
  }

  void initState() {
    fetchExpensesFromServer();
    super.initState();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (b) {
                return ExpenseForm(addnew: addnewExpense);
              });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (b) {
                      return ExpenseForm(addnew: addnewExpense);
                    });
              },
              icon: Icon(Icons.add))
        ],
        title: Text('Masroufi'),
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            height: 100,
            child: Card(
              elevation: 5,
              child: Center(
                  child: Text(
                'EGP ' + calculateTotal().toString(),
                style: TextStyle(fontSize: 30),
              )),
            ),
          ),
          EXListWidget(allExpenses: allExpenses, deleteExpense: deleteExpense),
        ],
      ),
    );
  }
}
//-----------------------(Hook version)-----------------------------
class mainPageHook extends HookWidget {
  @override
  Widget build(BuildContext context) {
final ValueNotifier<List<expense>> allExpenses = useState<List<expense>>([]);
    var context = useContext();
    void addnewExpense(
        {required String t, required double a, required DateTime d}) {
      allExpenses.value = [
        ...allExpenses.value,
        expense(amount: a, date: d, id: DateTime.now().toString(), title: t)
      ];

      Navigator.of(context).pop();
    }

    void deleteExpense({required String id}) {
      allExpenses.value = [
        ...(allExpenses.value as List<expense>)
          ..removeWhere((e) {
            return e.id == id;
          })
      ];
    }

    double calculateTotal() {
      double total = 0;
      allExpenses.value.forEach((e) {
        total += e.amount;
      });
      return total;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (b) {
                return ExpenseForm(addnew: addnewExpense);
              });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (b) {
                      return ExpenseForm(addnew: addnewExpense);
                    });
              },
              icon: Icon(Icons.add))
        ],
        title: Text('Masroufi'),
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            height: 100,
            child: Card(
              elevation: 5,
              child: Center(
                  child: Text(
                'EGP ' + calculateTotal().toString(),
                style: TextStyle(fontSize: 30),
              )),
            ),
          ),
          EXListWidget(
              allExpenses: allExpenses.value as List<expense>,
              deleteExpense: deleteExpense),
        ],
      ),
    );
  }
}
