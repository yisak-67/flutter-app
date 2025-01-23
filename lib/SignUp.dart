import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:untitled12/main.dart'; // Replace with the actual import for your home page

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _phone = '';
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<void> signUp() async {
    const String url = 'http://localhost:3001/users/register';
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['email'] = _email;
      request.fields['password'] = _password;
      request.fields['name'] = _name;
      request.fields['phone'] = _phone;

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Replace HomePage with your actual home page widget
            );
          },
        ),
        title: Text('Sign Up'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        label: 'Name',
                        icon: Icons.person,
                        onSaved: (value) => _name = value!,
                        validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        label: 'Phone',
                        icon: Icons.phone,
                        onSaved: (value) => _phone = value!,
                        validator: (value) => value == null || value.isEmpty ? 'Enter your phone' : null,
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        label: 'Email',
                        icon: Icons.email,
                        onSaved: (value) => _email = value!,
                        validator: (value) => value == null || value.isEmpty ? 'Enter your email' : null,
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        label: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                        onSaved: (value) => _password = value!,
                        validator: (value) => value == null || value.isEmpty ? 'Enter your password' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text('Upload Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      SizedBox(height: 10),
                      _image == null
                          ? Text('No image selected.', style: TextStyle(color: Colors.grey))
                          : Image.file(
                        _image!,
                        height: 100,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            signUp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        ),
                        child: Text('Sign Up', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    bool isPassword = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: isPassword,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
