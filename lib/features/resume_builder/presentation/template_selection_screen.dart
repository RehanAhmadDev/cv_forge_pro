import 'package:flutter/material.dart';
import 'resume_form_screen.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  final List<Map<String, dynamic>> templates = const [
    {'name': 'Executive', 'tag': 'ULTRA PRO', 'type': 'ultra_premium'},
    {'name': 'Professional', 'tag': 'PRO', 'type': 'pro_canva'},
    {'name': 'Creative', 'tag': 'TRENDING', 'type': 'creative_canva'},
    {'name': 'Modern', 'tag': 'FREE', 'type': 'header'},
    {'name': 'Classic', 'tag': 'FREE', 'type': 'simple'},
    {'name': 'Minimalist', 'tag': 'FREE', 'type': 'centered'},
  ];

  Widget _buildMiniLayout(String type) {
    // 1. ULTRA PREMIUM (Executive) - 3 Color Diagonal Cut
    if (type == 'ultra_premium') {
      return Stack(
        children: [
          Positioned(
            top: -20, left: -20, right: -20,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF4158D0), Color(0xFFC850C0), Color(0xFFFFCC70)]),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
              ),
            ),
          ),
          Positioned(top: 15, left: 10, child: Container(height: 6, width: 40, color: Colors.white)),
          Positioned(top: 25, left: 10, child: Container(height: 3, width: 25, color: Colors.white70)),
          Positioned(
            top: 12, right: 10,
            child: CircleAvatar(radius: 12, backgroundColor: Colors.white, child: CircleAvatar(radius: 10, backgroundColor: Colors.grey.shade300)),
          ),
          Positioned(top: 60, left: 10, child: Container(height: 4, width: 30, color: const Color(0xFF4158D0))),
          Positioned(top: 68, left: 10, child: Container(height: 3, width: 45, color: Colors.grey.shade300)),
          Positioned(top: 74, left: 10, child: Container(height: 3, width: 40, color: Colors.grey.shade300)),

          Positioned(top: 60, right: 10, child: Container(height: 4, width: 20, color: const Color(0xFF4158D0))),
          Positioned(top: 68, right: 10, child: Container(height: 3, width: 30, color: Colors.grey.shade300)),
        ],
      );
    }
    // 2. PROFESSIONAL (Pro Canva) - Dark Left Sidebar
    else if (type == 'pro_canva') {
      return Row(
        children: [
          Container(
            width: 45, color: const Color(0xFF1A237E),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                CircleAvatar(radius: 10, backgroundColor: Colors.white, child: CircleAvatar(radius: 9, backgroundColor: Colors.grey.shade300)),
                const SizedBox(height: 10),
                Container(height: 3, width: 25, color: Colors.white),
                const SizedBox(height: 4),
                Container(height: 2, width: 20, color: Colors.white54),
                const SizedBox(height: 4),
                Container(height: 2, width: 20, color: Colors.white54),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 6, width: 50, color: const Color(0xFF1A237E)),
                  const SizedBox(height: 4),
                  Container(height: 3, width: 30, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Container(height: 15, width: double.infinity, color: const Color(0xFFE8EAF6)),
                  const SizedBox(height: 10),
                  Container(height: 4, width: 40, color: const Color(0xFF1A237E)),
                  const SizedBox(height: 4),
                  Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
                ],
              ),
            ),
          ),
        ],
      );
    }
    // 3. CREATIVE (Creative Canva) - Dark Header, Orange Accent
    else if (type == 'creative_canva') {
      return Column(
        children: [
          Container(
            height: 45, color: const Color(0xFF212121),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 5, width: 40, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(height: 3, width: 25, color: const Color(0xFFFF6D00)),
                  ],
                ),
                CircleAvatar(radius: 10, backgroundColor: const Color(0xFFFF6D00), child: CircleAvatar(radius: 9, backgroundColor: Colors.grey.shade300)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 35, color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 3, width: 20, color: const Color(0xFF212121)),
                      const SizedBox(height: 2),
                      Container(height: 2, width: 15, color: const Color(0xFFFF6D00)),
                      const SizedBox(height: 8),
                      Container(height: 2, width: 20, color: Colors.grey.shade400),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 4, width: 30, color: const Color(0xFF212121)),
                        const SizedBox(height: 4),
                        Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Container(height: 4, width: 40, color: const Color(0xFF212121)),
                        const SizedBox(height: 4),
                        Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }
    // 4. MODERN (Header Style - Real Look)
    else if (type == 'header') {
      return Column(
          children: [
            Container(
              height: 40, color: Colors.blueGrey.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 5, width: 40, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(height: 2, width: 25, color: Colors.blueGrey.shade200),
                    ],
                  ),
                  const CircleAvatar(radius: 10, backgroundColor: Colors.white),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 8, width: double.infinity, color: Colors.grey.shade200),
                    const SizedBox(height: 10),
                    Container(height: 4, width: 30, color: Colors.blueGrey.shade800),
                    const SizedBox(height: 4),
                    Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(height: 3, width: 25, color: Colors.blueGrey.shade800),
                            const SizedBox(height: 4),
                            Container(height: 2, width: double.infinity, color: Colors.grey.shade300),
                          ])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(height: 3, width: 25, color: Colors.blueGrey.shade800),
                            const SizedBox(height: 4),
                            Container(height: 2, width: double.infinity, color: Colors.grey.shade300),
                          ])),
                        ]
                    )
                  ]
              ),
            )
          ]
      );
    }
    // 5. MINIMALIST (Centered Style - Real Look)
    else if (type == 'centered') {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade300),
              const SizedBox(height: 8),
              Container(height: 5, width: 50, color: Colors.black87),
              const SizedBox(height: 4),
              Container(height: 2, width: 30, color: Colors.grey.shade500),
              const SizedBox(height: 12),
              Container(height: 2, width: 80, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Container(height: 4, width: 40, color: Colors.black87),
              const SizedBox(height: 6),
              Container(height: 2, width: 70, color: Colors.grey.shade300),
              const SizedBox(height: 4),
              Container(height: 2, width: 60, color: Colors.grey.shade300),
            ]
        ),
      );
    }
    // 6. CLASSIC (Simple Traditional Style - Real Look)
    else {
      return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 6, width: 60, color: Colors.black87),
                            const SizedBox(height: 4),
                            Container(height: 3, width: 40, color: Colors.grey.shade600),
                          ]
                      ),
                      CircleAvatar(radius: 12, backgroundColor: Colors.grey.shade300),
                    ]
                ),
                const SizedBox(height: 8),
                Container(height: 1, width: double.infinity, color: Colors.black),
                const SizedBox(height: 10),
                Container(height: 4, width: 35, color: Colors.black87),
                const SizedBox(height: 4),
                Container(height: 2, width: double.infinity, color: Colors.grey.shade300),
                const SizedBox(height: 4),
                Container(height: 2, width: 90, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Container(height: 4, width: 45, color: Colors.black87),
                const SizedBox(height: 4),
                Container(height: 2, width: double.infinity, color: Colors.grey.shade300),
              ]
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('CV Forge Pro', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blueGrey.shade900,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose Your Template', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                const SizedBox(height: 5),
                Text('Select a professional design to start building your resume.', style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade400)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 20,
                childAspectRatio: 0.65,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final t = templates[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResumeFormScreen(selectedTemplate: t['name']),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withOpacity(0.08),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // ⬅️ Mini CV Page
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade200, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: _buildMiniLayout(t['type']),
                                ),
                              ),
                            ),
                            // ⬅️ Design Ka Naam
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                              ),
                              child: Text(
                                t['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.blueGrey.shade800),
                              ),
                            ),
                          ],
                        ),
                        // ⬅️ Premium Tags
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: t['tag'] == 'ULTRA PRO'
                                  ? const LinearGradient(colors: [Color(0xFFC850C0), Color(0xFFFFCC70)])
                                  : null,
                              color: t['tag'] == 'ULTRA PRO' ? null : (t['tag'] == 'FREE' ? Colors.green : Colors.blueGrey.shade900),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              t['tag'],
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}