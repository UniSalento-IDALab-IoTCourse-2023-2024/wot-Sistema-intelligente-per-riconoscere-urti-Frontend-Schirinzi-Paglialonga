import 'dart:convert';
import 'dart:async';

import 'package:app_iot/myaccountpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class ProfileScreen extends StatefulWidget{

  @override
  _ProfileScreenState createState ()=> _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{

  String? nome;
  String? cognome;
  String? username;
  String? email;
  String? numeroTelefono;

  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token1 = prefs.getString('auth_token');

    if (token1 != null) {
      final decodedToken = JwtDecoder.decode(token1);
      decodedToken.forEach((key, value) {
        print('$key: $value');
      });

      setState(() {
        username = decodedToken['user'];
        token = token1;
      });

      if (username != null) {
        await _findUser();
      }
    }
  }

  Future<void> _findUser() async {
    final url = Uri.parse('http://192.168.1.22:5001/api/utenti/find_by_username/$username');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Dati ricevuti: $responseData');

        setState(() {
          nome = responseData['nome'];
          cognome = responseData['cognome'];
          email = responseData['email'];
          numeroTelefono = responseData['numero_telefono'];

        });
      } else {
        print('Errore nella richiesta: ${response.statusCode}');
        print('Messaggio di errore: ${response.body}');
      }
    } catch (error) {
      print('Errore nella richiesta: $error');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Impostazioni", style: TextStyle(
              color: Colors.grey[300],
              fontWeight: FontWeight.bold
          ),),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
            children: [
              Expanded(
                child:SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0XFF29E2FD),
                                  child: Text(
                                    "${nome?[0] ?? ''}${cognome?[0] ?? ''}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Text("$nome $cognome", style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),),
                          Text(email!, style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),),
                          const SizedBox(height: 50,),
                          const Divider(),
                          const SizedBox(height: 10,),

                          ProfileMenuWidget(
                              title: "Account",
                              icon: Icons.settings,
                              endIcon: true,
                              onPress: () {
                                Navigator.push(context, MaterialPageRoute(builder: (e) => MyAccountPage()));
                              }
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ]
        )
    );
  }
}

Widget ProfileMenuWidget({
  required String title,
  required IconData icon,
  required VoidCallback onPress,
  required bool endIcon
}) {
  return ListTile(
    onTap: onPress,
    leading: Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Color(0XFF29E2FD).withOpacity(0.1),
      ),
      child: Icon(icon, color: Color(0XFF29E2FD),),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.grey[300],
      ),
    ),
    trailing: endIcon
        ? Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.grey[300]?.withOpacity(0.1),
      ),
      child: Icon(Icons.chevron_right, size: 18.0, color: Colors.grey[300],),
    )
        : null,
  );
}
