import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'contact.dart';
import 'contact_add.dart';
import 'contact_edit.dart';

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  late List<Contact> contacts;
  late Database _database;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    contacts = [];
    _initDatabase();
    _loadContacts();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'contacts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE contacts(id INTEGER PRIMARY KEY, name TEXT, phone TEXT, email TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _loadContacts() async {
    final List<Map<String, dynamic>> maps = await _database.query('contacts');

    setState(() {
      contacts = List.generate(maps.length, (i) {
        return Contact.fromMap(maps[i]);
      });
    });
  }

  Future<void> _handleRefresh() async {
    await _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact App"),
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          child: contacts.isEmpty
              ? Center(child: Text('No contacts available'))
              : ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Dismissible(
                      key: Key(contact.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteContact(context, contact);
                      },
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(contact.name),
                          subtitle: Text(contact.phone),
                          onTap: () {
                            _navigateToEditContact(context, contact);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddContact(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToEditContact(BuildContext context, Contact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactScreen(contact: contact),
      ),
    );

    if (result != null && result is Contact) {
      await _updateContact(result);
      await _handleRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact updated successfully.'),
        ),
      );
    }
  }

  Future<void> _updateContact(Contact contact) async {
    await _database.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  void _navigateToAddContact(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddContactScreen()),
    );

    if (result != null && result is Contact) {
      await _saveContact(result);
      await _handleRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact added successfully.'),
        ),
      );
    }
  }

  Future<void> _saveContact(Contact contact) async {
    await _database.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _deleteContact(BuildContext context, Contact contact) async {
    await _database.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [contact.id],
    );

    await _handleRefresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact deleted successfully.'),
      ),
    );
  }
}
