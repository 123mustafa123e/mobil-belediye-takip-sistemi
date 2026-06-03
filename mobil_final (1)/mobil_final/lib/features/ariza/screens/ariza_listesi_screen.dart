import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../bloc/ariza_cubit.dart';

class ArizaListesiScreen extends StatefulWidget {
  const ArizaListesiScreen({super.key});

  @override
  State<ArizaListesiScreen> createState() => _ArizaListesiScreenState();
}

class _ArizaListesiScreenState extends State<ArizaListesiScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ArizaCubit>().loadArizalar();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Şikayetlerim'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tümü'),
              Tab(text: 'Devam Eden'),
              Tab(text: 'Çözülen'),
            ],
          ),
        ),
        body: BlocBuilder<ArizaCubit, ArizaState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            return TabBarView(
              children: [
                _buildList(context, state.arizalar),
                _buildList(
                  context,
                  state.arizalar
                      .where(
                        (item) =>
                            item.durum != 'cozuldu' &&
                            item.durum != 'reddedildi',
                      )
                      .toList(),
                ),
                _buildList(
                  context,
                  state.arizalar
                      .where((item) => item.durum == 'cozuldu')
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<dynamic> arizalar) {
    if (arizalar.isEmpty) {
      return const Center(child: Text('Henüz arıza bildirimi bulunmuyor.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: arizalar.length,
      itemBuilder: (context, index) {
        final ariza = arizalar[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.build, color: Colors.blue),
            ),
            title: Text(ariza.baslik),
            subtitle: Text('Durum: ${ariza.durum}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.arizaDetay,
                arguments: {'arizaId': ariza.id},
              );
            },
          ),
        );
      },
    );
  }
}
