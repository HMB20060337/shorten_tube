import 'package:ai_youtube/features/main/repositories/summaries_model.dart';
import 'package:ai_youtube/features/main/riverpod/welcome_riverpod.dart';
import 'package:ai_youtube/features/main/screens/summaries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var box = Hive.box('db');
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 239, 239, 239),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: WidgetAnimator(
                  incomingEffect:
                      WidgetTransitionEffects.incomingSlideInFromTop(
                          duration: const Duration(milliseconds: 1000)),
                  child: PhysicalModel(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                    elevation: 5,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              TextField(
                                autofocus: false,
                                focusNode: _focusNode,
                                controller:
                                    ref.read(welcomeRiverpod).linkController,
                                decoration: const InputDecoration(
                                    labelText: 'Youtube Linki',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)))),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              FilledButton(
                                  style: const ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)))),
                                      backgroundColor: WidgetStatePropertyAll(
                                          Color.fromARGB(199, 54, 115, 196))),
                                  onPressed: () async {
                                    _focusNode.unfocus();

                                    await ref
                                        .read(welcomeRiverpod)
                                        .func(context);
                                  },
                                  child: const Text('Özet Çıkar'))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 2,
                child: WidgetAnimator(
                  incomingEffect:
                      WidgetTransitionEffects.incomingSlideInFromBottom(
                          duration: const Duration(milliseconds: 1400)),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 245, 245, 245),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, -2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              color: Colors.black12),
                        ]),
                    child: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'Son Özetler',
                              style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: TextButton(
                                    onPressed: () {
                                      box.clear();
                                    },
                                    child: Text(
                                      'Geçmişi Temizle',
                                      style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    )),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(
                          indent: 25,
                          endIndent: 25,
                        ),
                        Expanded(
                          child: ListenableBuilder(
                              listenable: box.listenable(),
                              builder: (context, snapshot) {
                                if (box.values.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 110),
                                      child: Text(
                                        'Hiç Özet Yok',
                                        style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: 5)
                                        .copyWith(bottom: 5),
                                    shrinkWrap: true,
                                    itemCount: box
                                        .values.length, // örnek bir item count
                                    itemBuilder: (context, index) {
                                      var list =
                                          box.values.toList().reversed.toList();
                                      var type = false;
                                      if (list[index].first) {
                                        type = true;
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: ListTile(
                                          enabled: (type == false &&
                                              list[index][2].isNotEmpty),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Summaries(
                                                            SummariesModel(
                                                                list[index]
                                                                    .last,
                                                                list[index]
                                                                    [2]))));
                                          },
                                          leading:
                                              const Icon(Icons.arrow_right),
                                          title: Text(
                                            list[index][1],
                                            style: GoogleFonts.poppins(
                                                color: Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          trailing: type
                                              ? const CircularProgressIndicator()
                                              : list[index][2].isEmpty
                                                  ? const Icon(
                                                      Icons.error_outline)
                                                  : const Icon(
                                                      Icons.chevron_right),
                                        ),
                                      );
                                    });
                              }),
                        )
                      ],
                    )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
