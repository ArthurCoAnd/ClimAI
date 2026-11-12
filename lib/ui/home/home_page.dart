import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/theme/glass_theme.dart';
import '../../data/models/city.dart';
import '../city/city_page.dart';
import '../search/search_page.dart';
import '../widgets/page_header.dart';
import '../widgets/glass_controls.dart';
import '../widgets/glass_surfaces.dart';
import 'favorite_card.dart';

/// Main screen: the favorite municipalities with their current weather.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.services});

  final AppServices services;

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SearchPage(services: services)),
    );
  }

  void _openCity(BuildContext context, City city) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CityPage(services: services, city: city),
      ),
    );
  }

  Future<void> _remove(BuildContext context, City city) async {
    final messenger = ScaffoldMessenger.of(context);
    final index = await services.favorites.remove(city);
    if (index < 0) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${city.name} removido dos favoritos'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => services.favorites.add(city, index: index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = services.favorites;
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: ContentWidth(
            child: Column(
              children: [
                PageHeader(
                  title: 'ClimAI',
                  subtitle: 'Municípios favoritos',
                  actions: [
                    GlassIconButton(
                      icon: Icons.search,
                      tooltip: 'Buscar município',
                      onTap: () => _openSearch(context),
                    ),
                  ],
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: favorites,
                    builder: (context, _) {
                      if (!favorites.loaded) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final cities = favorites.favorites;
                      if (cities.isEmpty) {
                        return _EmptyState(
                          onSearch: () => _openSearch(context),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: favorites.refreshAll,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            GlassMetrics.screenMargin,
                            4,
                            GlassMetrics.screenMargin,
                            32,
                          ),
                          itemCount: cities.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final city = cities[index];
                            return FavoriteCard(
                              key: ValueKey(city.id),
                              city: city,
                              state: favorites.weatherOf(city),
                              onTap: () => _openCity(context, city),
                              onRemove: () => _remove(context, city),
                              onRetry: () => favorites.refresh(city),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(GlassMetrics.screenMargin),
      child: GlassNotice(
        icon: Icons.travel_explore,
        message:
            'Você ainda não tem municípios favoritos.\n'
            'Busque um município para acompanhar o clima.',
        actionLabel: 'Buscar município',
        actionIcon: Icons.search,
        onAction: onSearch,
      ),
    );
  }
}
