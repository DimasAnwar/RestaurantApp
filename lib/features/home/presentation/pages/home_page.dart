import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/widgets/custom_input.dart';


class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.place,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4), // Kasih jarak dikit antara ikon dan teks
              
              // 2. Teks Lokasi
              const Text(
                "Current Location",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // 3. SPACER (Ngedorong elemen setelahnya mentok ke ujung)
              const Spacer(),

              // 4. Bikin Gambar Bulat Penuh
              ClipOval(
                child: Image.asset(
                  "assets/images/sate.jpg",
                  width: 45,  // Lebar gambar (silakan disesuaikan)
                  height: 45, // Tinggi wajib sama dengan lebar biar bulat sempurna
                  fit: BoxFit.cover, // Wajib pakai ini biar gambar sate lu nggak gepeng
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Column(
            children: [
              Text("Hello Dimas",
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.bold
              )),
              Text("What are you Eating Today?"),
              SizedBox(height: 20),
            ],
          ),
          Row(
            children: [
              CustomInput(
                icon: Icons.search,
                label: "Search", 
                hint: " Seacrh for food,drinks etc." ,
                controller: _searchController,
                ),
                IconButton(onPressed: (){}, icon: Icon(Icons.mic,
                size: 40,
                )),
            ],
          ),
          SizedBox(height: 20,),
          Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                width: double.infinity,
                height: 150,
                child : ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(20),
                  child: Image.asset("assets/images/promo1.jpg",
                  fit: BoxFit.cover,
                  ),
                )
              ),
              Positioned.fill( 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, // Mulai dari atas
                        end: Alignment.bottomCenter, // Sampai ke bawah
                        colors: [
                          Colors.transparent, 
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 50,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text("Spesial Offers",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),),
                    )
                  ],
                ),
                ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  children: [
                    Text("50% Off \n First Order",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                    )
                  ],
                )
                ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          //Tabs Katalog 
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  
                  child:Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 184, 174),
                    borderRadius: BorderRadius.circular(15)
                          ),
                        child: IconButton(
                          onPressed: (){}, 
                        icon: Icon(Icons.food_bank,
                        size: 40,
                        color: const Color.fromARGB(255, 85, 27, 13),)
                        ),
                      ),
                      Text("Food",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Inter'
                      ),)
                    ],
                  ) ,
                  
                ),
                SizedBox(width:20),
                Container(
                  
                  child:Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 184, 174),
                    borderRadius: BorderRadius.circular(15)
                          ),
                        child: IconButton(
                          onPressed: (){}, 
                        icon: Icon(Icons.local_drink_rounded,
                        size: 40,
                        color: const Color.fromARGB(255, 85, 27, 13),)
                        ),
                      ),
                      Text("Drinks",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Inter'
                      ),)
                    ],
                  ) ,
                  
                ),
                SizedBox(width:20),
                Container(
                  
                  child:Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 184, 174),
                    borderRadius: BorderRadius.circular(15)
                          ),
                        child: IconButton(
                          onPressed: (){}, 
                        icon: Icon(Icons.icecream_rounded,
                        size: 40,
                        color: const Color.fromARGB(255, 85, 27, 13),)
                        ),
                      ),
                      Text("Desert",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Inter'
                      ),)
                    ],
                  ) ,
                  
                ),
              ],
            ),
          ),
          


        ],
      ),
    ),
  ),
);
  }
}