import 'package:ai_youtube/features/main/riverpod/welcome_riverpod.dart';
import 'package:ai_youtube/features/main/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class Welcome extends ConsumerStatefulWidget {
  const Welcome({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends ConsumerState<Welcome> {
  var box = Hive.box('apiKey');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(tileMode: TileMode.decal, colors: [
          Color.fromARGB(139, 74, 142, 231),
          Color.fromARGB(140, 140, 220, 225)
        ])),
        child: Center(
          child: Container(
            decoration: const BoxDecoration(
                color: Color.fromARGB(120, 239, 239, 239),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextAnimator(
                  'Hoşgeldiniz',
                  style: GoogleFonts.poppins(
                      fontSize: 30, fontWeight: FontWeight.w500),
                  incomingEffect:
                      WidgetTransitionEffects.outgoingOffsetThenScale(
                          duration: const Duration(milliseconds: 200)),
                ),
                const SizedBox(
                  height: 45,
                ),
                WidgetAnimator(
                  incomingEffect: WidgetTransitionEffects.incomingScaleUp(
                      duration: const Duration(milliseconds: 400)),
                  child: SizedBox(
                    width: 80.w,
                    child: Column(
                      children: [
                        TextField(
                          controller: ref.read(welcomeRiverpod).controller,
                          decoration: const InputDecoration(
                              labelText: 'Gemini Api Key',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        FilledButton(
                            style: const ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)))),
                                backgroundColor: WidgetStatePropertyAll(
                                    Color.fromARGB(200, 74, 142, 231))),
                            onPressed: () {
                              if (ref.read(welcomeRiverpod).controller.text !=
                                  "") {
                                box
                                    .put(
                                        'apiKey',
                                        ref
                                            .read(welcomeRiverpod)
                                            .controller
                                            .text)
                                    .whenComplete(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()));
                                });
                              }
                            },
                            child: const Text('Devam Et'))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
