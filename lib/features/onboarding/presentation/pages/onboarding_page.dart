import 'package:flutter/material.dart';
import 'dart:async'; // Taruh di baris 2 atau 3
import '../../../../core/widgets/custom_button.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  int _currentIndex = 0;

  final PageController _pageController = PageController();
  Timer? _timer;


  final List<String> _bgImages = [
    "assets/images/sate.jpg",
    "assets/images/dimsum.jpg",
    "assets/images/nasi_goreng.jpg",
  ];

  @override
  void initState() {
    super.initState();
    // Bikin timer yang jalan berulang tiap 2 detik
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      // Logika: Kalau belum mentok di gambar terakhir, geser maju
      if (_currentIndex < _bgImages.length - 1) {
        _currentIndex++;
      } else {
        // Kalau udah di gambar terakhir, balik ke gambar pertama (0)
        _currentIndex = 0;
      }

      // Perintah buat remote control geser layarnya secara animasi
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  // Wajib ada ini biar aplikasi gak bocor memori (matiin timer pas pindah layar)
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- LAYER 1: Background ---
          Positioned.fill(
           child: PageView.builder(
              controller: _pageController, // <--- TAMBAHIN BARIS INI
              itemCount: _bgImages.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _bgImages[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // --- LAYER 2: Konten UI (Teks & Tombol) ---
          SafeArea(
            bottom: false, // Biar container putih bener-bener mentok ke bawah layar HP
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(), // Mendorong semua elemen di bawahnya sampai mentok
                
                // --- BAGIAN TEKS & DOTS (Dikasih Padding) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Taste Excelent",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28, // Sedikit dibesarin biar lebih 'nendang' sebagai judul
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Seamless Ordering for the Modern Epicurean.",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w500, // Diubah ke w500 biar kontras dengan judul
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // --- DOT INDICATORS ---
                      Row(
                    children: List.generate(
                      _bgImages.length, // Sesuaikan sama nama variabel list gambar lu ya
                      (index) => AnimatedContainer(
                        // 1. Format durasi yang bener
                        duration: const Duration(milliseconds: 300), 
                        // 2. Semua properti harus di DALAM kurung AnimatedContainer
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentIndex == index ? 35 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Colors.white
                              : const Color.fromARGB(255, 156, 155, 155),
                          borderRadius: BorderRadius.circular(20), // Jangan lupa ujungnya dilengkungin
                        ),
                      ),
                    ),
                  )
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- BAGIAN CONTAINER TOMBOL (Tanpa Padding Luar) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40, bottom: 50), // Bottom dilebihin buat ruang napas
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // --- TOMBOL 1: Get Started ---
                      CustomButton(
                        text: "Get Started",
                        onPressed: () {
                         Navigator.pushNamed(context, "/regist");
                          // Add navigation logic here later
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // --- TOMBOL 2: Login ---
                      CustomButton(
                        text: "Login",
                        onPressed: () {
                         Navigator.pushNamed(context, "/login");
                          // Add navigation logic here later
                        },
                        isPrimary: false,
                        // We don't need to pass isPrimary because it defaults to true!
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}